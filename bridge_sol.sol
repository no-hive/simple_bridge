// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

/**
 * Standard ERC-20 interface. Used to interact with the USDC token contract:
 * transferFrom pulls tokens from the user into this contract on Deposit,
 * transfer sends tokens out to the recipient on Transfer.
 */
interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

/**
 * Simple ERC-20 Bridge
 * 
 */
contract Bridge_sol {

    /**
     * Owner address is the multisig wallet that controls the bridge.
     * Federation_contract serves as a coordination space for nodes.
     * Token address is the ERC-20 token contract on this chain.
     * Own_balance tracks the token balance held on this chain.
     * External_balance tracks the token balance available on the other chain.
     * Nonce is incremented on each Deposit to uniquely identify every bridge request.
     */
    address public owner;
    address public federation_contract;
    address public token;
    uint256 public own_balance;
    uint256 public external_balance;
    uint256 public nonce;

    /**
     * Sets initial variable values.
     * Permanently stores the bridgable token address.
     */
    constructor(address _token) {
        own_balance = 0;
        external_balance = 0;
        token = _token;
        nonce = 0;
        owner = msg.sender;
    }

    /**
     * Entry point for users who want to bridge tokens to the other chain.
     * Pulls ERC-20 from the caller's wallet into this contract.
     * Validates that the other chain has sufficient funds to cover the transfer,
     * then updates the internal balance accounting and emits Request_Approved
     * to signal off-chain nodes to complete the transfer on the other chain.
     */
    function Deposit(uint256 amount, address recipient) external {
        require(amount > 0, "Amount must be greater than zero");
        require(external_balance > amount, "Insufficient funds on destination chain");
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom failed");
        external_balance -= amount;
        own_balance      += amount;
        nonce += 1;
         emit Request_Approved(msg.sender, amount, recipient, nonce);
    }

    /**
     * Called exclusively by the Federation contract
     * after 2-of-3 nodes reach consensus on a cross-chain transfer.
     * Sends ERC-20 token from this contract's balance to the recipient on this chain.
     */
    function Transfer(address recipient, uint256 amount) external {
        require(federation_contract == msg.sender, "Caller is not the federation contract");
        bool success = IERC20(token).transfer(recipient, amount);
        require(success, "Token transfer failed");
         emit Tokens_Released(amount, recipient);
    }


    function AddOwnLiquidity(uint256 amount) external onlyOwner (){
        require(amount > 0, "Amount must be greater than zero");
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom failed");
        bool own = true;
        own_balance += amount;
        emit Liquidity_Changed(amount, own);
    }

    function AddExternalLiquidity(uint256 amount) external onlyOwner (){
        require(amount > 0, "Amount must be greater than zero");
        bool own = false;
        external_balance += amount;
        emit Liquidity_Changed(amount, own);
    }


    function ChangeOwner (address _owner) public onlyOwner {
        owner = _owner;
    emit Owner_Changed (block.number, msg.sender, _owner);
    }

    /**
     * Emitted by BridgeRequest to notify off-chain federation nodes
     * that a user has deposited funds and a cross-chain transfer should begin.
     * Nodes listen for this event and call confirmRequest() on FederationSync.
     */
    event Request_Approved(
        address indexed sender,
        uint256 amount,
        address  recipient,
        uint256 nonce
    );

    event Owner_Changed (
        uint256 block,
        address  previous_owner,
        address new_owner
    );

    event Tokens_Released(
        uint256 amount,
        address  recipient
    );

        event Liquidity_Changed(
        uint256 amount,
        bool own
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not admin");
        _;
    }

}

