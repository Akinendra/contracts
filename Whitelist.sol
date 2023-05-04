// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./access/AccessControl.sol";

contract Whitelist is AccessControl {
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public blacklisted;

    event Whitelisted(address indexed account);
    event RemovedFromWhitelist(address indexed account);
    event Blacklisted(address indexed account);
    event RemovedFromBlacklist(address indexed account);

    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");

    constructor(address _admin, address _whitelister) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(WHITELISTER_ROLE, _whitelister);
    }

    /**
     * @dev Whitelist account.
     * @param account The address to be whitelisted.
     */
    function whitelistAccount(
        address account
    ) public onlyRole(WHITELISTER_ROLE) {
        whitelisted[account] = true;
        emit Whitelisted(account);
    }

    /**
     * @dev Blacklist account.
     * @param account The address to be blacklisted.
     */
    function blacklistAccount(
        address account
    ) public onlyRole(WHITELISTER_ROLE) {
        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Remove an account from the whitelist.
     * @param account The address to be removed from the whitelist.
     */
    function removeFromWhitelist(
        address account
    ) public onlyRole(WHITELISTER_ROLE) {
        whitelisted[account] = false;
        emit RemovedFromWhitelist(account);
    }

    /**
     * @dev Remove an account from the blacklist.
     * @param account The address to be removed from the blacklist.
     */
    function removeFromBlacklist(
        address account
    ) public onlyRole(WHITELISTER_ROLE) {
        blacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }

    /**
     * @dev Whitelist multiple accounts at once by passing an array of addresses.
     * @param users The array of addresses to be whitelisted.
     */
    function batchWhitelist(
        address[] memory users
    ) public onlyRole(WHITELISTER_ROLE) {
        uint8 i = 0;
        for (i; i < users.length; i++) {
            whitelistAccount(users[i]);
        }
    }

    /**
     * @dev Add a new whitelister. Can only be called by the admin.
     * @param account The address to be granted the whitelister role.
     */
    function addWhitelister(
        address account
    ) public onlyRole(getRoleAdmin(WHITELISTER_ROLE)) {
        grantRole(WHITELISTER_ROLE, account);
    }

    /**
     * @dev Remove a whitelister. Can only be called by the admin.
     * @param account The address to be revoked from the whitelister role.
     */
    function removeWhitelister(
        address account
    ) public onlyRole(getRoleAdmin(WHITELISTER_ROLE)) {
        revokeRole(WHITELISTER_ROLE, account);
    }
}
