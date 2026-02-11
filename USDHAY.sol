// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title USDHAY Token - Upgradeable ERC20
/// @notice Main stablecoin token with mint/burn/pause capabilities
/// @dev Uses UUPS proxy pattern for upgradeability
contract USDHAY is 
    Initializable, 
    ERC20Upgradeable, 
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    OwnableUpgradeable, 
    UUPSUpgradeable 
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the token (called once via proxy)
    /// @param initialOwner Address that will own the contract
    function initialize(address initialOwner) public initializer {
        __ERC20_init("USDHAY", "USDHAY");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    /// @notice Mint new tokens (only owner)
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @notice Pause all token transfers
    function pause() public onlyOwner {
        _pause();
    }

    /// @notice Unpause token transfers
    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _update(address from, address to, uint256 value) 
        internal 
        override(ERC20Upgradeable, ERC20PausableUpgradeable) 
    {
        super._update(from, to, value);
    }
}
