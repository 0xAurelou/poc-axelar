// SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

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
    }
}
