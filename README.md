# DNXT Smart Contract Suite

A comprehensive suite of Ethereum-based smart contracts implementing ERC20 and ERC721 tokens with advanced compliance, access control, and vesting capabilities. This project focuses on creating a regulatory-compliant token ecosystem for tokenized diamond assets.

## Project Structure

```
├── DNXT.sol                 # Main ERC20 token implementation
├── DNFT.sol                 # NFT implementation for diamond certificates
├── Compliance.sol           # Compliance logic for transfers and operations
├── IComplianceRegistry.sol  # Interface for compliance registry
├── Whitelist.sol            # Implementation of whitelist functionality
├── access/                  # Access control implementations
├── token/                   # Base token implementations (ERC20, ERC721)
├── security/                # Security-related contracts
├── utils/                   # Utility functions and helpers
└── vesting/                 # Vesting contracts for token allocations
```

## Key Components
### DNXT Token (ERC20)
The DNXT token (`DNXT.sol`) is an ERC20-compatible token with additional functionalities:
- **Pausable operations**: Allows authorized roles to pause token transfers during emergencies
- **Role-based access control**: Implements OpenZeppelin's AccessControl for permission management
- **Burnable tokens**: Supports token burning to reduce total supply
- **ERC20Permit**: Enables gasless approvals using off-chain signatures (EIP-2612)
- **ERC20Votes**: Provides governance capabilities with delegation and voting power tracking
- **Compliance checks**: Ensures all transfers comply with regulatory requirements

Implementation highlights:
```solidity
contract DNXT is
    ERC20,
    ERC20Burnable,
    Pausable,
    AccessControl,
    ERC20Permit,
    ERC20Votes,
    Compliance
{
    // Contract implementation
}
```

### DNFT (ERC721)
The DNFT contract (`DNFT.sol`) is an NFT implementation specifically designed for diamond certificates with:
- **Detailed diamond attributes**: Stores cut, clarity, color, carat weight, shape, etc.
- **Certificate tracking**: Maintains a list of certificates for each diamond
- **Enumerable extension**: Enables on-chain token enumeration
- **URI storage**: Provides metadata for each token
- **Pausable operations**: Allows pausing token transfers
- **Role-based access control**: Manages permissions for minting, burning, etc.
- **Burnable capabilities**: Supports token burning
- **ERC2981 royalty**: Implements standard for royalty payments
- **Locking mechanism**: Allows tokens to be locked for additional security

Implementation highlights:
```solidity
contract DNFT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    AccessControl,
    ERC721Burnable,
    Compliance,
    ERC2981
{
    // Diamond attributes and functions
}
```

### Compliance System
The compliance system (`Compliance.sol`) ensures that all token transfers adhere to regulatory requirements:
- **Compliance registry integration**: Connects to external compliance verification
- **Transfer restrictions**: Verifies compliance for both ERC20 and ERC721 transfers
- **Per-token enforcement**: Allows enabling/disabling compliance on a per-token basis
- **Admin control**: Allows changing compliance settings and registry

Implementation highlights:
```solidity
contract Compliance is AccessControl {
    IComplianceRegistry public complianceRegistry;
    mapping(address => bool) public enforcedCompliance;
    
    // Compliance verification functions
}
```

### Whitelist Management
The whitelist contract (`Whitelist.sol`) implements address-based access control:
- **Whitelist/blacklist functionality**: Maintains lists of allowed/blocked addresses
- **Batch operations**: Supports adding multiple addresses at once
- **Role-based management**: Uses AccessControl for permission management
- **Events**: Emits events for all whitelist changes for transparency

### Vesting Contracts
Three vesting contract implementations for different allocation purposes:
- **VestingPrivate**: For private sale participants with customizable vesting schedules
- **VestingTeam**: For team token allocations with longer lockup periods
- **VestingTreasury**: For treasury management with controlled release schedules

Implementation highlights:
```solidity
// From VestingTeam.sol
function unlockedTotal(address account) public view returns (uint256) {
    return (userData[account].locked * unlocked()) / 1000;
}
```

## Technical Implementation Details

### Access Control
The project uses OpenZeppelin's AccessControl for role-based permissions:
- **DEFAULT_ADMIN_ROLE**: Can grant/revoke all other roles
- **PAUSER_ROLE**: Can pause/unpause token transfers
- **MINTER_ROLE**: Can mint new tokens
- **BURNER_ROLE**: Can burn tokens
- **WHITELISTER_ROLE**: Can manage whitelist entries
- **ATTRIBUTE_ROLE**: Can set diamond attributes (in DNFT)
- **ROYALTIES_ROLE**: Can set royalty information (in DNFT)

### Upgradeability
The contracts are not upgradeable by design to ensure immutability of the core token logic. Compliance requirements are handled through the external compliance registry that can be updated.

### Diamond Certificate Management
DNFT includes a comprehensive data structure for storing diamond information:
```solidity
struct Diamond {
    string cut;
    string clarity;
    string color;
    uint256 caratWeight;
    string shape;
    string symmetry;
    string fluorescence;
    string polish;
    Certificate[] certificates;
}
```

## Setup and Deployment on Ethereum Sepolia Testnet

### Prerequisites
- Solidity ^0.8.9
- Hardhat or Truffle for deployment
- OpenZeppelin libraries
- MetaMask with Sepolia testnet configured
- ETH tokens for the Sepolia testnet (from [Sepolia Faucet](https://sepoliafaucet.com/))

### Deployment Steps

1. **Setup Environment**

   Install Hardhat and dependencies:
   ```bash
   npm install --save-dev hardhat @nomiclabs/hardhat-waffle @nomiclabs/hardhat-ethers ethers solidity-coverage
   npx hardhat init
   ```

2. **Configure Hardhat for Ethereum Sepolia**

   Update `hardhat.config.js`:
   ```javascript
   require("@nomiclabs/hardhat-waffle");
   require("dotenv").config();

   module.exports = {
     solidity: "0.8.9",
     networks: {
       sepolia: {
         url: "https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID",
         accounts: [process.env.PRIVATE_KEY],
         chainId: 11155111
       }
     }
   };
   ```

3. **Create Deployment Scripts**

   Create `scripts/deploy.js`:
   ```javascript
   async function main() {
     // Deploy Whitelist
     const Whitelist = await ethers.getContractFactory("Whitelist");
     const admin = "0x..."; // Admin address
     const whitelist = await Whitelist.deploy(admin, admin);
     await whitelist.deployed();
     console.log("Whitelist deployed to:", whitelist.address);

     // Deploy Compliance Registry (IComplianceRegistry implementation)
     // Note: This would require an actual implementation of the compliance registry

     // For this example, assume complianceRegistry is deployed at:
     const complianceRegistryAddress = "0x..."; 

     // Deploy DNXT
     const DNXT = await ethers.getContractFactory("DNXT");
     const dnxt = await DNXT.deploy(complianceRegistryAddress);
     await dnxt.deployed();
     console.log("DNXT deployed to:", dnxt.address);

     // Deploy DNFT
     const DNFT = await ethers.getContractFactory("DNFT");
     const dnft = await DNFT.deploy(complianceRegistryAddress);
     await dnft.deployed();
     console.log("DNFT deployed to:", dnft.address);

     // Deploy Vesting contracts if needed
   }

   main()
     .then(() => process.exit(0))
     .catch((error) => {
       console.error(error);
       process.exit(1);
     });
   ```

4. **Deploy to Ethereum Sepolia Testnet**

   ```bash
   npx hardhat run scripts/deploy.js --network sepolia
   ```

5. **Verify on Etherscan**

   After deployment, verify your contracts on Etherscan for transparency:
   ```bash
   npx hardhat verify --network sepolia <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
   ```

### Interacting with Deployed Contracts

Once deployed, you can interact with your contracts through:

1. **MetaMask + Web Interface**: Build a frontend to interact with your contracts
2. **Hardhat Console**: Use the Hardhat console for direct interaction
   ```bash
   npx hardhat console --network sepolia
   ```
   Example interactions:
   ```javascript
   const DNXT = await ethers.getContractAt("DNXT", "0x...");
   const balance = await DNXT.balanceOf("0x...");
   console.log("Balance:", ethers.utils.formatUnits(balance, 18));
   ```

## Security Considerations
- All contracts implement access control for sensitive functions
- Pausable functionality for emergency situations
- Compliance checks prevent unauthorized transfers
- ERC20Permit uses EIP-712 for secure, gasless approvals
- Token locking for additional security in DNFT
- Batch functions use safe iteration limits

## Compliance and Regulatory Aspects
The project is designed with regulatory compliance in mind:
- Whitelist/blacklist for KYC/AML compliance
- External compliance registry for additional checks
- Configurable compliance enforcement per token
- Role separation for administrative functions

## Testing
Test the contracts using Hardhat's testing framework:
```bash
npx hardhat test
```

## References and Citations
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) - Used for standard implementations of ERC20, ERC721, AccessControl, etc.
- [EIP-2612: Permit Extension for ERC20](https://eips.ethereum.org/EIPS/eip-2612)
- [EIP-2981: NFT Royalty Standard](https://eips.ethereum.org/EIPS/eip-2981)
- [Ethereum Sepolia Documentation](https://sepolia.dev/)
