// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IComplianceRegistry.sol";
import "./access/AccessControl.sol";

/**
 * @title Compliance
 * @dev A contract that provides compliance verification functionality for both ERC-20 and ERC-721 tokens, with individual enforcement settings.
 */
contract Compliance is AccessControl {
    IComplianceRegistry public complianceRegistry;
    mapping(address => bool) public enforcedCompliance;

    constructor(IComplianceRegistry _complianceRegistry) {
        complianceRegistry = _complianceRegistry;
    }

    function changeComplianceRegistry(IComplianceRegistry _newRegistry) public onlyRole(DEFAULT_ADMIN_ROLE) {
        complianceRegistry = _newRegistry;
    }

    function setComplianceEnforcement(address token, bool status) public onlyRole(DEFAULT_ADMIN_ROLE) {
        enforcedCompliance[token] = status;
    }

    function compliantERC20Transfer(address from, address to, uint256 amount, address token) public view returns (bool) {
        if (enforcedCompliance[token]) {
            return complianceRegistry.checkERC20Compliance(from, to, amount, token);
        }
        return true; // If compliance is not enforced for this token, allow the transfer.
    }

    function compliantERC721Transfer(address from, address to, uint256 tokenId, address token) public view returns (bool) {
        if (enforcedCompliance[token]) {
            return complianceRegistry.checkERC721Compliance(from, to, tokenId, token);
        }
        return true; // If compliance is not enforced for this token, allow the transfer.
    }
}