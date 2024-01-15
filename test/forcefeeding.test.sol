// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "../src/forcefeeding.sol";


contract BankAttackTest is Test {
    address owner = makeAddr("owner");
    address joker = makeAddr("badUser");
    Bank bank;
    Attack malicious;

    function setUp() public {
        vm.prank(owner);
        bank = new Bank();
        vm.prank(joker);
        malicious = new Attack(address(bank));
    }

    function test_attack() public {
        hoax(joker, 11 ether);
        malicious.attack{value: 11 ether}();
        assertEq(address(bank).balance, 11 ether);
        hoax(owner, 1 ether);
        vm.expectRevert();
        // owner cannot deposit
        bank.deposit{value: 1 ether}();
        vm.prank(owner);
        vm.expectRevert();
        // owner cannot withdraw
        bank.withdrawAll();
    }
}


contract SafeBankTest is Test {
    address owner = makeAddr("owner");
    address joker = makeAddr("badUser");
    SafeBank bank;
    Attack malicious;

    function setUp() public {
        vm.prank(owner);
        bank = new SafeBank();
        vm.prank(joker);
        malicious = new Attack(address(bank));
    }

    function test_attack() public {
        hoax(joker, 11 ether);
        malicious.attack{value: 11 ether}();
        assertEq(address(bank).balance, 11 ether);
        hoax(owner, 1 ether);
        vm.expectRevert();
        // owner cannot deposit
        bank.deposit{value: 1 ether}();
        vm.prank(owner);
        // but... owner can withdraw
        bank.withdrawAll();
        assertEq(address(bank).balance, 0);
        assertEq(address(owner).balance, 12 ether);
    }
}
