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
    }

    uint constant DECIMALS = 10 ** 18;
    uint constant MAX_SUPPLY = 1000000 * DECIMALS;
    uint constant INIT_SUPPLY = (20 * MAX_SUPPLY) / 100;

    mapping(address => memeToken) addressToMemeTokenMapping;

    function createMemeToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory imageUrl
    ) public returns (address) {
        Token memeTokenCt = new Token(name, symbol, INIT_SUPPLY);
        address memeTokenAddress = address(memeTokenCt);
        memeToken memory newlyCreatedToken = memeToken(
            name,
            symbol,
            description,
            imageUrl
        );
        addressToMemeTokenMapping[memeTokenAddress] = newlyCreatedToken;
        console.log(memeTokenAddress);
        return memeTokenAddress;
    }
}
