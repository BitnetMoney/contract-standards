// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/**
 * @title BTS1155 Token Standard
 * @dev Solidity implementation for the BTS1155 token standard.
 * @notice This interface defines the functions and events required by the BTS1155 token standard.
 * @notice BTS1155 Token Standard v.0.2.818
 */

pragma solidity ^0.8.18;

/* Interface for BTS1155 standard */
interface IBTS1155 {
    // Get the balance of a specific token ID owned by a specific address
    function balanceOf(address owner, uint256 tokenId) external view returns (uint256);
    
    // Set approval for an operator to manage all of the caller's assets
    function setApprovalForAll(address operator, bool approved) external;
    
    // Check if an operator is approved to manage all of an owner's assets
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    
    // Mint a new token with a specific ID and amount to a given address
    function mint(address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
    
    // Mint multiple tokens with given IDs and amounts to a given address
    function mintBatch(address to, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes calldata data) external;
    
    // Burn a specific amount of a token with a given ID owned by a specific address
    function burn(address from, uint256 tokenId, uint256 amount) external;
    
    // Burn multiple tokens with given IDs and amounts owned by a specific address
    function burnBatch(address from, uint256[] calldata tokenIds, uint256[] calldata amounts) external;
    
    // Safely transfer a specific amount of a token with a given ID from one address to another
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    
    // Safely transfer multiple tokens with given IDs and amounts from one address to another
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

library Strings {
    // Convert a uint256 to a string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

contract BTSOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    // Get the current owner's address
    function owner() public view returns (address) {
        return _owner;
    }

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    // Check if the caller is the owner
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    // Relinquish ownership of the contract
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Transfer ownership to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    // Internal function to transfer ownership
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BTS1155 is IBTS1155, BTSOwnable {
    using Strings for uint256; // Import the Strings library for uint256 to string conversion

    mapping(address => mapping(uint256 => uint256)) private _balances;
    mapping(address => mapping(address => bool)) private _operators;

    string private _uriPrefix; // Prefix for token URIs (e.g., "https://example.com/tokens/")
    string private _uriSuffix; // Suffix for token URIs (e.g., ".json")

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 tokenId, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Constructor to set the URI prefix and suffix during contract deployment
    constructor(string memory uriPrefix, string memory uriSuffix) {
        _uriPrefix = uriPrefix;
        _uriSuffix = uriSuffix;
    }

    // Function to set the URI prefix and suffix if needed
    function setURI(string memory uriPrefix, string memory uriSuffix) external onlyOwner {
        _uriPrefix = uriPrefix;
        _uriSuffix = uriSuffix;
    }

    // Function to retrieve the URI for a specific token ID
    function uri(uint256 tokenId) external view returns (string memory) {
        require(tokenId > 0, "BTS1155: URI query for nonexistent token");
        return string(abi.encodePacked(_uriPrefix, tokenId.toString(), _uriSuffix));
    }

    // Get the balance of a specific token ID owned by a specific address
    function balanceOf(address owner, uint256 tokenId) external view override returns (uint256) {
        return _balances[owner][tokenId];
    }

    // Set approval for an operator to manage all of the caller's assets
    function setApprovalForAll(address operator, bool approved) external override {
        require(msg.sender != operator, "BTS1155: Setting approval status for self");
        _operators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // Check if an operator is approved to manage all of an owner's assets
    function isApprovedForAll(address owner, address operator) external view override returns (bool) {
        return _operators[owner][operator];
    }

    // Mint a new token with a specific ID and amount to a given address
    function mint(address to, uint256 tokenId, uint256 amount, bytes calldata /*data*/) external override onlyOwner {
        require(to != address(0), "BTS1155: mint to the zero address");
        _balances[to][tokenId] += amount;
        emit TransferSingle(msg.sender, address(0), to, tokenId, amount);
    }

    // Mint multiple tokens with given IDs and amounts to a given address
    function mintBatch(address to, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes calldata /*data*/) external override onlyOwner {
        require(to != address(0), "BTS1155: mint to the zero address");
        require(tokenIds.length == amounts.length, "BTS1155: ID and amount array length mismatch");
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            _balances[to][tokenIds[i]] += amounts[i];
        }
        emit TransferBatch(msg.sender, address(0), to, tokenIds, amounts);
    }

    // Burn a specific amount of a token with a given ID owned by a specific address
    function burn(address from, uint256 tokenId, uint256 amount) external override {
        require(from == msg.sender || _operators[from][msg.sender] == true, "BTS1155: caller is not owner nor approved");
        require(from != address(0), "BTS1155: burn from the zero address");
        _balances[from][tokenId] -= amount;
        emit TransferSingle(msg.sender, from, address(0), tokenId, amount);
    }

    // Burn multiple tokens with given IDs and amounts owned by a specific address
    function burnBatch(address from, uint256[] calldata tokenIds, uint256[] calldata amounts) external override {
        require(from == msg.sender || _operators[from][msg.sender] == true, "BTS1155: caller is not owner nor approved");
        require(tokenIds.length == amounts.length, "BTS1155: ID and amount array length mismatch");
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            _balances[from][tokenIds[i]] -= amounts[i];
        }
        emit TransferBatch(msg.sender, from, address(0), tokenIds, amounts);
    }

    // Safely transfer a specific amount of a token with a given ID from one address to another
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata /*data*/) external override {
        require(from == msg.sender || _operators[from][msg.sender] == true, "BTS1155: caller is not owner nor approved");
        require(from != address(0), "BTS1155: transfer from the zero address");
        require(to != address(0), "BTS1155: transfer to the zero address");

        _balances[from][id] -= amount;
        _balances[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);
    }

    // Safely transfer multiple tokens with given IDs and amounts from one address to another
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata /*data*/) external override {
        require(from == msg.sender || _operators[from][msg.sender] == true, "BTS1155: caller is not owner nor approved");
        require(from != address(0), "BTS1155: transfer from the zero address");
        require(to != address(0), "BTS1155: transfer to the zero address");
        require(ids.length == amounts.length, "BTS1155: ID and amount array length mismatch");

        for (uint256 i = 0; i < ids.length; ++i) {
            _balances[from][ids[i]] -= amounts[i];
            _balances[to][ids[i]] += amounts[i];
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);
    }
}
