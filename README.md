# Cult
The Celeb Token launchpad built on EVM, establishing a Web3 connection between the celebs and the fans, leveraging EVM infrastructure. 

Explore the Cult, be the part of global decentralised culture!

## Overview

Cult is a decentralized platform built on the Ethereum Virtual Machine (EVM) that allows celebrities to launch their own meme tokens. The platform leverages smart contracts to create, manage, and trade these tokens securely and transparently. This project is planned to be integrated into Monad blockchain which is EVM Compatible

## Features

- **Token Creation**: Celebrities can create their own meme tokens with custom names, symbols, descriptions, and images.
- **Token Purchase**: Users can purchase meme tokens.
- **Liquidity Pools**: Automatically create and manage liquidity pools on DEX for meme tokens.
- **Funding Goals**: Each meme token has a funding goal that, once reached, triggers the creation of a liquidity pool.

## Smart Contracts

The project includes the following smart contracts:

- **Lock.sol**: A contract that locks funds until a specified unlock time.
- **Token.sol**: An ERC20 token contract with minting functionality.
- **TokenFactory.sol**: A factory contract for creating and managing meme tokens.

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/amit-katyal/cult.git
    cd cult
    ```

2. Install dependencies:
    ```sh
    npm install
    ```

3. Set up environment variables:
    Create a `.env` file in the root directory and add your RPC URL:
    ```sh
    RPC_URL=<your_rpc_url>
    ```

## Usage

### Deploy Contracts

1. Compile the contracts:
    ```sh
    npx hardhat compile
    ```

2. Deploy the contracts:
    ```sh
    npx hardhat run scripts/deploy.js --network <network_name>
    ```

### Run Tests

Execute the test suite to ensure everything is working correctly:
```sh
npx hardhat test
```

## Contributing

We welcome contributions! Please fork the repository and submit pull requests.
