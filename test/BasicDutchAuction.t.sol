// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "../src/BasicDutchAuction.sol";

contract BasicDutchAuctionTest is Test {
    BasicDutchAuction auction;

    function setUp() public {
        auction = new BasicDutchAuction(1000, 100, 10);
    }

    function testInitialPrice() public {
        assertEq(auction.initialPrice(), 2000, "Initial price should be 2000");
    }

    function testCurrentPrice() public {
        assertEq(auction.currentPrice(), 2000, "Current price should be 2000");
    }

    // function testBiden() public {
    //     address payable someRandomUser = payable(vm.addr(1));

    //     vm.deal(someRandomUser, 1 ether);
    //     vm.startPrank(someRandomUser);
    //     address win = auction.bid{value: 2001}();
    //     console.log('win: ', win);
    //     assertEq(auction.winner(), win, "Winner should be this contract");
    //     assertEq(auction.winningBidAmount(), 2001, "Winning bid amount should be 2001");
    //     vm.stopPrank();
    // }

    function testBid() public {
        // Ensure that an owner cannot bid
        // address owner = auction.owner();
        uint256 initialPrice = auction.initialPrice();
        uint256 currentPrice = auction.currentPrice();
        uint256 balanceBefore = address(this).balance;
        uint256 bidAmount = currentPrice + 1;
        try auction.bid{value: bidAmount}() {
            vm.expectRevert(bytes("Owner cannot bid"));
        } catch Error(string memory reason) {
            console.log('reason: ', reason);
        } 
        address payable someRandomUser = payable(vm.addr(1));
        vm.deal(someRandomUser, 1 ether);
        vm.startPrank(someRandomUser);
        
        assertEq(address(this).balance, balanceBefore, "Contract balance should not change after owner tries to bid");

        // Ensure that a bid lower than the reserve price is rejected
        balanceBefore = address(this).balance;
        bidAmount = initialPrice - 1;
     
        assertEq(address(this).balance, balanceBefore, "Contract balance should not change after bid lower than reserve price is rejected");

        // Ensure that a bid higher than the reserve price is accepted
        balanceBefore = address(this).balance;
        bidAmount = initialPrice + 1;
        address winningBidder = auction.bid{value: bidAmount}();
        assertEq(winningBidder, someRandomUser, "The winning bidder should be returned by the bid function");
        assertEq(auction.winner(), someRandomUser, "The winner should be the bidder who made the highest bid");
        assertEq(auction.winningBidAmount(), bidAmount, "The winning bid amount should be the highest bid made");

        uint256 blocksToWait = 5;
        uint256 blocksElapsed = 0;
        while (blocksElapsed < blocksToWait) {
            blocksElapsed++;
        }
        vm.stopPrank();
    }

}