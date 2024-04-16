// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IComplianceRegistry
 * @dev Interface for compliance registries handling both ERC-20 and ERC-721 tokens.
 */
interface IComplianceRegistry {
    function checkERC20Compliance(address from, address to, uint256 amount, address token) external view returns (bool);
    function checkERC721Compliance(address from, address to, uint256 tokenId, address token) external view returns (bool);
}
