# The Cult

The Cult is a tokenized creator economy platform built on the high-performance Monad blockchain. It positions itself as the “ultimate playground” for communities (aptly termed cults) to launch and trade social tokens with real purpose beyond fleeting memes. By fusing community, culture, and memes, The Cult enables creators and their fan communities to monetize and engage in new ways. Its core value proposition lies in leveraging Monad’s speed and scalability to provide a seamless, low-cost tokenization experience while differentiating itself with built-in verification and fair launch mechanisms that foster trust and transparency.

Explore The Cult, be part of the global decentralized culture!

## Overview

The Cult is a decentralized platform built on the Monad blockchain that allows Creators to launch their own social tokens. The platform leverages smart contracts to create, manage, and trade these tokens securely and transparently.

## Features

- **Token Creation**: Communities can create their own social tokens with custom names, symbols, descriptions, and images.
- **Token Purchase**: Users can purchase social tokens.
- **Liquidity Pools**: Automatically create and manage liquidity pools on DEX for social tokens.
- **Funding Goals**: Each social token has a funding goal that, once reached, triggers the creation of a liquidity pool.

## Smart Contracts

The project includes the following smart contracts:

- **Lock.sol**: A contract that locks funds until a specified unlock time.
- **Token.sol**: An ERC20 token contract with minting functionality.
- **TokenFactory.sol**: A factory contract for creating and managing social tokens.

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

## Frontend

To check out the frontend UI, visit the `cult-frontend` submodule in the repository.

