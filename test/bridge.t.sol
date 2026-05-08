pragma solidity ^0.8.33;

import {Bridge} from "src/bridge_contract.sol";
import {FederationSync} from "src/federation_contract.sol";
import "forge-std/Test.sol";

contract BridgeTest is Test {
    Bridge public bridge;
    FederationSync public federationSync;

// test addreses
    address TEST_TOKEN = address(1);
    address TEST_NODE_1 = address(2);
    address TEST_NODE_2 = address(3);
    address TEST_NODE_3 = address(4);
    address OWNER = address(5);

    function setUp() public {
        vm.startPrank(OWNER);
        bridge = new Bridge(TEST_TOKEN);
        address bridge_address = address(bridge);
        federationSync = new FederationSync(TEST_NODE_1, TEST_NODE_2, TEST_NODE_3, bridge_address);
        address federationSync_address = address(federationSync);
        bridge.updateFederationSyncAddress (federationSync_address);
        vm.stopPrank();
    }

function testDeployment() public {
    assertEq(address(bridge), federationSync.bridgeContract());
}

    // function testDeposit (uint256 amount, address recipient)
    // check if event is emited - Request_Approved(mssg.sender, amount, recipient, nonce);
    // check balances updates
    // check nonce

    // function testTransfer
    // the same data is sent to federation sync by one node, then the first node tries to send again,
    // then the second node sends wrong data, then the non autoritized send the right data, then the third node
    // sends the right data
    // function transfer to from the contract -
}

