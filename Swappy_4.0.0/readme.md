# BlockchainAddressRegistry Smart Contract 4INT

## Overview

The `BlockchainAddressRegistry` is a Solidity smart contract designed for the EVM blockchain. It is primarily aimed at managing blockchain addresses and facilitating fiat transactions, while also implementing a cashback reward system based on the balance of Forint tokens held by users. This contract integrates with ERC20 tokens and includes functionalities like pausing and unpausing the contract operations, managing user tiers, and handling claimable balances.

## Contract Features

### Security Management
- **pause()**: Allows the contract owner to halt the operations of the contract. This is a critical feature for emergency response or maintenance purposes. Once paused, the contract's main functionalities will be temporarily disabled until it is unpaused.
- **unpause()**: Resumes the operations of the contract after being paused. This function ensures that the contract can return to normal operation after the resolution of any issues or completion of maintenance.

### 4INT Token Configuration
- **setForintAddress(address, uint256)**: Configures the Forint ERC20 token's address and decimal places. This setting is crucial for the contract to interact correctly with the Forint token.
- **setUsdtAddress(address, uint256, uint256)**: Sets the USDT token's address, decimal places, and the minimum amount claimable by users. It enables the contract to handle transactions and rewards in USDT.
- **getForintBalance(address)**: Retrieves the balance of Forint tokens for a specified user address. This function is essential for calculating cashback and other rewards based on the user's Forint token holdings.

### User Tier and Cashback Configuration
- **setThreshold(uint256, uint256, uint256)**: Establishes the token balance thresholds for different user tiers, namely silver, gold, and platinum. These tiers are used to determine the rate of cashback and other benefits.
- **setCashback(uint256, uint256, uint256, uint256)**: Sets the cashback percentages for each tier and the decimal precision for cashback calculations. This function is key to defining the rewards for users based on their tier.
- **getCashback(address)**: Computes the cashback percentage for a user based on their Forint token balance. It enables dynamic calculation of rewards aligned with the user's current holdings.

### Blockchain Address Management
- **addBlockchain(string)**: Adds support for a new blockchain. This function allows the contract to be extended to support additional blockchains, enhancing its versatility.
- **isBlockchainSupported(string)**: Checks whether a blockchain is currently supported by the contract. It's a utility function to verify the availability of a blockchain in the system.
- **removeBlockchain(string)**: Removes a blockchain from the list of supported ones. This function provides flexibility in managing the blockchains that the contract interacts with.
- **setMaxAddressLength(uint256)**: Sets the maximum allowable length for blockchain addresses. It helps in maintaining a standard and preventing errors related to address length.
- **setAddress(string, string)**: Associates a user's Ethereum account with an address on another blockchain. This cross-chain functionality broadens the usability of the contract.
- **getAddress(string)**: Retrieves the blockchain address associated with the user's Ethereum account for a specified blockchain.
- **removeAddress(string)**: Deletes a previously set blockchain address for the user's Ethereum account. It offers users the flexibility to manage their linked addresses.

### Fiat Transaction Management
- **addFiatTransaction(address, string, uint256, uint256, string, uint)**: Records a fiat transaction, including its details and cashback calculations. This function is integral to tracking and rewarding fiat transactions made by users.
- **getFiatTransactions(address)**: Retrieves all fiat transactions associated with a specific user. It provides a history of transactions for audit and verification purposes.

### Claim Functionality
- **addRedeemableBalance(address, uint256, uint256)**: Credits a user's account with a redeemable balance in USDT and Forint tokens. This function is crucial for managing the rewards that users can claim.
- **editRedeemableBalance(address, uint256, uint256)**: Modifies the redeemable balance for a user, providing flexibility in reward management.
- **claimBalance()**: Enables users to claim their accumulated rewards in USDT and Forint tokens. This function is a key feature allowing users to access the benefits they have earned.

## Installation and Usage

To utilize this contract, set up a Solidity development environment compatible with Solidity version ^0.8.23. Follow these steps:

1. Clone the repository containing the smart contract.
2. Install necessary dependencies, such as interface contracts.
3. Compile the contract using a Solidity compiler like `sol