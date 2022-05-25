// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ICashier {
    function stake(uint256 amount) external;

    function withdrawPermit(
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
        ) external;

    function stakingToken() external view returns (address);

    function rewardToken() external view returns (address);

    function totalStaked() external view returns (uint256);

    function getRewardTokenBalance() external view returns (uint256);

    function getStakingTokenBalance() external view returns (uint256);

}