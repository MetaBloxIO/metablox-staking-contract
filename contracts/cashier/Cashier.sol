// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
import { EIP712,ECDSA } from "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { ICashier } from "./ICashier.sol";

contract Cashier is ICashier, Ownable, Pausable, EIP712 {
    using Address for address;
    using Counters for Counters.Counter;

    struct Stakeholder {
        uint256 staked;
        uint256 timestamp;
    }

    address public override stakingToken;
    address public override rewardToken;
    uint256 public override totalStaked;

    mapping(address => Stakeholder) public stakeholders;

    mapping(address => Counters.Counter) private _nonces;
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address staker,uint256 value,uint256 nonce,uint256 deadline)");

    event Staked(address indexed staker, uint256 amount);
    event Withdrawal(address indexed staker, uint256 rewardAmount);

    constructor(address _stakingToken, address _rewardToken)
        EIP712("MetaBlox", "1")
    {
        require(_stakingToken.isContract(),"Staking: stakingToken not a contract address");
        require( _rewardToken.isContract(),"Staking: rewardToken not a contract address");
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    /**
     * @dev start staking
     */
    function stake(uint256 _amount) public virtual override whenNotPaused {
        require(_amount > 0, "Staking: amount can't be 0");
        Stakeholder storage stakeholder = stakeholders[_msgSender()];
        stakeholder.staked += _amount;
        if (stakeholder.timestamp == 0) {
            stakeholder.timestamp = block.timestamp;
        }
        totalStaked += _amount;
        IERC20(stakingToken).transferFrom(_msgSender(), address(this), _amount);
        emit Staked(_msgSender(), _amount);
    }

    function withdrawPermit(
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override whenNotPaused {
        Stakeholder memory stakeholder = stakeholders[_msgSender()];
        require(stakeholder.staked > 0,"WithdrawPermit: you have not participated in staking");
        require(block.timestamp <= deadline,"WithdrawPermit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                _msgSender(),
                value,
                _useNonce(_msgSender()),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner(), "WithdrawRewardPermit: invalid signature");

        _withdraw(_msgSender(), value);
    }

    function getRewardTokenBalance() public view override returns (uint256) {
        return IERC20(rewardToken).balanceOf(address(this));
    }

    function getStakingTokenBalance() public view override returns (uint256) {
        return IERC20(stakingToken).balanceOf(address(this));
    }

    function getStaked(address _stakeholder) public view returns (uint256) {
        return stakeholders[_stakeholder].staked;
    }

    function _withdraw(address _to, uint256 _reward) internal {
        IERC20(rewardToken).transfer(_to, _reward);

        emit Withdrawal(_msgSender(), _reward);
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address staker)
        internal
        virtual
        returns (uint256 current)
    {
        Counters.Counter storage nonce = _nonces[staker];
        current = nonce.current();
        nonce.increment();
    }

    /**
     * @dev See {IERC20Permit-nonces}. refrence EIP712
     */
    function nonces(address staker) public view virtual returns (uint256) {
        return _nonces[staker].current();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

}