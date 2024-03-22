// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/send/sendToken.sol"; // Ensure this path is correct
import "forge-std/Test.sol";
import "forge-std/console.sol"; // Import for logging outputs in tests

import "axelar/test/token/ERC20MintableBurnableInit.sol"; // Import for ERC20 token

import {InterchainTokenService} from "axelar-interchain/InterchainTokenService.sol";
import {ITokenManagerType} from "axelar-interchain/interfaces/ITokenManagerType.sol";

import "src/send/sendToken.sol";

contract SendTokenTest is Test {
    CustomToken public tknEth;
    CustomToken public tknPoly;

    uint256 public polygonForkId;
    uint256 public ethereumForkId;

    address public aliceEth = address(0x10);
    address public alicePoly = address(0x20);
    address public admin = address(0x30);

    // Setup method to initialize the test environment
    function setUp() public {
        // Create forks for Ethereum and Polygon chains for testing
        ethereumForkId = vm.createFork("eth");
        polygonForkId = vm.createFork("arbi");

        // Select the Ethereum fork and deploy the ERC20 token on Ethereum
        vm.selectFork(ethereumForkId);
        tknEth = new CustomToken("Ethereum STBC", "ESTBC");
        console.log("Token deployed on Ethereum at address: ", address(tknEth));
        tknEth.mint(aliceEth, 100e18); // Mint 100 tokens to Alice on Ethereum
        console.log("Tokens minted to Alice on Ethereum");
        deal(aliceEth, 10e18); // Provide Alice with some ETH for gas fees
    }

    function testDeployTokenManagerArbi() public {
        address interChainServiceAddr = 0xB5FB4BE02232B1bBA4dC8f81dc24C26980dE9e3C;
        InterchainTokenService(interChainServiceAddr).deployTokenManager(
            bytes32(bytes("usual")),
            "Polygon",
            ITokenManagerType.TokenManagerType.MINT_BURN,
            abi.encode(msg.sender, address(tknEth)),
            0.01e17
        );
    }

    function testDeployArbi() public {
        // Select the Polygon fork and deploy the ERC20 token on Polygon
        vm.selectFork(polygonForkId);
        tknPoly = new CustomToken("Polygon STBC", "PSTBC");

        console.log("Token deployed on Polygon at address: ", address(tknPoly));
    }

    // Test sending tokens from Ethereum to Polygon
    function testSendTokenEthToPolygon() public {
        testDeployArbi();
        vm.selectFork(ethereumForkId);
        vm.makePersistent(alicePoly);
        vm.makePersistent(address(tknPoly));
        vm.makePersistent(aliceEth);
        vm.makePersistent(address(tknEth));
        vm.makePersistent(0x468Ec52Cf31A524EA872FdBC27D0c23e677867D5);
        console.log("Alice's balance on Ethereum: ", tknEth.balanceOf(aliceEth));
        vm.selectFork(polygonForkId);
        console.log("Alice's balance on Polygon before transfer: ", tknPoly.balanceOf(alicePoly));

        vm.selectFork(ethereumForkId);

        bytes memory recipient = abi.encode(alicePoly);
        vm.prank(aliceEth);
        tknEth.interchainTransfer("Polygon", recipient, 10e18, "");

        console.log("Alice's balance on Ethereum after transfer: ", tknEth.balanceOf(aliceEth));
        vm.selectFork(polygonForkId);
        console.log("Alice's balance on Polygon after transfer: ", tknPoly.balanceOf(alicePoly));
    }
}
