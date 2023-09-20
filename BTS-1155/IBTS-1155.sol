// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/**
 * @title BTS1155 Token Interface
 * @dev Solidity implementation for the BTS1155 token interface.
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