// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "forge-std/Script.sol";
import "../contracts/gmx/GMX.sol";
import "../contracts/gmx/GLP.sol";
import "../contracts/core/Vault.sol";
import "../contracts/core/Router.sol";
import "../contracts/core/VaultPriceFeed.sol";
import "../contracts/core/GlpManager.sol";
import "../contracts/core/PositionManager.sol";
import "../contracts/tokens/USDG.sol";
import "../contracts/tokens/Token.sol";

contract InteractGmx is Script {
    // Contract addresses - you'll need to update these after deployment
    address constant VAULT_ADDR = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address constant USDG_ADDR = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;
    address payable constant ROUTER_ADDR = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;
    address constant GMX_ADDR = 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9;
    address constant GLP_ADDR = 0xdc64A140AA3E981100A9bECA4e685F962f191277;
    address constant GLP_MANAGER_ADDR = 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707;
    address payable constant POSITION_MANAGER_ADDR = 0x0165878A594ca255338adfa4d48449f69242Eb8F;
    
    // Mock tokens
    address constant BNB_ADDR = 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6;
    address constant BTC_ADDR = 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318;
    address constant ETH_ADDR = 0x610178dA211FEF7D417bC0e6FeD39F05609AD788;
    address constant DAI_ADDR = 0xb7f8bc63BbCad18155201308C8F3540b07F87fdD;
    address constant BUSD_ADDR = 0xA0B86A33e6441B8c4C3132E3c5e9598C7088E77a;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        console.log("=== GMX Contract Interaction ===");
        
        // Get contract instances
        Vault vault = Vault(VAULT_ADDR);
        USDG usdg = USDG(USDG_ADDR);
        Router router = Router(ROUTER_ADDR);
        GMX gmx = GMX(GMX_ADDR);
        GLP glp = GLP(GLP_ADDR);
        GlpManager glpManager = GlpManager(GLP_MANAGER_ADDR);
        PositionManager positionManager = PositionManager(POSITION_MANAGER_ADDR);
        
        // Example interactions
        console.log("Vault address:", address(vault));
        console.log("USDG address:", address(usdg));
        console.log("Router address:", address(router));
        
        // Check vault state
        console.log("Vault is initialized:", vault.isInitialized());
        console.log("Vault router:", vault.router());
        console.log("Vault USDG:", vault.usdg());
        
        // Check token balances
        address user = vm.addr(privateKey);
        console.log("User address:", user);
        console.log("User GMX balance:", gmx.balanceOf(user));
        console.log("User GLP balance:", glp.balanceOf(user));
        console.log("User USDG balance:", usdg.balanceOf(user));
        
        // Example: Mint some GMX tokens to user
        console.log("Minting 1000 GMX to user...");
        gmx.mint(user, 1000 * 1e18);
        console.log("New GMX balance:", gmx.balanceOf(user));
        
        // Example: Check vault fees for a specific token
        uint256 feeReserves = vault.feeReserves(BNB_ADDR);
        console.log("Vault fee reserves for BNB:", feeReserves);
        
        vm.stopBroadcast();
    }
} 