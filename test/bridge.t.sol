pragma solidity ^0.8.33;

import {Bridge} from "src/bridge_contract.sol";
import {FederationSync} from "src/federation_contract.sol";
import "forge-std/Test.sol";

contract BridgeTest is Test {
    Bridge public bridge;
    FederationSync public federationSync;

    address TEST_TOKEN = 0x0000000000000000000000000000000000000001;

    address TEST_NODE_1 = 0x0000000000000000000000000000000000000002;
    address TEST_NODE_2 = 0x0000000000000000000000000000000000000003;
    address TEST_NODE_3 = 0x0000000000000000000000000000000000000004;

    function setUp() public {
        bridge = new Bridge(TEST_TOKEN);
        address bridge_address = address(bridge);
        federationSync = new FederationSync(TEST_NODE_1, TEST_NODE_2, TEST_NODE_3, bridge_address);
        // address federationSync_address = address(federationSync);
        // update address in bridge contract
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

