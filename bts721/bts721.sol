// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

// Ownable contract implementation
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
