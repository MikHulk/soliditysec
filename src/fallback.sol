/// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


contract BlackHole {
    mapping(address => uint) public balances;

    event WrongOperation(address origin, uint amount);
    event Deposit(address origin, uint amount);

    function deposit() public payable {
        uint amount = msg.value;
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    fallback() payable external {
        emit WrongOperation(msg.sender, msg.value);
    }

    receive() payable external {
        deposit();
    }
}
