// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./Whitelist.sol";
import "./access/AccessControl.sol";

/**
 * @title WhitelistVerifier
 * @dev A contract that provides whitelist verification functionality to derived contracts.
 */
contract WhitelistVerifier is AccessControl {
    Whitelist public whitelist;
    bool public verificationActive;

    /**
     * @dev Initializes the contract by setting the address of the whitelist contract and enabling verification.
     * @param _whitelist The address of the whitelist contract.
     */
    constructor(address _whitelist) {
        whitelist = Whitelist(_whitelist);
        verificationActive = true;
    }

    /**
     * @dev Changes the address of the whitelist contract.
     * @param _whitelist The new address of the whitelist contract.
     */
    function changeWhitelist(
        address _whitelist
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        whitelist = Whitelist(_whitelist);
    }

    /**
     * @dev Enables whitelist verification.
     */
    function enableVerification() public onlyRole(DEFAULT_ADMIN_ROLE) {
        verificationActive = true;
    }

    /**
     * @dev Disables whitelist verification.
     */
    function disableVerification() public onlyRole(DEFAULT_ADMIN_ROLE) {
        verificationActive = false;
    }

    /**
     * @dev Verifies that `_address` is whitelisted before a token transfer if verification is active.
     * @param _address The address to be checked against the whitelist.
     */
    function checkWhitelist(address _address) internal view returns (bool) {
        return whitelist.whitelisted(_address);
    }

    /**
     * @dev Verifies if `_address` is blacklisted before a token transfer.
     * @param _address The address to be checked against the blacklist.
     */
    function checkBlacklist(address _address) internal view returns (bool) {
        return whitelist.blacklisted(_address);
    }

    /**
     * @dev Check if an address can execute a function by verifying it is not blacklisted.
     * @param _address The address to be checked against the blacklist.
     */
    function _requireNotBlacklisted(address _address) internal view {
        require(
            !checkBlacklist(_address),
            string(
                abi.encodePacked(
                    "Whitelist Verifier: account ",
                    Strings.toHexString(uint160(_address), 20),
                    " is blacklisted"
                )
            )
        );
    }

    /**
     * @dev Check if an address can execute a function by verifying it is whitelisted if verification is active.
     * @param _address The address to be checked against the whitelist.
     */
    function _requireWhitelisted(address _address) internal view {
        if (verificationActive) {
            require(
                checkWhitelist(_address),
                string(
                    abi.encodePacked(
                        "Whitelist Verifier: account ",
                        Strings.toHexString(uint160(_address), 20),
                        " is not whitelisted"
                    )
                )
            );
        }
    }

    /**
     * @dev Check if an address can execute a function by verifying it is not blacklisted or is whitelisted if verification is active.
     * @param _address The address to be checked against the whitelist and blacklist.
     */
    function canExecute(address _address) public view returns (bool) {
        _requireNotBlacklisted(_address);
        _requireWhitelisted(_address);
        return true;
    }

    /**
     * @dev Returns true if `from` and `to` are not blacklisted or are whitelisted if verification is active, reverts otherwise.
     * @param from The address to be checked against the whitelist/blacklist.
     * @param to The address to be checked against the whitelist/blacklist.
     * @return bool Whether the addresses are not blacklisted or are whitelisted if verification is active.
     */
    function verifyAccounts(
        address from,
        address to
    ) public view returns (bool) {
        canExecute(from);
        canExecute(to);
        return true;
    }
}
