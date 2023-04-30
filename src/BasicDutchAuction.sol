// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;


contract BasicDutchAuction {


    address payable public owner;
    address payable public winner;
    uint256 public auctionEndBlock;
    uint256 public reservePrice;
    uint256 public numBlocksActionOpen;
    uint256 public offerPriceDecrement;
    uint startBlockNumber;
    uint public winningBidAmount;
    bool public auctionEnded;
    uint public initialPrice;
    uint public currentPrice;

    constructor(uint256 _reservePrice, uint256 _numBlocksAuctionOpen, uint256 _offerPriceDecrement) {
        reservePrice = _reservePrice;
        numBlocksActionOpen = _numBlocksAuctionOpen;
        offerPriceDecrement = _offerPriceDecrement;
        owner = payable(msg.sender);
        startBlockNumber = block.number;
        auctionEndBlock = block.number + numBlocksActionOpen;
        initialPrice = _reservePrice + (_offerPriceDecrement * _numBlocksAuctionOpen);
        currentPrice = initialPrice;
        auctionEnded = false;
    }

    function updatePrice() internal {
        if (block.number >= auctionEndBlock) {
            auctionEnded = true;
            return;
        }
        currentPrice = initialPrice - (offerPriceDecrement * (block.number - startBlockNumber));
    }

    function getInfo() public {
        updatePrice();
    }

    function bid() public payable returns(address) {
        require(msg.sender != owner, "Owner cannot bid");
        if(auctionEnded && winner != address(0) && msg.sender != winner) {
            address payable refundCaller = payable(msg.sender);
            refundCaller.transfer(address(this).balance);
        }
        // check if the auction has ended
        require(!auctionEnded, "Auction has ended");
        // check if the block number is within the time limit
        require(block.number < auctionEndBlock, "Auction has ended");
        updatePrice();
        // // check if the bid is higher than the reserve price
        require(msg.value >= currentPrice, "Bid is lower than current price");
        require(winner == address(0), "Auction has already been won");
	    // // if the bid value is higher end the auction and transfer the funds to the owner
        auctionEnded = true;
        winner = payable(msg.sender);
        // owner.transfer(msg.value);
        winningBidAmount = msg.value;
        return winner;
    }


}