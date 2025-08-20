# Compile contracts
echo "Compiling contracts..."
forge build

# Deploy contracts (with yes to continue on size warnings)
echo "Deploying GMX contracts to local chain..."
echo "Note: Some contracts may exceed size limits - this is normal for GMX contracts"
echo "y" | forge script script/DeployGmx.s.sol:DeployGmx --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --code-size-limit 10000000 -vvvv # Use 4000% of estimated gas

# Extract the latest Vault address from deployment
echo ""
echo "Extracting contract addresses..."
if [ -f "broadcast/DeployGmx.s.sol/31337/run-latest.json" ]; then
    # Get the latest Vault address (last one in the deployment)
    export VAULT=$(jq -r '.transactions[] | select(.contractName == "Vault") | .contractAddress' broadcast/DeployGmx.s.sol/31337/run-latest.json | tail -n 1)
    export USDG=$(jq -r '.transactions[] | select(.contractName == "USDG") | .contractAddress' broadcast/DeployGmx.s.sol/31337/run-latest.json | tail -n 1)
    export ROUTER=$(jq -r '.transactions[] | select(.contractName == "Router") | .contractAddress' broadcast/DeployGmx.s.sol/31337/run-latest.json | tail -n 1)
    export GMX=$(jq -r '.transactions[] | select(.contractName == "GMX") | .contractAddress' broadcast/DeployGmx.s.sol/31337/run-latest.json | tail -n 1)
    export GLP=$(jq -r '.transactions[] | select(.contractName == "GLP") | .contractAddress' broadcast/DeployGmx.s.sol/31337/run-latest.json | tail -n 1)
    
    echo "Latest contract addresses:"
    echo "  VAULT: $VAULT"
    echo "  USDG: $USDG"
    echo "  ROUTER: $ROUTER"
    echo "  GMX: $GMX"
    echo "  GLP: $GLP"
    
    # Output environment variables for sourcing
    echo ""
    echo "# Environment variables for sourcing:"
    echo "export VAULT=$VAULT"
    echo "export USDG=$USDG"
    echo "export ROUTER=$ROUTER"
    echo "export GMX=$GMX"
    echo "export GLP=$GLP"
    echo "export RPC_URL=$RPC_URL"
    echo "export PRIVATE_KEY=$PRIVATE_KEY"
else
    echo "Warning: Deployment file not found. Addresses not extracted."
fi

echo ""
echo "=== Setup Complete ==="
echo "You can now interact with the contracts using:"
echo "1. forge script script/InteractGmx.s.sol:InteractGmx --rpc-url $RPC_URL --private-key $PRIVATE_KEY"
echo "2. cast calls to contract addresses (e.g., cast call \$VAULT 'isInitialized()(bool)' --rpc-url $RPC_URL)"
echo "3. Web3 frontend connecting to $RPC_URL"
echo ""
echo "Contract addresses are set as environment variables above." 