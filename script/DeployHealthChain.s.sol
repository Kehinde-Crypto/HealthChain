// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/SupplyChain.sol";

contract DeployHealthChain is Script {
  function setUp() public {}

  function run() public {
    vm.startBroadcast();
    // Set the correct price feed address here
    address _priceFeedAddress = address(0x1234567890123456789012345678901234567890);
    new SupplyChain(_priceFeedAddress);
    vm.stopBroadcast();
  }
}