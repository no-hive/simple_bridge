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
 * @title  Simple USDC Stacks-Base Bridge
 * @author no-hive
 * @notice This contract is for testing purposes only.
 *         Production version must use SafeERC20.
 */
contract Bridge_sol {

    /**
     * Tracks the USDC balance held on this chain (own_balance)
     * and the mirrored balance available on the other chain (external_balance).
     */
    uint256 public own_balance;
    uint256 public external_balance;

    address public owner;

    /**
     * Incremented on each Deposit to uniquely identify every bridge request.
     * Off-chain nodes use this nonce to match events across chains.
     */
    uint256 public nonce;

    /**
     * Address of the USDC ERC-20 token contract on this chain.
     */
    address public token;

    /**
     * Address of the FederationSync multisig contract.
     * Only this address is authorized to call Transfer().
     */
    address public multisig_contract;

    constructor(
        uint256 _own_balance,
        uint256 _external_balance,
        address _token
    ) {
        own_balance       = _own_balance;
        external_balance  = _external_balance;
        token             = _token;
        nonce             = 0;
        owner = msg.sender;
    }

    /**
     * Validates that the other chain has sufficient funds to cover the transfer,
     * then updates the internal balance accounting and emits Request_Approved
     * to signal off-chain nodes to complete the transfer on the other chain.
     */
    function BridgeRequest(uint256 amount, address recipient) internal {
        require(external_balance > amount, "Insufficient funds on destination chain");
        external_balance -= amount;
        own_balance      += amount;
        nonce += 1;
         emit Request_Approved(msg.sender, amount, recipient, nonce);
    }

    /**
     * Entry point for users who want to bridge tokens to the other chain.
     * Pulls USDC from the caller's wallet into this contract,
     * then triggers BridgeRequest to update balances and notify the nodes.
     */
    function Deposit(uint256 amount, address recipient) external {
        require(amount > 0, "Amount must be greater than zero");
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom failed");
        BridgeRequest(amount, recipient);
    }

    /**
     * Called exclusively by the FederationSync multisig contract
     * after 2-of-3 nodes reach consensus on a cross-chain transfer.
     * Sends USDC from this contract's balance to the recipient on this chain.
     */
    function Transfer(address recipient, uint256 amount) external {
        require(owner == msg.sender, "Caller is not the owner multisig contract");
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

