// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "forge-std/Script.sol";
import "../contracts/gmx/GMX.sol";
import "../contracts/gmx/GLP.sol";
import "../contracts/core/Vault.sol";
import "../contracts/core/Router.sol";
import "../contracts/core/VaultPriceFeed.sol";
import "../contracts/core/VaultUtils.sol";
import "../contracts/core/VaultErrorController.sol";
import "../contracts/core/GlpManager.sol";
import "../contracts/core/PositionManager.sol";
import "../contracts/core/PositionRouter.sol";
import "../contracts/core/OrderBook.sol";
import "../contracts/core/ShortsTracker.sol";
import "../contracts/tokens/USDG.sol";
import "../contracts/tokens/Token.sol";
import "../contracts/oracle/PriceFeed.sol";
import "../contracts/core/interfaces/IVault.sol";
import "../contracts/core/interfaces/IVaultUtils.sol";

contract DeployGmx is Script {
    // Core contracts
    Vault public vault;
    USDG public usdg;
    Router public router;
    VaultPriceFeed public vaultPriceFeed;
    VaultUtils public vaultUtils;
    VaultErrorController public vaultErrorController;
    
    // GMX tokens
    GMX public gmx;
    GLP public glp;
    GlpManager public glpManager;
    
    // Position management
    PositionManager public positionManager;
    PositionRouter public positionRouter;
    OrderBook public orderBook;
    ShortsTracker public shortsTracker;
    
    // Mock tokens for testing
    Token public bnb;
    Token public btc;
    Token public eth;
    Token public dai;
    Token public busd;
    
    // Price feeds
    PriceFeed public bnbPriceFeed;
    PriceFeed public btcPriceFeed;
    PriceFeed public ethPriceFeed;
    PriceFeed public daiPriceFeed;
    PriceFeed public busdPriceFeed;

    function run() external {
        // Use the default Anvil private key
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(deployerPrivateKey);

        console.log("=== Deploying GMX System to Local Chain ===");
        
        // Deploy mock tokens
        deployMockTokens();
        
        // Deploy price feeds
        deployPriceFeeds();
        
        // Deploy core contracts
        deployCoreContracts(); // Remove the pre-deployed vault parameter
        
        // Deploy GMX tokens
        deployGmxTokens();
        
        // Deploy position management contracts
        deployPositionContracts();
        
        // Initialize the system
        initializeSystem();
        
        // Configure the system
        configureSystem();
        
        vm.stopBroadcast();
        
        // Print deployment summary
        printDeploymentSummary();
    }

    function deployMockTokens() internal {
        console.log("Deploying mock tokens...");
        
        bnb = new Token();
        btc = new Token();
        eth = new Token();
        dai = new Token();
        busd = new Token();
        
        console.log("BNB Token:", address(bnb));
        console.log("BTC Token:", address(btc));
        console.log("ETH Token:", address(eth));
        console.log("DAI Token:", address(dai));
        console.log("BUSD Token:", address(busd));
    }

    function deployPriceFeeds() internal {
        console.log("Deploying price feeds...");
        
        bnbPriceFeed = new PriceFeed();
        btcPriceFeed = new PriceFeed();
        ethPriceFeed = new PriceFeed();
        daiPriceFeed = new PriceFeed();
        busdPriceFeed = new PriceFeed();
        
        // Set some mock prices
        bnbPriceFeed.setLatestAnswer(300 * 1e8); // $300
        btcPriceFeed.setLatestAnswer(60000 * 1e8); // $60,000
        ethPriceFeed.setLatestAnswer(2000 * 1e8); // $2,000
        daiPriceFeed.setLatestAnswer(1 * 1e8); // $1
        busdPriceFeed.setLatestAnswer(1 * 1e8); // $1
        
        console.log("Price feeds deployed and configured");
    }

    function deployCoreContracts() internal {
        console.log("Deploying core contracts...");
        
        // Deploy a new Vault contract
        vault = new Vault();
        usdg = new USDG(address(vault));
        router = new Router(address(vault), address(usdg), address(bnb));
        vaultPriceFeed = new VaultPriceFeed();
        vaultUtils = new VaultUtils(IVault(address(vault)));
        vaultErrorController = new VaultErrorController();
        
        console.log("Vault:", address(vault));
        console.log("USDG:", address(usdg));
        console.log("Router:", address(router));
        console.log("VaultPriceFeed:", address(vaultPriceFeed));
    }

    function deployGmxTokens() internal {
        console.log("Deploying GMX tokens...");
        
        gmx = new GMX();
        glp = new GLP();
        shortsTracker = new ShortsTracker(address(vault));
        glpManager = new GlpManager(
            address(vault),
            address(usdg),
            address(glp),
            address(shortsTracker),
            24 * 60 * 60 // cooldown duration
        );
        
        console.log("GMX:", address(gmx));
        console.log("GLP:", address(glp));
        console.log("ShortsTracker:", address(shortsTracker));
        console.log("GlpManager:", address(glpManager));
    }

    function deployPositionContracts() internal {
        console.log("Deploying position management contracts...");
        
        orderBook = new OrderBook();
        positionManager = new PositionManager(
            address(vault),
            address(router),
            address(shortsTracker),
            address(bnb),
            0, // depositFee
            address(orderBook)
        );
        
        positionRouter = new PositionRouter(
            address(vault),
            address(router),
            address(bnb),
            address(shortsTracker),
            500000, // minExecutionFee
            500000  // minExecutionFee
        );
        
        console.log("OrderBook:", address(orderBook));
        console.log("PositionManager:", address(positionManager));
        console.log("PositionRouter:", address(positionRouter));
    }

    function initializeSystem() internal {
        console.log("Initializing system...");
        
        // Initialize vault
        vault.initialize(
            address(router),
            address(usdg),
            address(vaultPriceFeed),
            2 * 1e30, // liquidationFeeUsd
            100, // fundingRateFactor
            100  // stableFundingRateFactor
        );
        
        // Set vault utils and error controller
        vault.setVaultUtils(IVaultUtils(address(vaultUtils)));
        vault.setErrorController(address(vaultErrorController));
        
        // Configure price feeds
        vaultPriceFeed.setTokenConfig(address(bnb), address(bnbPriceFeed), 8, false);
        vaultPriceFeed.setTokenConfig(address(btc), address(btcPriceFeed), 8, false);
        vaultPriceFeed.setTokenConfig(address(eth), address(ethPriceFeed), 8, false);
        vaultPriceFeed.setTokenConfig(address(dai), address(daiPriceFeed), 8, false);
        vaultPriceFeed.setTokenConfig(address(busd), address(busdPriceFeed), 8, false);
        
        // Initialize GLP
        glp.setMinter(address(glpManager), true);
        usdg.addVault(address(glpManager));
        
        // Set up shorts tracker
        shortsTracker.setIsGlobalShortDataReady(true);
        shortsTracker.setHandler(address(positionRouter), true);
        
        console.log("System initialized");
    }

    function configureSystem() internal {
        console.log("Configuring system...");
        
        // Set vault fees
        vault.setFees(
            10, // taxBasisPoints
            5,  // stableTaxBasisPoints
            20, // mintBurnFeeBasisPoints
            20, // swapFeeBasisPoints
            1,  // stableSwapFeeBasisPoints
            10, // marginFeeBasisPoints
            2 * 1e30, // liquidationFeeUsd
            24 * 60 * 60, // minProfitTime
            true // hasDynamicFees
        );
        
        // Set vault mode
        vault.setInManagerMode(true);
        vault.setManager(address(glpManager), true);
        
        // Configure GLP manager
        glpManager.setInPrivateMode(true);
        glp.setInPrivateTransferMode(true);
        
        console.log("System configured");
    }

    function printDeploymentSummary() internal view {
        console.log("\n=== GMX Deployment Summary ===");
        console.log("Core Contracts:");
        console.log("  Vault:", address(vault));
        console.log("  USDG:", address(usdg));
        console.log("  Router:", address(router));
        console.log("  VaultPriceFeed:", address(vaultPriceFeed));
        
        console.log("\nGMX Tokens:");
        console.log("  GMX:", address(gmx));
        console.log("  GLP:", address(glp));
        console.log("  GlpManager:", address(glpManager));
        
        console.log("\nPosition Management:");
        console.log("  PositionManager:", address(positionManager));
        console.log("  PositionRouter:", address(positionRouter));
        console.log("  OrderBook:", address(orderBook));
        console.log("  ShortsTracker:", address(shortsTracker));
        
        console.log("\nMock Tokens:");
        console.log("  BNB:", address(bnb));
        console.log("  BTC:", address(btc));
        console.log("  ETH:", address(eth));
        console.log("  DAI:", address(dai));
        console.log("  BUSD:", address(busd));
        
        console.log("\n=== Ready for Manual Interaction ===");
        console.log("You can now interact with these contracts using:");
        console.log("1. Foundry scripts");
        console.log("2. Hardhat console");
        console.log("3. Web3 frontend");
        console.log("4. Direct contract calls");
    }
} 