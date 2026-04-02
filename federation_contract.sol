// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

/**
 * @title Custom Bridge Contract Interface
 * @notice Interface to the Bridge contract on this chain
 * @dev Must match the deployed Bridge contract exactly
 */
interface IBridge {
    /**
     * @notice Releases tokens to a recipient after consensus
     * @param recipient Address receiving tokens
     * @param amount Amount of tokens to transfer
     */
    function Transfer(address recipient, uint256 amount) external;
}

/**
 * @title Bridge Federation Sync Contract
 * @author no-hive (https://github.com/no-hive)
 * @notice Coordination contract for off-chain nodes
 * @dev Part of a system consisting of:
 *      - Owner contract: multisig wallet controlling the bridge
 *      - Federation contract: coordinates node consensus for transfers (this contract)
 *      - Bridge contract: manages token custody and transfer execution
 */
contract FederationSync {

    /// @notice Address of federation node #1
    address public federation_node_1;

    /// @notice Address of federation node #2
    address public federation_node_2;

    /// @notice Address of federation node #3
    address public federation_node_3;

    /// @notice Address of the Bridge contract responsible for custody and transfers
    address public bridgeContract;

    /// @notice Contract owner (can rotate federation nodes)
    address public owner;

    /**
     * @notice Stores per-request confirmation data submitted by federation nodes
     *
     * @dev
     * Each node independently submits the data it observed from the source chain.
     * Consensus is reached when at least 2 nodes submit identical values.
     */
    struct ConfirmedRequestData {

        /// @notice Whether the transfer has already been executed
        /// @dev Prevents double execution for the same nonce
        bool transfer_made;

        /// @notice Flags indicating whether each node has confirmed
        bool node_1_confirmation;
        bool node_2_confirmation;
        bool node_3_confirmation;

        /// @notice Submitted recipient per node
        address node_1_recipient;
        address node_2_recipient;
        address node_3_recipient;

        /// @notice Final recipient after consensus
        address recipient_confirmed;

        /// @notice Submitted amount per node
        uint256 node_1_amount;
        uint256 node_2_amount;
        uint256 node_3_amount;

        /// @notice Final amount after consensus
        uint256 amount_confirmed;
    }

    /// @notice Mapping from Bridge nonce → request confirmation data
    /// @dev Nonce originates from Bridge.Request_Approved event
    mapping(uint256 => ConfirmedRequestData) public requests;

    /**
     * @notice Initializes federation nodes and bridge contract
     *
     * @param _federation_node_1 Address of node 1
     * @param _federation_node_2 Address of node 2
     * @param _federation_node_3 Address of node 3
     * @param _bridgeContract Address of Bridge contract
     *
     * @dev
     * Bridge contract must:
     * - Hold the tokens
     * - Restrict Transfer() to this contract
     */
    constructor(
        address _federation_node_1,
        address _federation_node_2,
        address _federation_node_3,
        address _bridgeContract
    ) {
        require(_bridgeContract != address(0), "Invalid bridge");

        federation_node_1 = _federation_node_1;
        federation_node_2 = _federation_node_2;
        federation_node_3 = _federation_node_3;

        bridgeContract = _bridgeContract;
        owner = msg.sender;
    }

    /**
     * @notice Submits confirmation of a cross-chain transfer request
     *
     * @param recipient Recipient observed in Bridge.Request_Approved
     * @param amount Amount observed in Bridge.Request_Approved
     * @param nonce Unique request identifier from Bridge
     *
     * @dev
     * Requirements:
     * - Caller must be a federation node
     * - Each node can confirm only once per nonce
     * - Transfer must not have been executed yet
     *
     * Behavior:
     * - Stores node-specific data
     * - Checks if 2 nodes agree on (recipient, amount)
     * - If yes:
     *      1. Marks request as executed
     *      2. Calls Bridge.Transfer()
     *
     * Security:
     * - Reentrancy-safe (state updated before external call)
     */
    function confirmRequest(
        address recipient,
        uint256 amount,
        uint256 nonce
    ) external {
        // implementation
    }

    /**
     * @notice Checks whether at least 2 nodes agree on request data
     *
     * @param nonce Request identifier from Bridge
     *
     * @return hasConsensus True if 2-of-3 agreement reached
     * @return situation Encodes which nodes agreed:
     *         - 1 → node1+node2 OR node1+node3
     *         - 2 → node2+node3
     *
     * @dev
     * Consensus requires exact match of:
     * - recipient
     * - amount
     */
    function _hasConsensus(uint256 nonce)
        internal
        view
        returns (bool hasConsensus, uint256 situation)
    {
        // implementation
    }

    /**
     * @notice Updates federation node #1 address
     * @param newAddress New node address
     *
     * @dev Only callable by owner
     */
    function changeNode1(address newAddress) external onlyOwner {}

    /**
     * @notice Updates federation node #2 address
     * @param newAddress New node address
     */
    function changeNode2(address newAddress) external onlyOwner {}

    /**
     * @notice Updates federation node #3 address
     * @param newAddress New node address
     */
    function changeNode3(address newAddress) external onlyOwner {}

    /**
     * @notice Emitted when a node confirms a request
     *
     * @param confirmedBy Node address
     * @param recipient Proposed recipient
     * @param amount Proposed amount
     * @param nonce Request identifier
     */
    event RequestConfirmed(
        address indexed confirmedBy,
        address indexed recipient,
        uint256 amount,
        uint256 nonce
    );

    /**
     * @notice Emitted when transfer is executed after consensus
     *
     * @param recipient Final recipient
     * @param amount Final amount
     * @param nonce Request identifier
     */
    event TransferExecuted(
        address indexed recipient,
        uint256 amount,
        uint256 nonce
    );

    /**
     * @notice Emitted when a federation node is updated
     *
     * @param nodeIndex Node index (1, 2, or 3)
     * @param changedBy Address performing the change
     * @param newAddress New node address
     */
    event NodeChanged(
        uint8 indexed nodeIndex,
        address indexed changedBy,
        address indexed newAddress
    );

    /**
     * @notice Restricts function access to owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not admin");
        _;
    }
}