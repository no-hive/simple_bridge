pragma solidity ^0.8.33;

import {Bridge} from "src/bridge_contract.sol";
import {FederationSync} from "src/federation_contract.sol";
import "forge-std/Test.sol";

contract BridgeTest is Test {
    Bridge public bridge;
    FederationSync public federationSync;

    address TEST_TOKEN = 0x0000000000000000000000000000000000000000;

    address TEST_NODE_1 = 0x0000000000000000000000000000000000000000;
    address TEST_NODE_2 = 0x0000000000000000000000000000000000000000;
    address TEST_NODE_3 = 0x0000000000000000000000000000000000000000;

    function setUp() public {
        bridge = new Bridge(TEST_TOKEN);
        address bridge_address = address(bridge);
        federationSync = new FederationSync(TEST_NODE_1, TEST_NODE_2, TEST_NODE_3, bridge_address);
    }
}
