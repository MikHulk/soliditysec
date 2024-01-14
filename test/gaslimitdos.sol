// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/gaslimitdos.sol";


// run with a gas-limit to 3000000:
// forge test  -vvv --gas-limit 3000000
contract VotingAttackTest is Test {
    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address badUser = makeAddr("badUser");
    Voting target;
    Attack malicious;

    function setUp() public {
        vm.prank(owner);
        target = new Voting();
        vm.prank(badUser);
        malicious = new Attack(address(target));
    }

    function attack() private noGasMetering {
        vm.startPrank(badUser);
        malicious.attack();
        malicious.attack();
        malicious.attack();
        malicious.attack();
        malicious.attack();
        malicious.attack();
        vm.stopPrank();
    }

    function test_attack() public {
        vm.startPrank(owner);
        target.registerVoters(user1);
        target.registerVoters(user2);
        target.registerVoters(address(malicious));
        target.startProposalsRegistration();
        vm.stopPrank();
        
        vm.prank(user1);
        target.registerProposals("prop1");
        vm.prank(user2);
        target.registerProposals("prop2");

        attack();
        
        vm.startPrank(owner);
        target.endProposalsRegistration();
        target.startVotingSession();
        vm.stopPrank();
        
        vm.prank(user1);
        target.vote(0);
        vm.prank(user2);
        target.vote(1);
        
        vm.startPrank(owner);
        target.endVotingSession();
        vm.expectRevert();
        target.votesTallied();
        vm.stopPrank();
    }
}


// run with a gas-limit to 3000000:
// forge test  -vvv --gas-limit 3000000
contract SafeVotingTest is Test {
    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address badUser = makeAddr("badUser");
    SafeVoting target;
    Attack malicious;

    function setUp() public {
        vm.prank(owner);
        target = new SafeVoting();
        vm.prank(badUser);
        malicious = new Attack(address(target));
    }

    function attack() private noGasMetering {
        vm.startPrank(badUser);
        malicious.attack();
        malicious.attack();
        malicious.attack();
        malicious.attack();
        malicious.attack();
        malicious.attack();
        vm.stopPrank();
    }

   function test_attack() public {
        vm.startPrank(owner);
        target.registerVoters(user1);
        target.registerVoters(user2);
        target.registerVoters(address(malicious));
        target.startProposalsRegistration();
        vm.stopPrank();
        
        vm.prank(user1);
        target.registerProposals("prop1");
        vm.prank(user2);
        target.registerProposals("prop2");

        attack();
        
        vm.startPrank(owner);
        target.endProposalsRegistration();
        target.startVotingSession();
        vm.stopPrank();
        
        vm.prank(user1);
        target.vote(0);
        vm.prank(user2);
        target.vote(1);
        
        vm.startPrank(owner);
        target.endVotingSession();
        target.votesTallied();
        Voting.Proposal memory p = target.getWinner();
        assertEq(p.description, "prop1");
        vm.stopPrank();
    }
}
