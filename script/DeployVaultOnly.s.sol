// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "forge-std/Script.sol";
import "../contracts/core/Vault.sol";

contract DeployVaultOnly is Script {
    function run() external {
        // Use the default Anvil private key
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(deployerPrivateKey);

        console.log("=== Deploying Vault Contract Only ===");
        
        // Deploy only the Vault contract
        Vault vault = new Vault();
        
        console.log("Vault deployed at:", address(vault));
        
        vm.stopBroadcast();
        
        console.log("=== Vault Deployment Complete ===");
    }
} 