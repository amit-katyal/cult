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

    // Function to calculate the cost in wei for purchasing `tokensToBuy` starting from `currentSupply`
    function calculateCost(
        uint256 currentSupply,
        uint256 tokensToBuy
    ) public pure returns (uint256) {
        // Calculate the exponent parts scalred to avoid precision loss
        uint256 exponent1 = (K * (currentSupply + tokensToBuy)) / 10 ** 18;
        uint256 exponent2 = (K * currentSupply) / 10 ** 18;

        // Calcuate e^(kx) using the exp function
        uint256 exp1 = exp(exponent1);
        uint256 exp2 = exp(exponent2);

        // Cost formula: (P0 / k) * (e^(k * (currentSupply + tokensToBuy)) - e^(k * currentSupply))
        // We use (P0 * 10^18) / k to avoid precision loss
        uint256 cost = (INITIAL_PRICE * 10 ** 18 * (exp1 - exp2)) / K; //Adjust for k scaling without divising by zero
        return cost;
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

        Token tokenCt = Token(memeTokenAddress);

        uint currentSupply = tokenCt.totalSupply();
        uint availableSupply = MAX_SUPPLY - currentSupply;

        uint availableSupplyScaled = availableSupply / DECIMALS;
        uint purcharseQtyScaled = purcharseQty * DECIMALS;

        require(
            purcharseQtyScaled <= availableSupplyScaled,
            "Insufficient supply"
        );

        // Calulate the cost for purchasing purchaseQtyScaled tokens
    }
}
