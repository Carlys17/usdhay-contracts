// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./USDHAY.sol";
import "./sUSDHAY.sol";

/// @notice Deploys USDHAY (proxy + impl), then sUSDHAY vault pointing at it.
contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address owner = vm.envOr("OWNER", msg.sender);

        vm.startBroadcast(pk);

        // 1. USDHAY implementation
        USDHAY usdhayImpl = new USDHAY();
        console.log("USDHAY impl       :", address(usdhayImpl));

        // 2. ERC1967 proxy pointing at the impl, calling initialize(owner)
        bytes memory initData = abi.encodeWithSelector(USDHAY.initialize.selector, owner);
        ERC1967Proxy usdhayProxy = new ERC1967Proxy(address(usdhayImpl), initData);
        console.log("USDHAY proxy     :", address(usdhayProxy));

        // 3. sUSDHAY implementation
        sUSDHAY savImpl = new sUSDHAY();
        console.log("sUSDHAY impl      :", address(savImpl));

        // 4. sUSDHAY proxy, init with USDHAY as the underlying asset
        bytes memory savData = abi.encodeWithSelector(
            sUSDHAY.initialize.selector,
            IERC20(address(usdhayProxy)),
            owner
        );
        ERC1967Proxy savProxy = new ERC1967Proxy(address(savImpl), savData);
        console.log("sUSDHAY proxy    :", address(savProxy));

        vm.stopBroadcast();
    }
}
