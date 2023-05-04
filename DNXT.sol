// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./token/ERC20/ERC20.sol";
import "./token/ERC20/extensions/ERC20Burnable.sol";
import "./security/Pausable.sol";
import "./access/AccessControl.sol";
import "./token/ERC20/extensions/draft-ERC20Permit.sol";
import "./token/ERC20/extensions/ERC20Votes.sol";
import "./WhitelistVerifier.sol";
import "./Whitelist.sol";

contract DNXT is
    ERC20,
    ERC20Burnable,
    Pausable,
    AccessControl,
    ERC20Permit,
    ERC20Votes,
    WhitelistVerifier
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(
        address _whitelist
    )
        ERC20("Diamond NXT", "DNXT")
        ERC20Permit("Diamond NXT")
        WhitelistVerifier(_whitelist)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, 0x76162c23689533723Deee2624707a051418d3A6c);
        _grantRole(PAUSER_ROLE, 0x76162c23689533723Deee2624707a051418d3A6c);
        _mint(0x76162c23689533723Deee2624707a051418d3A6c, 100000000 * 10 ** decimals());
    }

    /**
     * @dev Add a new pauser. Can only be called by the admin.
     * @param account The address to be granted the pauser role.
     */
    function addPauser(
        address account
    ) public onlyRole(getRoleAdmin(PAUSER_ROLE)) {
        grantRole(PAUSER_ROLE, account);
    }

    /**
     * @dev Remove a pauser. Can only be called by the admin.
     * @param account The address to be revoked from the pauser role.
     */
    function removePauser(
        address account
    ) public onlyRole(getRoleAdmin(PAUSER_ROLE)) {
        revokeRole(PAUSER_ROLE, account);
    }

    /**
     * @dev Override the transfer function to check if addresses are whitelisted before transferring tokens.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to be transferred.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) whenNotPaused {
        verifyAccounts(from, to);
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev Pause the contract. Can only be called by the pauser.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpause the contract. Can only be called by the pauser.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Override required for Solidity. Updates token balances and total supply after a token transfer.
     * @param from The address from which the tokens are transferred.
     * @param to The address to which the tokens are transferred.
     * @param amount The amount of tokens transferred.
     */

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    /**
     * @dev Override required for Solidity. Mints new tokens and updates total supply.
     * @param to The address to which the tokens will be minted.
     * @param amount The amount of tokens to be minted.
     */
    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    /**
     * @dev Override required for Solidity. Burns tokens and updates total supply.
     * @param account The address from which the tokens will be burned.
     * @param amount The amount of tokens to be burned.
     */
    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
