// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/* 
  @version BTS1155 Token Standard v.0.2.818
  This is the BTS1155 Token Standard interface definition.
*/

pragma solidity ^0.8.18;

/* Interface for BTS1155 standard */
interface IBTS1155 {
    function balanceOf(address owner, uint256 tokenId) external view returns (uint256);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function mint(address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
    function mintBatch(address to, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes calldata data) external;
    function burn(address from, uint256 tokenId, uint256 amount) external;
    function burnBatch(address from, uint256[] calldata tokenIds, uint256[] calldata amounts) external;
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

library Strings {
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

    function balanceOf(address owner, uint256 tokenId) external view override returns (uint256) {
        return _balances[owner][tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external override {
        require(msg.sender != operator, "BTS1155: Setting approval status for self");
        _operators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view override returns (bool) {
        return _operators[owner][operator];
    }

    function mint(address to, uint256 tokenId, uint256 amount, bytes calldata /*data*/) external override onlyOwner {
        require(to != address(0), "BTS1155: mint to the zero address");
        _balances[to][tokenId] += amount;
        emit TransferSingle(msg.sender, address(0), to, tokenId, amount);
    }

    function mintBatch(address to, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes calldata /*data*/) external override onlyOwner {
        require(to != address(0), "BTS1155: mint to the zero address");
        require(tokenIds.length == amounts.length, "BTS1155: ID and amount array length mismatch");
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            _balances[to][tokenIds[i]] += amounts[i];
        }
        emit TransferBatch(msg.sender, address(0), to, tokenIds, amounts);
    }

    function burn(address from, uint256 tokenId, uint256 amount) external override {
        require(from == msg.sender || _operators[from][msg.sender] == true, "BTS1155: caller is not owner nor approved");
        require(from != address(0), "BTS1155: burn from the zero address");
        _balances[from][tokenId] -= amount;
        emit TransferSingle(msg.sender, from, address(0), tokenId, amount);
    }

    function burnBatch(address from, uint256[] calldata tokenIds, uint256[] calldata amounts) external override {
        require(from == msg.sender || _operators[from][msg.sender] == true, "BTS1155: caller is not owner nor approved");
        require(tokenIds.length == amounts.length, "BTS1155: ID and amount array length mismatch");
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            _balances[from][tokenIds[i]] -= amounts[i];
        }
        emit TransferBatch(msg.sender, from, address(0), tokenIds, amounts);
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata /*data*/) external override {
        require(from == msg.sender || _operators[from][msg.sender] == true, "BTS1155: caller is not owner nor approved");
        require(from != address(0), "BTS1155: transfer from the zero address");
        require(to != address(0), "BTS1155: transfer to the zero address");

        _balances[from][id] -= amount;
        _balances[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);
    }

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