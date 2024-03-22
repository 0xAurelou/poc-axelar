// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "src/ERC20CrossChain.sol";
import "forge-std/Test.sol";

contract ERC20CrossChainTest is Test {
    ERC20CrossChain public erc20CrossChainEth;
    ERC20CrossChain public erc20CrossChainPoly;
    address public aliceEth = address(0x10);
    address public alicePoly = address(0x20);
    uint256 public constant polygonId = 137;
    uint256 public constant ethereumId = 1;
    uint256 public polygonForkId;
    uint256 public ethereumForkId;

    function setUp() public {
        ethereumForkId = vm.createFork("eth");
        polygonForkId = vm.createFork("arbi");
        vm.selectFork(ethereumForkId);
        erc20CrossChainEth = new ERC20CrossChain(
            // Gateway address on ethereum
            address(0x4F4495243837681061C4743b74B3eEdf548D56A5),
            // Gas receiver address on ethereum
            address(0x2d5d7d31F671F86C782533cc367F14109a082712),
            18
        );
        console.log("ERC20CrossChain address on ethereum: %s", address(erc20CrossChainEth));
        assertTrue(address(erc20CrossChainEth) != address(0), "Fail Deployment");
        vm.selectFork(polygonForkId);
        erc20CrossChainPoly = new ERC20CrossChain(
            // Gateway address on polygon
            address(0x6f015F16De9fC8791b234eF68D486d2bF203FBA8),
            // Gas receiver address on polygon
            address(0x2d5d7d31F671F86C782533cc367F14109a082712),
            18
        );

        console.log("ERC20CrossChain address on polygon: %s", address(erc20CrossChainPoly));
        assertTrue(address(erc20CrossChainPoly) != address(0), "Fail Deployment");
    }

    function testSetUp() public {
        vm.selectFork(ethereumForkId);
        assertTrue(address(erc20CrossChainEth) != address(0), "Fail Deployment");
        assertEq(erc20CrossChainEth.name(), "Ethereum STBC", "Fail name");
        assertEq(erc20CrossChainEth.symbol(), "ESTBC", "Fail symbol");
    }

    function mintTokenEth() public {
        vm.prank(aliceEth);
        erc20CrossChainEth.giveMe(100e18);
        deal(aliceEth, 10e18);
    }

    function testTransferRemote() public {
        vm.selectFork(ethereumForkId);
        mintTokenEth();
        console2.log("aliceEth balance: %s", erc20CrossChainEth.balanceOf(aliceEth));
        console2.log("alicePoly balance: %s", erc20CrossChainEth.balanceOf(alicePoly));
        vm.prank(aliceEth);
        erc20CrossChainEth.transferRemote{value: 10e18}("Polygon", alicePoly, 100e18);
        assertEq(erc20CrossChainEth.balanceOf(aliceEth), 0, "Fail balance Ethereum");
        console2.log("aliceEth balance: %s", erc20CrossChainEth.balanceOf(aliceEth));
        vm.selectFork(polygonForkId);
        console2.log("alicePoly balance: %s", erc20CrossChainPoly.balanceOf(alicePoly));
        console2.log(erc20CrossChainPoly.balanceOf(address(erc20CrossChainEth)));
        assertTrue(erc20CrossChainPoly.balanceOf(alicePoly) > 0, "Fail balance Polygon ");
    }
}
