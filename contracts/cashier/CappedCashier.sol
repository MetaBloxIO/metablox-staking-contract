// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Cashier } from "./Cashier.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CappedCashier is Cashier {
    using Address for address;
    uint256 public capacity;
    uint256 public minStakePerTime;
    uint256 public maxStakePerAddress;

    event CapacityChanged(uint256 oldCap, uint256 newCap);
    event MinStakePerTimeChanged(uint256 oldAmount, uint256 newAmount);
    event MaxStakePerAddressChanged(uint256 oldAmount, uint256 newAmount);
    event Recovered(address indexed token, uint256 amount);

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _capacity,
        uint256 _minStakePerTime,
        uint256 _maxStakePerAddress
    ) Cashier(_stakingToken, _rewardToken) {
        capacity = _capacity;
        minStakePerTime = _minStakePerTime;
        maxStakePerAddress = _maxStakePerAddress;
    }

    modifier checkLimit(uint256 _amount) {
        require(totalStaked + _amount <= capacity, "Staking: over capacity limit");
        require(_amount >= minStakePerTime, "Staking: over minStakePerTime limit");
        Stakeholder memory _holder = stakeholders[_msgSender()];
        require(_holder.staked + _amount <= maxStakePerAddress, "Staking: over maxStakePerAddress limit");
        _;
    }

    function stake(uint256 _amount) public override checkLimit(_amount) {
        super.stake(_amount);
    }

    function setCapcity(uint256 _newCap) public onlyOwner {
        require(_newCap >= totalStaked, "Staking: new cap less than already staked amount");
        uint256 oldAmount = capacity;
        capacity = _newCap;
        emit CapacityChanged(oldAmount, _newCap);
    }

    function setMinStakePerTime(uint256 _newMinStakePerTime) public onlyOwner {
        require(_newMinStakePerTime > 0, "Staking: new minStakePerTime less than 1");
        uint256 oldAmount = minStakePerTime;
        minStakePerTime = _newMinStakePerTime;
        emit MinStakePerTimeChanged(oldAmount, _newMinStakePerTime);
    }    
    
    function setMaxStakePerAddress(uint256 _newMaxStakePerAddress) public onlyOwner {
        require(_newMaxStakePerAddress > 0, "Staking: new maxStakePerAddress less than 1");
        uint256 oldAmount = maxStakePerAddress;
        maxStakePerAddress = _newMaxStakePerAddress;
        emit MaxStakePerAddressChanged(oldAmount, _newMaxStakePerAddress);
    }


    function recoverTokens(IERC20 _token) external virtual onlyOwner {
        uint256  balance = _token.balanceOf(address(this));
        _token.transfer(owner(), balance);
        emit Recovered(address(_token), balance);
    }

        
}