// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../USDHAY.sol";
import "../sUSDHAY.sol";

contract USDHAYTest is Test {
    USDHAY public token;
    address alice = address(0xA11CE);

    function setUp() public {
        USDHAY impl = new USDHAY();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl), abi.encodeWithSelector(USDHAY.initialize.selector, address(this))
        );
        token = USDHAY(address(proxy));
    }

    function test_init() public {
        assertEq(token.name(), "USDHAY");
        assertEq(token.symbol(), "USDHAY");
        assertEq(token.owner(), address(this));
    }

    function test_mintBurn() public {
        token.mint(alice, 1000 ether);
        assertEq(token.balanceOf(alice), 1000 ether);
        vm.prank(alice);
        token.burn(400 ether);
        assertEq(token.balanceOf(alice), 600 ether);
    }

    function test_pause() public {
        token.mint(alice, 1000 ether);
        token.pause();
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(address(0xB0B), 1 ether);
    }
}

contract sUSDHAYTest is Test {
    USDHAY public usd;
    sUSDHAY public sav;
    address alice = address(0xA11CE);

    function setUp() public {
        USDHAY u = new USDHAY();
        ERC1967Proxy p1 = new ERC1967Proxy(
            address(u), abi.encodeWithSelector(USDHAY.initialize.selector, address(this))
        );
        usd = USDHAY(address(p1));
        sUSDHAY s = new sUSDHAY();
        ERC1967Proxy p2 = new ERC1967Proxy(
            address(s), abi.encodeWithSelector(sUSDHAY.initialize.selector, IERC20(address(usd)), address(this))
        );
        sav = sUSDHAY(address(p2));
        usd.mint(alice, 10_000 ether);
    }

    function test_depositAndYield() public {
        vm.startPrank(alice);
        usd.approve(address(sav), 1_000 ether);
        uint256 shares = sav.deposit(1_000 ether, alice);
        assertGt(shares, 0);
        // distribute 100 USDHAY as yield
        vm.stopPrank();
        usd.mint(address(this), 100 ether);
        usd.approve(address(sav), 100 ether);
        sav.distributeYield(100 ether);
        // share value should now be higher
        uint256 out = sav.redeem(sav.balanceOf(alice), alice, alice);
        assertGt(out, 1_000 ether);
    }
}
