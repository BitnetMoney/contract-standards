// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

// Import Ownable from the specified repository
import "https://raw.githubusercontent.com/BitnetMoney/contract-standards/main/library/Ownable.sol";

// Contract implementing the BTS1155 token standard
contract BTS1155 is Ownable {
    // Struct to represent the approval status of an operator
    struct OperatorStatus {
        bool approved;
    }

    // Mapping to store the operator status for token transfers
    mapping(address => mapping(address => OperatorStatus)) private _operators;

    // Mapping to store the balance of tokens owned by addresses
    mapping(address => mapping(uint256 => uint256)) private _balances;

    // Event emitted on a single token transfer
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 tokenId, uint256 amount);

    // Event emitted on a batch token transfer
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] tokenIds, uint256[] amounts);

    // Event emitted when an operator's approval status changes
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Function to get the balance of a specific token owned by an address
    function balanceOf(address owner, uint256 tokenId) external view returns (uint256) {
        return _balances[owner][tokenId];
    }

    // Function to set the approval status for an operator
    function setApprovalForAll(address operator, bool approved) external {
        require(msg.sender != operator, "BTS1155: caller is not the operator");
        _operators[msg.sender][operator].approved = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // Function to check if an operator is approved for all tokens of an owner
    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _operators[owner][operator].approved;
    }

    // Function to mint a single token
    function mint(address to, uint256 tokenId, uint256 amount, bytes memory /*data*/) external {
        require(to != address(0), "BTS1155: mint to the zero address");
        _balances[to][tokenId] += amount;
        emit TransferSingle(msg.sender, address(0), to, tokenId, amount);
    }

    // Function to mint multiple tokens in a batch
    function mintBatch(address to, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes memory /*data*/) external {
        require(to != address(0), "BTS1155: mint to the zero address");
        require(tokenIds.length == amounts.length, "BTS1155: lengths mismatch");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _balances[to][tokenIds[i]] += amounts[i];
        }

        emit TransferBatch(msg.sender, address(0), to, tokenIds, amounts);
    }

    // Hook function executed before a token transfer
    function _beforeTokenTransfer(address from, address to, uint256 /*tokenId*/, uint256 /*amount*/) internal virtual {
        require(_operators[from][msg.sender].approved || _operators[msg.sender][to].approved, "BTS1155: caller is not owner nor approved");
    }

    // Function to burn a single token
    function burn(address from, uint256 tokenId, uint256 amount) external {
        require(from == msg.sender || _operators[from][msg.sender].approved, "BTS1155: caller is not owner nor approved");
        require(from != address(0), "BTS1155: burn from the zero address");
        _balances[from][tokenId] -= amount;
        emit TransferSingle(msg.sender, from, address(0), tokenId, amount);
    }

    // Function to burn multiple tokens in a batch
    function burnBatch(address from, uint256[] calldata tokenIds, uint256[] calldata amounts) external {
        require(from == msg.sender || _operators[from][msg.sender].approved, "BTS1155: caller is not owner nor approved");
        require(tokenIds.length == amounts.length, "BTS1155: lengths mismatch");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _balances[from][tokenIds[i]] -= amounts[i];
        }

        emit TransferBatch(msg.sender, from, address(0), tokenIds, amounts);
    }
}
