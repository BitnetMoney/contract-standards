// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

// Import Ownable contract from external repository
import "https://github.com/BitnetMoney/contract-standards/library/Ownable.sol";

// Bitnet Token Standard 721 (BTS721) implementation
contract BTS721 is Ownable {
    // Mapping to track token ownership
    mapping(uint256 => address) private _owners;

    // Mapping to track token balances of owners
    mapping(address => uint256) private _balances;

    // Event emitted when token ownership changes
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // Constructor to initialize token name and symbol
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    string private name;
    string private symbol;

    // Function to get the name of the token
    function getName() external view returns (string memory) {
        return name;
    }

    // Function to get the symbol of the token
    function getSymbol() external view returns (string memory) {
        return symbol;
    }

    // Function to get the owner of a specific token
    function ownerOf(uint256 tokenId) external view returns (address) {
        return _owners[tokenId];
    }

    // Function to get the balance of tokens owned by an address
    function balanceOf(address owner) external view returns (uint256) {
        return _balances[owner];
    }

    // Function to mint a new token and assign ownership
    function mint(address to, uint256 tokenId) external {
        require(to != address(0), "BTS721: mint to the zero address");
        require(_owners[tokenId] == address(0), "BTS721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    string private _baseTokenURI;

    // Function to return the base URI for token metadata
    function baseTokenURI() external view returns (string memory) {
        return _baseTokenURI;
    }

    // Function to set a new base URI for token metadata
    function setBaseTokenURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }
}
