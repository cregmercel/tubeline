// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {GaslessCrossChainOrder} from "../interfaces/IERC7683.sol";

/// @notice What a Tubeline order asks for: an input escrowed on the origin chain, and the least the user accepts in
///  return on Elysium. Carried ABI-encoded in `GaslessCrossChainOrder.orderData`.
struct TubelineOrderData {
    /// @dev The token the user spends, on the origin chain.
    address inputToken;
    /// @dev How much of it is escrowed when the order opens.
    uint256 inputAmount;
    /// @dev The token delivered on the destination chain (bytes32, per ERC-7683).
    bytes32 outputToken;
    /// @dev The user's signed minimum. A fill below it is rejected; anything above it goes to the user.
    uint256 minOutputAmount;
    /// @dev Who receives the output on the destination chain.
    bytes32 recipient;
    /// @dev The destination chain: Elysium (99901 on mainnet, 99801 on testnet).
    uint64 destinationChainId;
}

/// @title TubelineOrderLib
/// @notice The EIP-712 type of a Tubeline order: the one definition of what a user signs. The SDK mirrors it field for
///  field in `packages/sdk/src/eip712.ts`; the two must never drift.
/// @dev The signed struct flattens the ERC-7683 envelope and the order data into one type, so a wallet shows the user
///  every field, minimum included, instead of an opaque `bytes orderData`.
library TubelineOrderLib {
    /// @notice The EIP-712 type string of the signed order.
    bytes internal constant ORDER_TYPE = "TubelineOrder(address originSettler,address user,uint256 nonce,"
        "uint256 originChainId,uint32 openDeadline,uint32 fillDeadline,address inputToken,uint256 inputAmount,"
        "bytes32 outputToken,uint256 minOutputAmount,bytes32 recipient,uint64 destinationChainId)";

    /// @notice keccak256 of `ORDER_TYPE`.
    bytes32 internal constant ORDER_TYPEHASH = keccak256(ORDER_TYPE);

    /// @notice The type string of `TubelineOrderData`.
    bytes internal constant ORDER_DATA_TYPE = "TubelineOrderData(address inputToken,uint256 inputAmount,"
        "bytes32 outputToken,uint256 minOutputAmount,bytes32 recipient,uint64 destinationChainId)";

    /// @notice The value of `GaslessCrossChainOrder.orderDataType` for a Tubeline order.
    bytes32 internal constant ORDER_DATA_TYPEHASH = keccak256(ORDER_DATA_TYPE);

    error WrongOrderDataType(bytes32 orderDataType);

    /// @notice Decodes a Tubeline order's data, rejecting any other order type.
    function decode(GaslessCrossChainOrder calldata order) internal pure returns (TubelineOrderData memory data) {
        if (order.orderDataType != ORDER_DATA_TYPEHASH) revert WrongOrderDataType(order.orderDataType);
        data = abi.decode(order.orderData, (TubelineOrderData));
    }

    /// @notice The EIP-712 struct hash of a Tubeline order. Combined with the settler's domain separator, it is the
    ///  digest the user signs, and it serves as the order's id.
    function hash(GaslessCrossChainOrder calldata order, TubelineOrderData memory data)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                ORDER_TYPEHASH,
                order.originSettler,
                order.user,
                order.nonce,
                order.originChainId,
                order.openDeadline,
                order.fillDeadline,
                data.inputToken,
                data.inputAmount,
                data.outputToken,
                data.minOutputAmount,
                data.recipient,
                data.destinationChainId
            )
        );
    }
}
