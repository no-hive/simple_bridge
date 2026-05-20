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
    address TEST_USER_2 = address(7);

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
        bridge.Deposit(TEST_AMOUNT, TEST_USER_2);
        vm.stopPrank();
    }

    // the valid confirmation
    function testConfirmation() public {
        testDeposit();
        vm.startPrank(TEST_NODE_1);
        federationSync.confirmRequest(TEST_USER_2, TEST_AMOUNT, 1);
        vm.stopPrank();
        //the third node sends the right data
        vm.startPrank(TEST_NODE_3);
        federationSync.confirmRequest(TEST_USER_2, TEST_AMOUNT, 1);
        vm.stopPrank();
    }

    // the valid confirmation
    function testConfirmationReverted_1() public {
        testDeposit();
        vm.startPrank(TEST_NODE_1);
        federationSync.confirmRequest(TEST_USER_2, TEST_AMOUNT, 1);
        vm.stopPrank();
        //the first node tries to send again.
        vm.startPrank(TEST_NODE_1);
        vm.expectRevert();
        federationSync.confirmRequest(TEST_USER_2, TEST_AMOUNT, 1);
        vm.stopPrank();
    }

    function testConfirmationReverted_2() public {
        testDeposit();
        vm.startPrank(TEST_NODE_1);
        federationSync.confirmRequest(TEST_USER_2, TEST_AMOUNT, 1);
        vm.stopPrank();
        // then the second node sends wrong data
        vm.startPrank(TEST_NODE_2);
        uint256 fake_amount_ = TEST_AMOUNT + 1e5;
        vm.expectRevert();
        federationSync.confirmRequest(TEST_USER_2, fake_amount_, 1);
        vm.stopPrank();
    }

    function testConfirmationReverted_3() public {
        testDeposit();
        vm.startPrank(TEST_NODE_1);
        federationSync.confirmRequest(TEST_USER_2, TEST_AMOUNT, 1);
        vm.stopPrank();
        //the non autoritized send the right data
        vm.startPrank(OWNER);
        vm.expectRevert();
        federationSync.confirmRequest(TEST_USER_2, TEST_AMOUNT, 1);
        vm.stopPrank();
    }

    // checks that Deposit --> Confirmations --> Transfer Cycle works
    function testSuccessfullTransfer() public {
        testConfirmation();
        uint256 balance_ = exampleToken.balanceOf(TEST_USER_2);
        assertEq(balance_, TEST_AMOUNT);
    }
}
