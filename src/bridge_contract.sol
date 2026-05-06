// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// @title ERC-20 Bridge Contract
// @author no-hive (https://github.com/no-hive)
// @notice Holds tokens on this chain and coordinates cross-chain transfers
// @dev Part of a system consisting of:
//      - Owner contract: multisig wallet controlling the bridge
//      - Federation contract: coordinates node consensus for transfers
//      - Bridge contract: manages token custody and transfer execution (this contract)
contract Bridge {
    using SafeERC20 for IERC20;
    //
    // ===================================
    // EVENTS
    // ===================================

    // @notice Emitted when a deposit is accepted and cross-chain transfer is initiated
    // @param sender Address initiating the deposit
    // @param amount Amount of tokens deposited
    // @param recipient Destination address on the other chain
    // @param nonce Unique identifier of the request
    event Request_Approved(address indexed sender, uint256 amount, address recipient, uint256 nonce);

    // @notice Emitted when the owner address is changed
    // @param block Block number when the change occurred
    // @param previous_owner Previous owner address
    // @param new_owner New owner address
    event Owner_Changed(uint256 block, address previous_owner, address new_owner);

    // @notice Emitted when tokens are successfully released to a recipient
    // @param amount Amount of tokens transferred
    // @param recipient Address receiving the tokens
    event Tokens_Released(uint256 amount, address recipient);

    // @notice Emitted when liquidity is updated
    // @param amount Amount of liquidity added
    // @param own True if local liquidity was increased, false if external
    event Liquidity_Changed(uint256 amount, bool own);

    // ===================================
    // VARIABLES
    // ===================================

    // @notice Multisig wallet address controlling the bridge
    address public owner;

    // @notice Federation contract responsible for coordinating cross-chain approvals
    address public federation_contract;

    // @notice ERC-20 token address handled by the bridge
    address public immutable token;

    // @notice Amount of tokens held on this chain
    uint256 public own_balance;

    // @notice Amount of tokens available on the external chain
    uint256 public external_balance;

    // @notice Incremental identifier for each deposit request
    uint256 public nonce;

    // ===================================
    // CONSTRUCTOR
    // ===================================

    // @notice Initializes the bridge contract
    // @param _token Address of the ERC-20 token to be bridged
    // @dev Sets initial balances to zero and assigns contract deployer as owner
    constructor(address _token) {
        own_balance = 0;
        external_balance = 0;
        require(_token != address(0), "Invalid token address");
        token = _token;
        nonce = 0;
        owner = msg.sender;
    }

    // ===================================
    // FUNCTOINS - DEPOSIT & TRANSFER
    // ===================================

    // @notice Locks tokens on this chain and initiates a cross-chain transfer
    // @param amount Amount of tokens to bridge
    // @param recipient Address that will receive tokens on the destination chain
    // @dev Requires sufficient liquidity on the external chain
    //      Emits a Request_Approved event for off-chain processing by federation nodes
    function Deposit(uint256 amount, address recipient) external {
        require(amount > 0, "Amount must be greater than zero");
        require(external_balance > amount, "Insufficient funds on destination chain");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        external_balance -= amount;
        own_balance += amount;
        nonce += 1;

        emit Request_Approved(msg.sender, amount, recipient, nonce);
    }

    // @notice Releases tokens to a recipient after federation approval
    // @param recipient Address receiving the tokens
    // @param amount Amount of tokens to transfer
    // @dev Can only be called by the federation contract
    function Transfer(address recipient, uint256 amount) external {
        require(federation_contract == msg.sender, "Not federation contract");

        IERC20(token).safeTransfer(recipient, amount);

        emit Tokens_Released(amount, recipient);
    }

    // ===================================
    // FUNCTIONS - LIQUIDITY MANAGEMENT
    // ===================================

    // @notice Adds liquidity to the bridge on this chain
    // @param amount Amount of tokens to add
    // @dev Transfers tokens from the owner to the contract and updates internal balance

    function AddOwnLiquidity(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        own_balance += amount;

        emit Liquidity_Changed(amount, true);
    }

    // @notice Updates liquidity available on the external chain
    // @param amount Amount of liquidity to add
    // @dev Does not transfer tokens, only updates internal accounting

    function AddExternalLiquidity(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");

        external_balance += amount;

        emit Liquidity_Changed(amount, false);
    }

    // ===================================
    // MODIFIERS
    // ===================================

    // @notice Updates the owner (multisig) address
    // @param _owner New owner address
    // @dev Used for administrative control and key rotation
    function ChangeOwner(address _owner) external onlyOwner {
        require(_owner != address(0), "Invalid token address");
        owner = _owner;

        emit Owner_Changed(block.number, msg.sender, _owner);
    }

    // @notice Restricts function access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not admin");
        _;
    }
}
