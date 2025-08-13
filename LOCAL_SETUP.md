# GMX Local Setup Guide

This guide will help you set up and run GMX contracts locally on your machine using Foundry and Anvil.

## Prerequisites

- Foundry (forge, anvil, cast)
- Node.js (for additional scripts if needed)

## Quick Start

### 1. Start Local Blockchain and Deploy Contracts

```bash
# Run the setup script
./scripts/setup_local.sh
```

This script will:
- Start Anvil local blockchain on port 8545
- Compile all contracts
- Deploy the entire GMX system
- Display contract addresses

### 2. Manual Setup (Alternative)

If you prefer to do it step by step:

```bash
# Start Anvil
anvil --port 8545 --host 0.0.0.0

# In another terminal, deploy contracts
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export RPC_URL=http://localhost:8545

forge build
forge script script/DeployGmx.s.sol:DeployGmx --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## Interacting with Contracts

### 1. Using Foundry Scripts

```bash
# Run the interaction script
forge script script/InteractGmx.s.sol:InteractGmx --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 2. Using Cast (Command Line)

```bash
# Check GMX balance
cast call <GMX_ADDRESS> "balanceOf(address)" <USER_ADDRESS> --rpc-url $RPC_URL

# Check vault state
cast call <VAULT_ADDRESS> "isInitialized()" --rpc-url $RPC_URL
```

### 3. Using Web3 Frontend

Connect your frontend to `http://localhost:8545` and use the contract addresses displayed after deployment.

## Contract Addresses

After deployment, you'll see addresses like:
- Vault: `0x5FbDB2315678afecb367f032d93F642f64180aa3`
- USDG: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`
- Router: `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`
- GMX: `0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9`
- GLP: `0xDc64a140Aa3E981100a9becA4E685f962f191277`

## Key Features Available

- **Vault**: Core trading vault with position management
- **Router**: Trading router for executing trades
- **PositionManager**: NFT-based position management
- **PositionRouter**: Order-based position management
- **OrderBook**: Limit order functionality
- **GlpManager**: GLP token management
- **Mock Tokens**: BNB, BTC, ETH, DAI, BUSD for testing
- **Price Feeds**: Mock price feeds for all tokens

## Testing Scenarios

1. **Deposit Collateral**: Use the vault to deposit tokens
2. **Open Positions**: Create long/short positions
3. **Swap Tokens**: Execute token swaps
4. **Manage GLP**: Mint/burn GLP tokens
5. **Check Fees**: View and understand fee structures

## Troubleshooting

### Common Issues

1. **Anvil not starting**: Make sure port 8545 is available
2. **Deployment fails**: Check if contracts compiled successfully
3. **Script errors**: Verify private key and RPC URL are set correctly

### Reset Local Chain

```bash
# Stop Anvil
pkill anvil

# Start fresh
./scripts/setup_local.sh
```

## Next Steps

Once you have the contracts deployed locally, you can:

1. Explore the contract code in `contracts/` directory
2. Run tests with `forge test`
3. Create custom interaction scripts
4. Build a frontend to interact with the contracts
5. Analyze the contract logic and security

## Useful Commands

```bash
# View contract source
forge inspect Vault

# Run specific tests
forge test --match-test testDeposit

# Get contract bytecode
cast code <CONTRACT_ADDRESS> --rpc-url $RPC_URL

# Call contract functions
cast call <CONTRACT_ADDRESS> "<FUNCTION_SIGNATURE>" <ARGS> --rpc-url $RPC_URL
``` 