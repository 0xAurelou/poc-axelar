// SPDX-License-Identifier:MIT

pragma solidity 0.8.20;

import {ERC20CrossChain} from "src/ERC20CrossChain.sol";

import "forge-std/Script.sol";

contract crossChainDeployment is Script {
    ERC20CrossChain public erc20CrossChain;
    address public alice;
    uint256 public constant polygonId = 137;
    uint256 public constant ethereumId = 1;
    uint256 public polygonForkId;
    uint256 public ethereumForkId;

    function run() public {
        ethereumForkId = vm.createFork("eth");
        polygonForkId = vm.createFork("polygon");
        vm.selectFork(ethereumForkId);
        erc20CrossChain = new ERC20CrossChain(
            // Gateway address on ethereum
            address(0x4F4495243837681061C4743b74B3eEdf548D56A5),
            // Gas receiver address on ethereum
            address(0x2d5d7d31F671F86C782533cc367F14109a082712),
            18
        );
        console.log("ERC20CrossChain address on ethereum: %s", address(erc20CrossChain));
    }
}
