
# DNXT Smart Contract Suite

A comprehensive suite of Ethereum-based smart contracts implementing ERC20 and ERC721 tokens with advanced compliance, access control, and vesting capabilities.

## Project Structure

```
├── DNXT.sol                 # Main ERC20 token implementation
├── DNFT.sol                 # NFT implementation with compliance features
├── Compliance.sol           # Compliance logic for transfers and operations
├── IComplianceRegistry.sol  # Interface for compliance registry
├── Whitelist.sol            # Implementation of whitelist functionality
├── access/                  # Access control implementations
├── token/                   # Base token implementations (ERC20, ERC721)
├── security/                # Security-related contracts
├── utils/                   # Utility functions and helpers
└── vesting/                 # Token vesting implementations
```

## Key Components

### DNXT Token (ERC20)
The DNXT token is an ERC20-compatible token with additional functionalities:
- Pausable operations
- Role-based access control
- Burnable tokens
- ERC20Permit for gasless approvals
- ERC20Votes for governance capabilities
- Compliance checks for transfers

### DNFT (ERC721)
The DNFT is an NFT implementation with:
- Enumerable extension for on-chain tracking
- URI storage for metadata
- Pausable operations
- Role-based access control
- Burnable capabilities
- ERC2981 royalty standard support
- Compliance for transfers

### Compliance System
The compliance system ensures that all token transfers adhere to regulatory requirements:
- Whitelist-based transfers
- Compliance registry integration
- Transfer restrictions based on roles and statuses

### Vesting Contracts
Three vesting contract implementations:
- VestingPrivate: For private sale participants
- VestingTeam: For team token allocations
- VestingTreasury: For treasury management

## Setup and Deployment

### Prerequisites
- Solidity ^0.8.9
- Hardhat or Truffle for deployment
- OpenZeppelin libraries

### Deployment Steps
1. Deploy Compliance and Whitelist contracts
2. Deploy DNXT token contract
3. Deploy DNFT contract
4. Configure roles and permissions
5. Setup vesting contracts if needed

## Security Considerations
- All contracts implement access control for sensitive functions
- Pausable functionality for emergency situations
- Compliance checks prevent unauthorized transfers
- ERC20Permit uses EIP-712 for secure, gasless approvals

## License
[Specify your license here]

## Contact
[Your contact information]
