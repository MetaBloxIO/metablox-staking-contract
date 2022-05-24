/* SPDX-License-Identifier: MIT */
pragma solidity >=0.4.22 <=0.8.13;

contract MetabloxStaking {

    address public owner;
    uint256 public tokenBalance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        owner = msg.sender;
        tokenBalance = 100;
    }

    function mint(uint256 _amount) public {
        require(msg.sender == owner, "Only the owner can mint new tokens");
        tokenBalance += _amount;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        success = false;
        require(msg.sender == owner, "Only the owner can transfer tokens");
        require(_value <= tokenBalance, "Not enough tokens in pool to transfer");
        emit Transfer(address(this), _to, _value);
        success = true;
    }

    function receiveTokens(address _from, uint256 _value) public returns (bool success) {
        success = false;
        emit Transfer(_from, address(this), _value);
        success = true;
    }
}
