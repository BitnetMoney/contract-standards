// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/* @version BTS721 Token Standard v.0.2.821 */

pragma solidity ^0.8.21;

/**
 * @notice Interface for BTS721, defining the necessary methods and events
 */
interface IBTS721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256);
    function baseURI() external view returns (string memory);
    function mint(address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract BTS721 is IBTS721 {
    /** 
     * @notice Internal state variables for ownership management
     */
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /** 
     * @notice Mappings to manage token ownership and balances
     */
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /** 
     * @notice Internal state variables for token metadata
     */
    string private _name;
    string private _symbol;
    string private _baseTokenURI;

    /**
     * @dev Constructor to initialize the BTS721 token
     * @param tokenName The name of the token
     * @param tokenSymbol The symbol of the token
     */
    constructor(string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Only owner can call functions with this modifier
     */
    modifier onlyOwner() {
        require(isOwner(), "BTS721: caller is not the owner");
        _;
    }

    /**
     * @dev Checks if the caller is the owner
     * @return True if the caller is the owner
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Renounces ownership of the contract
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership to a new address
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "BTS721: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Gets the name of the token
     * @return The name of the token
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the symbol of the token
     * @return The symbol of the token
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Gets the owner of a specific token ID
     * @param tokenId The ID of the token
     * @return The owner of the token
     */
    function ownerOf(uint256 tokenId) external view override returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Gets the balance of tokens for a specific address
     * @param owner The address to query the balance of
     * @return The balance of tokens for the given address
     */
    function balanceOf(address owner) external view override returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Gets the base URI for the token metadata
     * @return The base URI string
     */
    function baseURI() external view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Mints a new token and assigns ownership to the 'to' address
     * @param to The address that will receive the minted token
     * @param tokenId The token ID to mint
     */
    function mint(address to, uint256 tokenId) external override onlyOwner {
        require(to != address(0), "BTS721: mint to the zero address");
        require(_owners[tokenId] == address(0), "BTS721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Safely transfers a token from one address to another
     * @param from The address to transfer the token from
     * @param to The address to transfer the token to
     * @param tokenId The ID of the token to transfer
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        require(msg.sender == from || _isApprovedOrOwner(msg.sender, tokenId), "BTS721: transfer caller is not owner nor approved");
        require(to != address(0), "BTS721: transfer to the zero address");
        require(_owners[tokenId] == from, "BTS721: token not owned by the sender");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to check if a given address is the owner or approved operator of a given token ID
     * @param spender The address to check
     * @param tokenId The token ID to check
     * @return True if the address is the owner or approved operator, false otherwise
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = _owners[tokenId];
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Gets the approved address for a token ID
     * @param tokenId The token ID to query
     * @return The approved address for the token ID
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "BTS721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Checks if an address is approved for all tokens of a given address
     * @param owner The address to check for
     * @param operator The address to check against
     * @return True if the address is approved for all tokens of the given address, false otherwise
     */
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
}
