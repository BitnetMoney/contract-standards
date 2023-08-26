// SPDX-License-Identifier: MIT
// Contract implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

// Import Ownable from the specified repository
import "https://raw.githubusercontent.com/BitnetMoney/contract-standards/main/library/Ownable.sol";

contract BTS1155 is Ownable {
    mapping(address => mapping(uint256 => uint256)) private _balances;
    mapping(address => mapping(uint256 => mapping(address => bool))) private _operators;

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 tokenId, uint256 amount);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] tokenIds, uint256[] amounts);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner, uint256 tokenId) external view returns (uint256) {
        return _balances[owner][tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        require(msg.sender != operator, "BTS1155: caller is not the operator");
        _operators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _operators[owner][operator];
    }

    function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) external {
        require(to != address(0), "BTS1155: mint to the zero address");
        _balances[to][tokenId] += amount;
        emit TransferSingle(msg.sender, address(0), to, tokenId, amount);
    }

    function mintBatch(address to, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes memory data) external {
        require(to != address(0), "BTS1155: mint to the zero address");
        require(tokenIds.length == amounts.length, "BTS1155: lengths mismatch");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _balances[to][tokenIds[i]] += amounts[i];
        }

        emit TransferBatch(msg.sender, address(0), to, tokenIds, amounts);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 amount) internal virtual {
        require(_operators[from][msg.sender] || _operators[msg.sender][to], "BTS1155: caller is not owner nor approved");
    }

    function burn(address from, uint256 tokenId, uint256 amount) external {
        require(from == msg.sender || _operators[from][msg.sender], "BTS1155: caller is not owner nor approved");
        require(from != address(0), "BTS1155: burn from the zero address");
        _balances[from][tokenId] -= amount;
        emit TransferSingle(msg.sender, from, address(0), tokenId, amount);
    }

    function burnBatch(address from, uint256[] calldata tokenIds, uint256[] calldata amounts) external {
        require(from == msg.sender || _operators[from][msg.sender], "BTS1155: caller is not owner nor approved");
        require(tokenIds.length == amounts.length, "BTS1155: lengths mismatch");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _balances[from][tokenIds[i]] -= amounts[i];
        }

        emit TransferBatch(msg.sender, from, address(0), tokenIds, amounts);
    }
}
