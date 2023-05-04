// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
import "../access/Ownable.sol";


/**
 * @dev A token holder contract that allows beneficiaries to extract
 * tokens after a given release time.
 */
contract DiamondNXTTimeLock is Ownable {

    /**
     * @dev ERC20 contract being held = Diamond NXT (DNXT)
     */
    IERC20 public DNXT;
    /**
     * @dev Timestamp when token unlock logic begins = contract deployment timestamp
     */
    uint256 public startDate;
    /**
     * @dev Whether the locked addresses and amounts have been set
     */
    bool public set;
    /**
     * @dev Struct that holds the user data: locked and withdrawn tokens
     */
    struct User {
        uint256 locked;
        uint256 withdrawn;
    }
    /**
     * @dev Mapping of an address to a User struct
     */
    mapping(address => User) public userData;
    /**
     * @dev Event emitted when a user claims tokens
     */
    event Claimed(address indexed account, uint256 amount);
    /**
     * @dev Event emitted when the owner sets the addresses of the users with the corresponding amount of locked tokens
     */
    event AddressesSet(bool set);


    constructor () {
        DNXT = IERC20(0x0D74b7d0e373bA7E61758B0962f8F321Ac2b8387);
        startDate = block.timestamp;
    }

    /**
     * @dev Calculates and returns the proportion of tokens currently unlocked based on the elapsed time since the start date.
     * @return releasePercentage Percentage unlocked now
     */
    function unlocked() public view returns (uint256) {
        uint256 startRelease = startDate + 365 days;
        uint256 releasePercentage;
       
        if (block.timestamp <= startRelease + 91 days) {
            releasePercentage = 0;
        } else if (block.timestamp < startRelease + 182 days) {
            releasePercentage = 25;
        } else if (block.timestamp < startRelease + 274 days) {
            releasePercentage = 50;
        } else if (block.timestamp < startRelease + 365 days) {
            releasePercentage = 75;
        } else if (block.timestamp >= startRelease + 365 days) {
            releasePercentage = 100;
        }
        return releasePercentage;
    }

    /**
     * @dev An internal function that transfers the eligible amount of tokens to the specified beneficiary's account.
     */
    function _claim(address account) internal {
        uint256 withdrawable = availableToWithdraw(account);
        userData[account].withdrawn += withdrawable;
        DNXT.transfer(account, withdrawable);
        emit Claimed(account, withdrawable);
    }

    /**
     * @dev A public function that enables users to retrieve their accessible unlocked tokens.
     */
    function claim() public {
        _claim(msg.sender);
    }

    /**
     * @dev Determines the number of tokens an address can withdraw, calculated as the difference between the total unlocked tokens and the tokens already claimed.
     * @param account The user address
     */
    function availableToWithdraw(address account) public view returns (uint256) {
        return unlockedTotal(account) - claimedAmount(account);
    }

    /**
     * @dev Computes the total number of tokens that have been unlocked for a specific user address.
     * @param account The user address
     */
    function unlockedTotal(address account) public view returns (uint256) {
       
        return userData[account].locked * unlocked() / 100;
    }
    
    /**
     * @dev Retrieves the number of tokens locked for a specific user address.
     * @param account The user address
     */
    function lockedAmount(address account) public view returns (uint256) {
        return userData[account].locked;
    }
    
    /**
     * @dev Determines the number of tokens already claimed by a specific user address.
     * @param account The user address
     */
    function claimedAmount(address account) public view returns (uint256) {
        return userData[account].withdrawn;
    }
    
    /**
     * @dev Calculates the number of tokens yet to be claimed by a user address as the difference between locked and withdrawn tokens.
     * @param account The user address
     */
    function leftToClaim(address account) public view returns (uint256) {
        return userData[account].locked - userData[account].withdrawn;
    }

    /**
     * @dev Grants permission to the contract owner to assign an array of addresses and their corresponding locked token amounts. This function can be executed only once.
     * @param accounts Array of user addresses
     * @param amounts Array of user amounts
     */
    function setlockedAmounts(address[] memory accounts, uint256[] memory amounts) public onlyOwner {
        require(set == false, "Already set");
        set = true;
        for (uint256 i = 0; i < accounts.length; i++) {
            userData[accounts[i]].locked = amounts[i];
        }
        emit AddressesSet(true);
    }
}
