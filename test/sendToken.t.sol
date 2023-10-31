// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "src/send/sendToken.sol";
import "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract myERC20 is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}

contract SendTokenTest is Test {
    myERC20 public tknEth;
    myERC20 public tknPoly;

    SendToken public erc20CrossChainEth;
    SendToken public erc20CrossChainPoly;

    uint256 public polygonForkId;
    uint256 public ethereumForkId;

    address public aliceEth = address(0x10);
    address public alicePoly = address(0x20);

    address public admin = address(0x30);

    function setUp() public {
        tknEth = new myERC20("Ethereum STBC", "ESTBC");
        tknPoly = new myERC20("Polygon STBC", "PSTBC");
        ethereumForkId = vm.createFork("eth");
        polygonForkId = vm.createFork("polygon");
        vm.selectFork(ethereumForkId);
        erc20CrossChainEth = new SendToken(
            // Gateway address on ethereum
            address(0x4F4495243837681061C4743b74B3eEdf548D56A5),
            // Gas receiver address on ethereum
            address(tknEth),
            admin
        );
        console.log("ERC20CrossChain address on ethereum: %s", address(erc20CrossChainEth));
        assertTrue(address(erc20CrossChainEth) != address(0), "Fail Deployment");
        vm.selectFork(polygonForkId);
        erc20CrossChainPoly = new SendToken(
            // Gateway address on polygon
            address(0x6f015F16De9fC8791b234eF68D486d2bF203FBA8),
            // Gas receiver address on polygon
            address(tknPoly),
            admin
        );
        console.log("ERC20CrossChain address on polygon: %s", address(erc20CrossChainPoly));
    }

    function mintTokenEth() public {
        vm.prank(aliceEth);
        tknEth.mint(100e18);
        deal(aliceEth, 10e18);
        tknEth.approve(address(erc20CrossChainEth), 100e18);
    }

    function testSendTokenEthToPolygon() public {
        mintTokenEth();
        vm.prank(aliceEth);
        erc20CrossChainEth.send("ESTBC", 100e18, "0x20", "Polygon");
    }
}
