//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.sol";
import "hardhat/console.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

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

    address[] public memeTokenAddresses;

    uint constant DECIMALS = 10 ** 18;
    uint constant MAX_SUPPLY = 1000000 * DECIMALS;
    uint constant INIT_SUPPLY = (20 * MAX_SUPPLY) / 100;

    uint constant MEMETOKEN_CREATION_FEE = 0.0001 ether;

    uint constant MEMETOKEN_FUNDING_GOAL = 24 ether;

    address constant UNISWAP_V2_FACTORY_ADDRESS =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant UNISWAP_V2_ROUTER_ADDRESS =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    uint256 public constant INITIAL_PRICE = 30000000000000; // Initial price of the token in wei (P0), 3.00 * 10^13
    uint256 public constant K = 8 * 10 ** 15; // Growth rate(k), scaled to avoid precision loss

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
        memeTokenAddresses.push(memeTokenAddress);
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

    // Improved helper function to calculate e^x for larger x using the Taylor series expansion
    function exp(uint256 x) internal pure returns (uint256) {
        uint256 sum = 10 ** 18; // Start with 1 * 10^18 to avoid precision loss
        uint256 term = 10 ** 18; // Initial term is 1 * 10^18
        uint256 xPower = x; // Initial power of x
        for (uint256 i = 1; i < 20; i++) {
            // Increase the number of iterations for more precision
            term = (term * xPower) / (i * 10 ** 18); // x^i / i!
            sum += term;

            // Prevent overflow and unnecessary iterations
            if (term < 1) break;
        }

        return sum;
    }

    function buyMemeToken(
        address memeTokenAddress,
        uint purchaseQty
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
        uint purchaseQtyScaled = purchaseQty * DECIMALS;
        // console.log(purchaseQtyScaled)

        require(purchaseQty <= availableSupplyScaled, "Insufficient supply");

        // Calulate the cost for purchasing purchaseQtyScaled tokens
        uint currentSupplyScaled = (currentSupply - INIT_SUPPLY) / DECIMALS;
        uint requiredEth = calculateCost(currentSupplyScaled, purchaseQty);

        console.log("Required Eth: ", requiredEth);

        require(msg.value >= requiredEth, "Insufficient funds");

        listedToken.fundingRaised += msg.value;

        tokenCt.mint(purchaseQtyScaled, msg.sender);

        console.log("User's token balance: ", tokenCt.balanceOf(msg.sender));

        if (listedToken.fundingRaised >= MEMETOKEN_FUNDING_GOAL) {
            // Create the liquidity pool on Uniswap
            address pool = _createLiquidityPool(memeTokenAddress);
            console.log("Liquidity pool created at", pool);

            // Provide liquidity to the pool
            uint ethAmount = listedToken.fundingRaised;
            uint liquidity = _provideLiquidity(
                memeTokenAddress,
                INIT_SUPPLY,
                ethAmount
            );
            console.log("Liquidity provided to the pool", liquidity);

            // Burn the LP tokens that represent the liquidity
            _burnLPTokens(pool, liquidity);
        }

        return requiredEth;
    }

    function _createLiquidityPool(
        address memeTokenAddress
    ) internal returns (address) {
        // Create a Uniswap pair for the meme token and WETH
        IUniswapV2Factory factory = IUniswapV2Factory(
            UNISWAP_V2_FACTORY_ADDRESS
        );
        IUniswapV2Router01 router = IUniswapV2Router01(
            UNISWAP_V2_ROUTER_ADDRESS
        );
        address pair = factory.createPair(memeTokenAddress, router.WETH());
        return pair;
    }

    function _provideLiquidity(
        address memeTokenAddress,
        uint tokenAmount,
        uint ethAmount
    ) internal returns (uint) {
        // Add liquidity to the pool
        Token memeTokenCt = Token(memeTokenAddress);
        memeTokenCt.approve(UNISWAP_V2_ROUTER_ADDRESS, tokenAmount);
        IUniswapV2Router01 router = IUniswapV2Router01(
            UNISWAP_V2_ROUTER_ADDRESS
        );
        (uint amountToken, uint amountETH, uint liquidity) = router
            .addLiquidityETH{value: ethAmount}(
            memeTokenAddress,
            tokenAmount,
            tokenAmount,
            ethAmount,
            address(this),
            block.timestamp
        );
        return liquidity;
    }

    function _burnLPTokens(
        address pool,
        uint liquidity
    ) internal returns (uint) {
        // Burn the LP tokens that represent the liquidity
        IUniswapV2Pair uniswapv2pairct = IUniswapV2Pair(pool);
        uniswapv2pairct.transfer(address(0), liquidity);
        console.log("LP tokens burned", liquidity);
        return 1;
    }

    function getAllMemeTokens() public view returns (memeToken[] memory) {
        memeToken[] memory allTokens = new memeToken[](
            memeTokenAddresses.length
        );
        for (uint i = 0; i < memeTokenAddresses.length; i++) {
            allTokens[i] = addressToMemeTokenMapping[memeTokenAddresses[i]];
        }
        return allTokens;
    }
}
