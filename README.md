## Note: This code is NOT secure - DONT use in production

# NotOpenSea (NFT Marketplace)

- Address  : 0xc572beeb724c5b20e67b3b8f8d8a8a8fd6301fee
- Testnet  : Sepolia         
- Block No : 4394122 (contract creation)
- link     : https://sepolia.etherscan.io/address/0xc572beeb724c5b20e67b3b8f8d8a8a8fd6301fee
- MP Owner : 0x01e07A5371035BeC2A86e1Ff9eaAC6b002edB102

## Marketplace Features
Its a simple NFT Marketplace with limited features

- sellers can list their NFT above the **minimum floor of 0.05 eth** set by the marketplace - during initial listing
- The NFT uploaded by the user is hosted on IPFS using pinata - the tokenURI is mapped to the tokenId 
- sellers pay an initial **fixed fee of 0.005 eth** upon listing
- sellers can **change the listing status** (list or unlist) anytime they want
- sellers can **change the listing price** anytime they want
- sellers **pay a fixed royalty 0.005 eth** when their NFT is bought 

- marketplace **owner can withdraw** the eth to any address they want
- marketplace **owner can update the royalty** anytime they want

- NFT owners can view their collected NFTs (when front-end is integrated)
- marketplace users can view all NFTs available on the market (when front-end is integrated)


## File Layout

- License statement 
- Pragma statements
- Import Statements 
- Contracts

## Contract Layout

- Type declarations
- State variables
- Errors
- Events
- Modifiers
- Functions ( External, public, private, view)
