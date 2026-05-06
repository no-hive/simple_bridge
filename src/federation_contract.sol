// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

// @title Custom Bridge Contract Interface
// @notice Interface to the Bridge contract on this chain
// @dev Must match the deployed Bridge contract exactly
interface IBridge {
    // @notice Releases tokens to a recipient after consensus
    // @param recipient Address receiving tokens
    // @param amount Amount of tokens to transfer
    function safeTransfer(address recipient, uint256 amount) external;
}

// @title Bridge Federation Sync Contract
// @author no-hive (https://github.com/no-hive)
// @notice Coordination contract for off-chain nodes
// @dev Part of a system consisting of:
//      - Owner contract: multisig wallet controlling the bridge
//      - Federation contract: coordinates node consensus for transfers (this contract)
//      - Bridge contract: manages token custody and transfer execution
contract FederationSync {
    // @notice Address of federation node #1
    address public federation_node_1;

    // @notice Address of federation node #2
    address public federation_node_2;

    // @notice Address of federation node #3
    address public federation_node_3;

    // @notice Address of the Bridge contract responsible for custody and transfers
    address public bridgeContract;

    // @notice Contract owner (can rotate federation nodes)
    address public owner;

    // @notice Stores per-request confirmation data submitted by federation nodes
    // @dev
    // Each node independently submits the data it observed from the source chain.
    // Consensus is reached when at least 2 nodes submit identical values.
    ///
    struct ConfirmedRequestData {


        // @notice Whether the transfer has already been executed
        // @dev Prevents double execution for the same nonce
        bool transfer_made;

        // @notice Flags indicating whether each node has confirmed
        bool first_confirmation;
        bool second_confirmation;

        // @notice Submitted recipient per node
        address first_conf_recipient;
        address second_conf_recipient;

        // @notice Submitted amount per node
        uint256 first_conf_amount;
        uint256 second_conf_amount;
    }

    // @notice Mapping from Bridge nonce → request confirmation data
    // @dev Nonce originates from Bridge.Request_Approved event
    mapping(uint256 => ConfirmedRequestData) public requests;

    // @notice Initializes federation nodes and bridge contract
    // @param _federation_node_1 Address of node 1
    // @param _federation_node_2 Address of node 2
    // @param _federation_node_3 Address of node 3
    // @param _bridgeContract Address of Bridge contract
    // @dev
    // Bridge contract must:
    // - Hold the tokens
    // - Restrict Transfer() to this contract
    constructor(
        address _federation_node_1,
        address _federation_node_2,
        address _federation_node_3,
        address _bridgeContract
    ) {
        require(_bridgeContract != address(0), "Invalid bridge");
        require(_federation_node_1 != address(0), "Invalid node 1");
        require(_federation_node_2 != address(0), "Invalid node 2");
        require(_federation_node_3 != address(0), "Invalid node 3");
        federation_node_1 = _federation_node_1;
        federation_node_2 = _federation_node_2;
        federation_node_3 = _federation_node_3;

        bridgeContract = _bridgeContract;
        owner = msg.sender;
    }

    // @notice Submits confirmation of a cross-chain transfer request
    // @param recipient Recipient observed in Bridge.Request_Approved
    // @param amount Amount observed in Bridge.Request_Approved
    // @param nonce Unique request identifier from Bridge
    // @dev
    // Requirements:
    // - Caller must be a federation node
    // - Each node can confirm only once per nonce
    // - Transfer must not have been executed yet
    // Behavior:
    // - Stores node-specific data
    // - Checks if 2 nodes agree on (recipient, amount)
    // - If yes:
    //      1. Marks request as executed
    //      2. Calls Bridge.Transfer()
    // Security:
    // - Reentrancy-safe (state updated before external call)
    function confirmRequest(address _recipient, uint256 _amount, uint256 _nonce) external {
        require(transfer_made == false, "Already Executed");
        if (first_confirmation == true) {
            second_confirmation = true;
            second_conf_recipient = _recipient;
            second_conf_amount = _amount;
        } else {
            second_confirmation = true;
            second_conf_recipient = _recipient;
            second_conf_amount = _amount;
            _hasConsensus(_nonce);
        }
    }

    // @notice Checks whether at least 2 nodes agree on request data
    // @param nonce Request identifier from Bridge
    // @return hasConsensus True if 2-of-3 agreement reached
    // @return situation Encodes which nodes agreed:
    //         - 1 → node1+node2 OR node1+node3
    //         - 2 → node2+node3
    // @dev
    // Consensus requires exact match of:
    // - recipient
    // - amount
    function _hasConsensus(uint256 nonce) internal view returns (bool hasConsensus, uint256 situation) {
        // check that transfer is not executed, and both bools are right.
        require(transfer_made == false, "Already Executed");
        require(first_confirmation == true, "Data Not Collected Yet");
        require(second_confirmation == true, "Data Not Collected Yet");
        require(first_conf_recipient == second_conf_recipient, "1");
        require(first_conf_amount == second_conf_amount, "2");
        IBridge(bridgeContract).safwTransfer(irst_conf_recipient, first_conf_amount);
        emit TransferExecuted(first_conf_recipient, first_conf_amount, nonce);
    }

    // @notice Emitted when a node confirms a request
    // @param confirmedBy Node address
    // @param recipient Proposed recipient
    // @param amount Proposed amount
    // @param nonce Request identifier
    ///
    event RequestConfirmed(address indexed confirmedBy, address indexed recipient, uint256 amount, uint256 nonce);

    // @notice Emitted when transfer is executed after consensus
    // @param recipient Final recipient
    // @param amount Final amount
    // @param nonce Request identifier
    event TransferExecuted(address indexed recipient, uint256 amount, uint256 nonce);

    // @notice Emitted when a federation node is updated
    // @param nodeIndex Node index (1, 2, or 3)
    // @param changedBy Address performing the change
    // @param newAddress New node address
    event NodeChanged(uint8 indexed nodeIndex, address indexed changedBy, address indexed newAddress);

    // @notice Restricts function access to owner

    modifier onlyOwner() {
        require(msg.sender == owner, "Not admin");
        _;
    }

       modifier onlyNode() {
        require(msg.sender == federation_node_1, federation_node_2, federation_node_3, "Not admin");
        _;
    }
}
