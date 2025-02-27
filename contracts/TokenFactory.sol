//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.sol";

contract TokenFactory {
    uint constant DECIMALS = 10 ** 18;
    uint constant MAX_SUPPLY = 1000000 * DECIMALS;
    uint constant INIT_SUPPLY = (20 * MAX_SUPPLY) / 100;

    function createMemeToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory imageUrl
    ) public returns (address) {}
}
