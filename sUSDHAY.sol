// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title sUSDHAY - Savings/Staking Vault for USDHAY
/// @notice ERC4626 vault - deposit USDHAY, receive sUSDHAY shares
/// @dev Yield distributed by owner depositing rewards into vault
contract sUSDHAY is 
    Initializable, 
    ERC4626Upgradeable, 
    OwnableUpgradeable, 
    UUPSUpgradeable 
{
    uint256 public yieldRateBps;
    uint256 public lastYieldTimestamp;

    event YieldRateUpdated(uint256 newRate);
    event YieldDistributed(uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the vault
    /// @param _asset Address of the USDHAY token proxy
    /// @param initialOwner Address that will own the contract
    function initialize(IERC20 _asset, address initialOwner) public initializer {
        __ERC4626_init(IERC20(_asset));
        __ERC20_init("Savings USDHAY", "sUSDHAY");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        
        yieldRateBps = 500; // 5% APY default
        lastYieldTimestamp = block.timestamp;
    }

    /// @notice Update yield rate (only owner)
    function setYieldRate(uint256 _newRateBps) external onlyOwner {
        require(_newRateBps <= 10000, "Rate too high");
        yieldRateBps = _newRateBps;
        emit YieldRateUpdated(_newRateBps);
    }

    /// @notice Distribute yield - transfer USDHAY rewards to vault
    function distributeYield(uint256 amount) external {
        IERC20(asset()).transferFrom(msg.sender, address(this), amount);
        lastYieldTimestamp = block.timestamp;
        emit YieldDistributed(amount);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function decimals() public view override(ERC4626Upgradeable) returns (uint8) {
        return super.decimals();
    }
}
