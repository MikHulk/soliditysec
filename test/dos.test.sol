// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/dos.sol";


contract AuctionAttackTest is Test {
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address badUser = makeAddr("badUser");
    Auction auction;
    Attack malicious;

    function setUp() public {
        vm.prank(user1);
        auction = new Auction();
        vm.prank(badUser);
        malicious = new Attack(address(auction));
    }

    function test_attack() public {
        hoax(user2, 5 ether);
        auction.bid{value: 1 ether}();
        assertEq(address(user2).balance, 4 ether);
        assertEq(address(auction).balance, 1 ether);
        hoax(badUser, 5 ether);
        malicious.attack{value: 2 ether}();
        assertEq(address(auction).balance, 2 ether);
        vm.prank(user2);
        assertEq(address(user2).balance, 5 ether);
        // cannot bid anymore
        vm.expectRevert();
        auction.bid{value: 3 ether}();
        assertEq(address(auction).balance, 2 ether);
    }
}


contract SafeAuctionTest is Test {
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address badUser = makeAddr("badUser");
    SafeAuction auction;
    Attack malicious;

    function setUp() public {
        vm.prank(user1);
        auction = new SafeAuction();
        vm.prank(badUser);
        malicious = new Attack(address(auction));
    }

    function test_attack() public {
        hoax(user2, 5 ether);
        auction.bid{value: 1 ether}();
        assertEq(address(user2).balance, 4 ether);
        assertEq(address(auction).balance, 1 ether);
        hoax(badUser, 5 ether);
        malicious.attack{value: 2 ether}();
        assertEq(address(auction).balance, 3 ether);
        vm.prank(user2);
        assertEq(address(user2).balance, 4 ether);
        auction.bid{value: 3 ether}();
        // bidder are not refund immediately
        assertEq(address(auction).balance, 6 ether);
        // but on demand
        vm.prank(user2);
        auction.withdraw();
        assertEq(address(auction).balance, 5 ether);
        assertEq(address(user2).balance, 2 ether);
    }
}
