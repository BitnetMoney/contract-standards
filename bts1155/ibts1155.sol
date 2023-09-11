// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/* 
  @version BTS1155 Token Standard v.0.2.821
  This is the BTS1155 Token Standard interface definition.
*/
pragma solidity ^0.8.21;

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