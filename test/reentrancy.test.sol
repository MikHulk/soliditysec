// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/reentrancy.sol";


contract VaultAttackTest is Test {
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address badUser = makeAddr("badUser");
    Vault vault;
    VaultAttack malicious;

    function setUp() public {
        vm.prank(user1);
        vault = new Vault();
        vm.prank(badUser);
        malicious = new VaultAttack(address(vault));
    }

    function test_attack() public {
        hoax(user2, 1 ether);
        vault.store{value: 1 ether}();
        assertEq(address(vault).balance, 1 ether);
        hoax(badUser, 1 ether);
        console.logAddress(address(vault));
        malicious.attack{value: 1 ether}();
        // contract is drained
        assertEq(address(vault).balance, 0);
        // bad user gain 1 ether
        assertEq(address(badUser).balance, 2 ether);
        // user2 cannot redeem
        vm.prank(user2);
        vm.expectRevert("redeem fails on transfert");
        vault.redeem();
        assertEq(address(user2).balance, 0);
    }
}


contract SafeVaultTest is Test {
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address badUser = makeAddr("badUser");
    SafeVault vault;
    VaultAttack malicious;

    function setUp() public {
        vm.prank(user1);
        vault = new SafeVault();
        vm.prank(badUser);
        malicious = new VaultAttack(address(vault));
    }

    function test_attack() public {
        hoax(user2, 1 ether);
        vault.store{value: 1 ether}();
        assertEq(address(vault).balance, 1 ether);
        hoax(badUser, 1 ether);
        console.logAddress(address(vault));
        vm.expectRevert("redeem fails on transfert");
        malicious.attack{value: 1 ether}();
        // contract is not drained
        assertEq(address(vault).balance, 1 ether);
        // bad user gain lost ether
        assertEq(address(badUser).balance, 1 ether);
        // user2 can redeem
        vm.prank(user2);
        vault.redeem();
        assertEq(address(user2).balance, 1 ether);
    }
}
