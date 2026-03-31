// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

/**
 * Interface of Bridge_sol deployed on this chain.
 * Transfer() sends USDC tokens to the recipient after 2-of-3 consensus is reached.
 * Only this contract's address is authorized to call it, enforced by Bridge_sol.
 */
interface IBridge {
    function Transfer(address recipient, uint256 amount) external;
}

contract FederationSync {

    /**
     * Addresses of the three federation nodes. Only these addresses
     * are allowed to confirm requests and rotate their own address.
     */
    address public federation_node_1;
    address public federation_node_2;
    address public federation_node_3;

    /**
     * Address of the Bridge_sol contract that holds the USDC funds
     * and executes the token transfer once consensus is reached.
     */
    address public bridgeContract;

    address public owner;

    /**
     * Each transfer request is identified by a nonce taken from Bridge_sol's
     * Request_Approved event. The struct stores each node's submission separately
     * so the contract can verify that two nodes agree on the same parameters
     * before releasing funds.
     */
    struct ConfirmedRequestData {
        bool    transfer_made;
        bool consensus_reached;
        bool    node_1_confirmation;
        bool    node_2_confirmation;
        bool    node_3_confirmation;
        address node_1_recipient;
        address node_2_recipient;
        address node_3_recipient;
        address recipient_confirmed;
        uint256 node_1_amount;
        uint256 node_2_amount;
        uint256 node_3_amount;
        uint256 amount_confirmed;
    }

    /**
     * Maps each nonce to its confirmation data.
     * Allows independent lookups per request without array iteration.
     */
    mapping(uint256 => ConfirmedRequestData) public requests;

    constructor(
        address _federation_node_1,
        address _federation_node_2,
        address _federation_node_3,
        address _bridgeContract
    ) {
        federation_node_1 = _federation_node_1;
        federation_node_2 = _federation_node_2;
        federation_node_3 = _federation_node_3;
        bridgeContract    = _bridgeContract;
        owner = msg.sender;
    }

    /**
     * Called by each node after it detects a Request_Approved event on the source chain.
     * Each node submits the recipient address, amount, and nonce it observed.
     * After each submission the contract checks whether any two nodes agree —
     * if yes, transfer_made is set to true and Bridge_sol.Transfer() is called.
     * The transfer_made flag permanently blocks re-execution for that nonce.
     */
    function confirmRequest(
        address recipient,
        uint256 amount,
        uint256 nonce
    ) external {
        ConfirmedRequestData storage req = requests[nonce];

        require(!req.transfer_made, "Transfer already executed");

        if (msg.sender == federation_node_1) {
            require(!req.node_1_confirmation, "Node 1 already confirmed");
            req.node_1_confirmation = true;
            req.node_1_recipient    = recipient;
            req.node_1_amount       = amount;
        } else if (msg.sender == federation_node_2) {
            require(!req.node_2_confirmation, "Node 2 already confirmed");
            req.node_2_confirmation = true;
            req.node_2_recipient    = recipient;
            req.node_2_amount       = amount;
        } else if (msg.sender == federation_node_3) {
            require(!req.node_3_confirmation, "Node 3 already confirmed");
            req.node_3_confirmation = true;
            req.node_3_recipient    = recipient;
            req.node_3_amount       = amount;
             } else {
            revert("Only federation nodes can confirm");
        }
        emit RequestConfirmed(msg.sender, recipient, amount, nonce);

        (bool ok, address finalRecipient, uint256 finalAmount) = _getConsensus(nonce);

        if (ok) {
            req.transfer_made = true;
            IBridge(bridgeContract).Transfer(finalRecipient, finalAmount);
            emit TransferExecuted(finalRecipient, finalAmount, nonce);
        }
    }

    /**
     * Each node can rotate only its own registered address.
     * Designed for key rotation or node infrastructure changes
     * without requiring a full contract redeployment.
     */
    function changeNode1(address newAddress) external onlyOwner {
        federation_node_1 = newAddress;
        emit NodeChanged(1, msg.sender, newAddress);
    }

    function changeNode2(address newAddress) external onlyOwner {
        federation_node_2 = newAddress;
        emit NodeChanged(2, msg.sender, newAddress);
    }

    function changeNode3(address newAddress) external onlyOwner {
        federation_node_3 = newAddress;
        emit NodeChanged(3, msg.sender, newAddress);
    }

    

    /**
     * Iterates over all three node pairs and returns true as soon as
     * any two nodes are found to have submitted identical recipient and amount.
     * Called internally at the end of every confirmRequest execution.
     */
function _getConsensus(uint256 nonce)
    internal
    view
    returns (bool, address, uint256)
{
    ConfirmedRequestData storage req = requests[nonce];

    // node 1 + node 2
    if (req.node_1_confirmation && req.node_2_confirmation) {
        if (
            req.node_1_recipient == req.node_2_recipient &&
            req.node_1_amount    == req.node_2_amount
        ) {
            return (true, req.node_1_recipient, req.node_1_amount);
        }
    }

    // node 1 + node 3
    if (req.node_1_confirmation && req.node_3_confirmation) {
        if (
            req.node_1_recipient == req.node_3_recipient &&
            req.node_1_amount    == req.node_3_amount
        ) {
            return (true, req.node_1_recipient, req.node_1_amount);
        }
    }

    // node 2 + node 3
    if (req.node_2_confirmation && req.node_3_confirmation) {
        if (
            req.node_2_recipient == req.node_3_recipient &&
            req.node_2_amount    == req.node_3_amount
        ) {
            return (true, req.node_2_recipient, req.node_2_amount);
        }
    }

    return (false, address(0), 0);
}

    /**
     * Emitted each time a node submits its confirmation for a given nonce.
     * Off-chain services can track this to monitor consensus progress.
     */
    event RequestConfirmed(
        address indexed confirmedBy,
        address indexed recipient,
        uint256 amount,
        uint256 nonce
    );

    /**
     * Emitted once consensus is reached and Bridge_sol.Transfer() has been called.
     */
    event TransferExecuted(
        address indexed recipient,
        uint256 amount,
        uint256 nonce
    );

    /**
     * Emitted when a node rotates its address.
     * Records the node index, the old address that initiated the change,
     * and the new address that replaces it.
     */
    event NodeChanged(
        uint8   indexed nodeIndex,
        address indexed changedBy,
        address indexed newAddress
    );

      modifier onlyOwner() {
        require(msg.sender == owner, "Not admin");
        _;
    }
}
