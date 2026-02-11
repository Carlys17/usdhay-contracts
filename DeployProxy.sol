// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @notice Helper to deploy ERC1967Proxy in Remix
/// @dev After compiling, select "ERC1967Proxy" from the contract dropdown
contract DeployProxy is ERC1967Proxy {
    constructor(address implementation, bytes memory _data) 
        ERC1967Proxy(implementation, _data) 
    {}
}
