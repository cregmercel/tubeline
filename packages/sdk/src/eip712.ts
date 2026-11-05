/**
 * The EIP-712 definition of a Tubeline order: what a user's wallet shows them, and what they sign.
 *
 * This must match `TubelineOrderLib.ORDER_TYPE` in `contracts/src/types/TubelineOrder.sol` field for field, in the
 * same order. The shapes below plug straight into viem's `signTypedData` / ethers' `signTypedData`.
 */
import type { Address, TubelineOrder } from './types.ts';

/** The signing domain. One per origin settler deployment. */
export function orderDomain(chainId: number, originSettler: Address) {
  return {
    name: 'Tubeline',
    version: '1',
    chainId,
    verifyingContract: originSettler,
  } as const;
}

/** The order's EIP-712 types. */
export const ORDER_TYPES = {
  TubelineOrder: [
    { name: 'originSettler', type: 'address' },
    { name: 'user', type: 'address' },
    { name: 'nonce', type: 'uint256' },
    { name: 'originChainId', type: 'uint256' },
    { name: 'openDeadline', type: 'uint32' },
    { name: 'fillDeadline', type: 'uint32' },
    { name: 'inputToken', type: 'address' },
    { name: 'inputAmount', type: 'uint256' },
    { name: 'outputToken', type: 'bytes32' },
    { name: 'minOutputAmount', type: 'uint256' },
    { name: 'recipient', type: 'bytes32' },
    { name: 'destinationChainId', type: 'uint64' },
  ],
} as const;

export const ORDER_PRIMARY_TYPE = 'TubelineOrder' as const;

/** The EIP-712 type string, identical to the contract's `ORDER_TYPE`. Its keccak256 is the order typehash. */
export const ORDER_TYPE_STRING = `${ORDER_PRIMARY_TYPE}(${ORDER_TYPES.TubelineOrder.map((f) => `${f.type} ${f.name}`).join(',')})`;

/** Everything a wallet needs to sign an order. */
export function orderTypedData(order: TubelineOrder) {
  return {
    domain: orderDomain(Number(order.originChainId), order.originSettler),
    types: ORDER_TYPES,
    primaryType: ORDER_PRIMARY_TYPE,
    message: order,
  } as const;
}
