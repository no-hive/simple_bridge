pragma solidity ^0.8.33;

import {Bridge} from "src/bridge_contract.sol";
import {FederationSync} from "src/federation_contract.sol";
import {ExampleToken} from "test/example_token.sol";
import "forge-std/Test.sol";

contract BridgeTest is Test {
    Bridge public bridge;
    FederationSync public federationSync;
    ExampleToken public exampleToken;

    // test addreses
    address TEST_TOKEN = address(1);
    address TEST_NODE_1 = address(2);
    address TEST_NODE_2 = address(3);
    address TEST_NODE_3 = address(4);
    address OWNER = address(5);

    uint256 TEST_AMOUNT = 100000000;
    address TEST_USER = address(6);

    function setUp() public {
        vm.startPrank(OWNER);
        exampleToken = new ExampleToken(OWNER);
        address exampleToken_address = address(exampleToken);
        bridge = new Bridge(exampleToken_address);
        address bridge_address = address(bridge);
        federationSync = new FederationSync(TEST_NODE_1, TEST_NODE_2, TEST_NODE_3, bridge_address);
        address federationSync_address = address(federationSync);
        bridge.updateFederationSyncAddress(federationSync_address);
        vm.stopPrank();
    }

    function testDeployment() public {
        assertEq(address(bridge), federationSync.bridgeContract());
    }

    function testDeposit() public {
        vm.startPrank(OWNER);
        // send token both to user and to the contract
        bool transferBool = exampleToken.transfer(TEST_USER, TEST_AMOUNT);
        bridge.AddExternalLiquidity(1000000000);
        vm.stopPrank();
        vm.startPrank(TEST_USER);
        address bridge_address = address(bridge);
        bool approveBool = exampleToken.approve(bridge_address, TEST_AMOUNT);
        bridge.Deposit(TEST_AMOUNT, TEST_USER);
        assertEq(1, bridge.nonce());
        vm.stopPrank();
        // check if event is emited - Request_Approved(mssg.sender, amount, recipient, nonce);
        // check balances updates
    }

    // function testTransfer
    // the same data is sent to federation sync by one node, then the first node tries to send again,
    // then the second node sends wrong data, then the non autoritized send the right data, then the third node
    // sends the right data
    // function transfer to from the contract -
}

