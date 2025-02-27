//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.sol";
import "hardhat/console.sol";

contract TokenFactory {
    struct memeToken {
        string name;
        string symbol;
        string description;
        string tokenImageUrl;
        uint fundingRaised;
        address tokenAddress;
        address creatorAddress;
    }

    uint constant DECIMALS = 10 ** 18;
    uint constant MAX_SUPPLY = 1000000 * DECIMALS;
    uint constant INIT_SUPPLY = (20 * MAX_SUPPLY) / 100;

    uint constant MEMETOKEN_CREATION_FEE = 0.0001 ether;

    uint constant MEMETOKEN_FUNDING_GOAL = 24 ether;

    mapping(address => memeToken) addressToMemeTokenMapping;

    function createMemeToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory imageUrl
    ) public payable returns (address) {
        require(msg.value == MEMETOKEN_CREATION_FEE, "Insufficient fee");
        Token memeTokenCt = new Token(name, symbol, INIT_SUPPLY);
        address memeTokenAddress = address(memeTokenCt);
        memeToken memory newlyCreatedToken = memeToken(
            name,
            symbol,
            description,
            imageUrl,
            0,
            memeTokenAddress,
            msg.sender
        );
        addressToMemeTokenMapping[memeTokenAddress] = newlyCreatedToken;
        console.log("Meme Token deployed successfully to", memeTokenAddress);
        return memeTokenAddress;
    }

    function buyMemeToken(
        address memeTokenAddress,
        uint purcharseQty
    ) public payable returns (uint) {
        require(
            addressToMemeTokenMapping[memeTokenAddress].tokenAddress !=
                address(0),
            "Invalid meme token address"
        );

        memeToken storage listedToken = addressToMemeTokenMapping[
            memeTokenAddress
        ];
        require(
            addressToMemeTokenMapping[memeTokenAddress].fundingRaised <=
                MEMETOKEN_FUNDING_GOAL,
            "Funding goal has already been reached"
        );
    }
}
