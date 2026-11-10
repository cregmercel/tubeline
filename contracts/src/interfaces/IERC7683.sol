// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ERC-7683 cross-chain intents
/// @notice The standard's types and settler interfaces, as specified in https://eips.ethereum.org/EIPS/eip-7683.
///  Tubeline's origin and destination settlers implement these, so any ERC-7683 filler can read a Tubeline
///  order without Tubeline-specific code.

/// @notice A user's order, signed off-chain and opened on the origin chain by a filler on their behalf.
struct GaslessCrossChainOrder {
    /// @dev The settler contract on the origin chain that this order is opened on.
    address originSettler;
    /// @dev The user whose funds the order spends, and who signed it.
    address user;
    /// @dev Replay protection, scoped to the user and settler.
    uint256 nonce;
    /// @dev The chain the order is opened on.
    uint256 originChainId;
    /// @dev The latest time the order can be opened.
    uint32 openDeadline;
    /// @dev The latest time the order can be filled on the destination chain.
    uint32 fillDeadline;
    /// @dev EIP-712 typehash of `orderData`'s type, so fillers know how to decode it.
    bytes32 orderDataType;
    /// @dev Implementation-specific order data (for Tubeline, an encoded `TubelineOrderData`).
    bytes orderData;
}

/// @notice An order opened directly on the origin chain by the user, in their own transaction.
struct OnchainCrossChainOrder {
    uint32 fillDeadline;
    bytes32 orderDataType;
    bytes orderData;
}

/// @notice The implementation-independent view of an order: what it spends, what it must deliver, and how to fill
///  it. Emitted on open, and returned by `resolve`/`resolveFor`.
struct ResolvedCrossChainOrder {
    address user;
    uint256 originChainId;
    uint32 openDeadline;
    uint32 fillDeadline;
    bytes32 orderId;
    /// @dev The most the filler can be charged, across all chains. For a filler, these are the outputs they must
    ///  deliver; Tubeline sets them equal to `minReceived` on the destination chain.
    Output[] maxSpent;
    /// @dev The least the filler receives in return: the user's escrowed input on the origin chain.
    Output[] minReceived;
    /// @dev One instruction per destination chain the filler must act on.
    FillInstruction[] fillInstructions;
}

/// @notice A token amount on a chain, with its recipient. Addresses are bytes32 so non-EVM chains fit.
struct Output {
    bytes32 token;
    uint256 amount;
    bytes32 recipient;
    uint256 chainId;
}

/// @notice What a filler must pass to the destination settler on one chain.
struct FillInstruction {
    uint64 destinationChainId;
    bytes32 destinationSettler;
    bytes originData;
}

/// @notice The settler on the chain an order's funds come from.
interface IOriginSettler {
    /// @notice Emitted when an order is opened and its input is escrowed.
    event Open(bytes32 indexed orderId, ResolvedCrossChainOrder resolvedOrder);

    /// @notice Opens a gasless order on the user's behalf, verifying their signature and escrowing their input.
    function openFor(GaslessCrossChainOrder calldata order, bytes calldata signature, bytes calldata originFillerData)
        external;

    /// @notice Opens an order the caller signs by sending this transaction.
    function open(OnchainCrossChainOrder calldata order) external;

    /// @notice Resolves a gasless order into its standard view, without opening it.
    function resolveFor(GaslessCrossChainOrder calldata order, bytes calldata originFillerData)
        external
        view
        returns (ResolvedCrossChainOrder memory);

    /// @notice Resolves an on-chain order into its standard view, without opening it.
    function resolve(OnchainCrossChainOrder calldata order) external view returns (ResolvedCrossChainOrder memory);
}

/// @notice The settler on the chain an order is delivered on.
interface IDestinationSettler {
    /// @notice Fills an order: the filler delivers the order's outputs to the user.
    /// @param orderId The order's id, from its `ResolvedCrossChainOrder`.
    /// @param originData The `FillInstruction.originData` for this chain.
    /// @param fillerData Filler-chosen data, e.g. where the filler wants to be repaid.
    function fill(bytes32 orderId, bytes calldata originData, bytes calldata fillerData) external;
}
