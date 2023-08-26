# Bitnet Contract Standards

Welcome to the Bitnet Contract Standards repository! This repository provides a set of contract standards developed by Bitnet to facilitate the creation of secure and interoperable smart contracts on the Bitnet blockchain. These standards are designed to enhance security, control, and usability within the Bitnet decentralized ecosystem.

## Table of Contents

- [Introduction](#introduction)
- [Bitnet Token Standards](#bitnet-token-standards)
- [Library Assets](#library-assets)
- [Importing Standards](#importing-standards)
- [Example Implementations](#example-implementations)
- [Contributing](#contributing)
- [License](#license)

## Introduction

In the rapidly evolving blockchain space, standardized smart contract designs play a crucial role in ensuring security and compatibility. The Bitnet Contract Standards aim to provide developers with a solid foundation for creating decentralized applications, especially those involving tokenization and DeFi functionalities, within the Bitnet network.

## Bitnet Token Standards

The Bitnet Contract Standards consist of token standards that build upon widely recognized standards, enhancing them with additional features and functionalities specific to the Bitnet network. The following token standards are currently available:

- [BTS20](./bts20/bts20.sol): An extended version of the token standard with added functionalities, designed to enhance security and control, tailored for the Bitnet network.

- [BTS21](./bts21/bts21.sol): An extended version of the BTS20 token standard with integrated security enhancements, control features, and usability improvements, designed for Bitnet.

- [BTS1155](./bts1155/bts1155.sol): A standard for multi-token contracts, offering both fungible and non-fungible token capabilities within the Bitnet network.

- [BTS721](./bts721/bts721.sol): A standard for non-fungible tokens (NFTs), providing the foundation for unique and indivisible digital assets on the Bitnet network.

## Library Assets

The `/library` folder contains essential library assets that can be imported and used in your smart contracts on the Bitnet network:

- [Ownable.sol](./library/Ownable.sol): A library contract that provides basic authorization control functions, simplifying the implementation of user access controls.

- [ReentrancyGuard.sol](./library/ReentrancyGuard.sol): A library contract that helps prevent reentrant attacks by using a mutex pattern to guard against multiple calls.

## Importing Standards

To use the Bitnet Token Standards or library assets in your smart contracts on the Bitnet network, follow these steps:

1. In your contract file, use the following import statement to access the desired standard or library:

   ```solidity
   import "https://raw.githubusercontent.com/BitnetMoney/contract-standards/main/bts20/bts20.sol";
   ```

   or

   ```solidity
   import "https://raw.githubusercontent.com/BitnetMoney/contract-standards/main/library/Ownable.sol";
   ```

2. Inherit from the imported contract in your contract's inheritance list.

3. You can now utilize the functionalities provided by the Bitnet Token Standards or library assets within your contract on the Bitnet network.

## Example Implementations

Explore the provided example contracts in our **[main Wiki](https://github.com/BitnetMoney/bitnet/wiki)** to understand how to implement and customize the Bitnet Token Standards in your projects on the Bitnet network. Each example contract includes detailed comments explaining the usage of functions and features.

## Contributing

We welcome contributions to improve and expand the Bitnet Contract Standards repository. Feel free to submit issues or pull requests for bug fixes, enhancements, or new standards.

## License

The Bitnet Contract Standards are released under the MIT License. See the [License](./LICENSE) file for more details.
