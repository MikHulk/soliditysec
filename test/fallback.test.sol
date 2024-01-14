// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "../src/fallback.sol";


contract TestBank is Test {

    BlackHole blh = new BlackHole();
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function test_deposit() public {
        assertEq(address(blh).balance, 0);
        hoax(user1, 5 ether);
        vm.expectEmit(false, false, false, true);
        emit BlackHole.Deposit(user1, 5 ether);
        blh.deposit{value: 5 ether}();
        assertEq(user1.balance, 0);
        assertEq(address(blh).balance, 5 ether);
        assertEq(blh.balances(user1), 5 ether);
    }

    function test_wrong_deposit() public {
        assertEq(address(blh).balance, 0);
        bytes memory payload = abi.encode("answer(uint)", 42);
        hoax(user1, 5 ether);
        vm.expectEmit(false, false, false, true);
        emit BlackHole.WrongOperation(user1, 5 ether);
        (bool sent, ) = address(blh).call{value: 5 ether}(payload);
        assertTrue(sent);
        assertEq(user1.balance, 0);
        assertEq(address(blh).balance, 5 ether);
        assertEq(blh.balances(user1), 0);
    }

    function test_fallback_deposit() public {
        assertEq(address(blh).balance, 0);
        hoax(user1, 5 ether);
        vm.expectEmit(false, false, false, true);
        emit BlackHole.Deposit(user1, 5 ether);
        (bool sent, ) = address(blh).call{value: 5 ether}("");
        assertTrue(sent);
        assertEq(user1.balance, 0);
        assertEq(address(blh).balance, 5 ether);
        assertEq(blh.balances(user1), 5 ether);
    }
}
