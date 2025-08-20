#!/bin/bash

# GMX Local Setup Script
echo "=== GMX Local Setup ==="

# Check if Anvil is running
if ! pgrep -x "anvil" > /dev/null; then
    echo "Starting Anvil local blockchain..."
    anvil --port 8545 --host 0.0.0.0 --gas-limit 100000000000000 &
    ANVIL_PID=$!
    echo "Anvil started with PID: $ANVIL_PID"
    sleep 2
else
    echo "Anvil is already running"
fi

# Set environment variables
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export RPC_URL=http://localhost:8545

echo "Environment variables set:"
echo "  PRIVATE_KEY: $PRIVATE_KEY"
echo "  RPC_URL: $RPC_URL"