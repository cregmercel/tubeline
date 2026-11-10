/**
 * The Tubeline order, as the SDK and its users see it. These mirror the Solidity structs in
 * `contracts/src/interfaces/IERC7683.sol` and `contracts/src/types/TubelineOrder.sol`.
 */

/** A 20-byte EVM address, 0x-prefixed. */
export type Address = `0x${string}`;

/** A 32-byte value, 0x-prefixed. ERC-7683 uses bytes32 for tokens and recipients so non-EVM chains fit. */
export type Bytes32 = `0x${string}`;

/** What a Tubeline order asks for. Mirrors `TubelineOrderData`. */
export interface TubelineOrderData {
  /** The token the user spends, on the origin chain. */
  inputToken: Address;
  /** How much of it is escrowed when the order opens, in the token's smallest unit. */
  inputAmount: bigint;
  /** The token delivered on Elysium. */
  outputToken: Bytes32;
  /** The least the user accepts. A fill below it is rejected; anything above it goes to the user. */
  minOutputAmount: bigint;
  /** Who receives the output on Elysium. */
  recipient: Bytes32;
  /** The destination chain id: Elysium (99901 on mainnet, 99801 on testnet). */
  destinationChainId: bigint;
}

/** The full order a user signs: the ERC-7683 envelope plus the order data, flattened. Mirrors `TubelineOrder`. */
export interface TubelineOrder extends TubelineOrderData {
  /** The origin settler the order is opened on. */
  originSettler: Address;
  /** The user whose funds the order spends. */
  user: Address;
  /** Replay protection, scoped to the user and settler. */
  nonce: bigint;
  /** The chain the order is opened on. */
  originChainId: bigint;
  /** Latest time (unix seconds) the order can be opened. */
  openDeadline: number;
  /** Latest time (unix seconds) the order can be filled on Elysium. */
  fillDeadline: number;
}

/** Where an order is in its life. See docs/ORDER-LIFECYCLE.md. */
export type OrderStatus =
  | 'signed' // signed by the user, held by the relay, nothing has moved
  | 'auction' // sealed, couriers are bidding
  | 'opened' // a courier opened it: the input is in escrow on the origin chain
  | 'delivered' // the courier filled it on Elysium
  | 'settled' // the fill was proven and the escrow released to the courier
  | 'expired' // not opened before openDeadline: nothing ever moved
  | 'refunded'; // opened but not filled before fillDeadline: the input went back to the user

/** Left-pads a 20-byte EVM address into the bytes32 form ERC-7683 uses for tokens and recipients. */
export function addressToBytes32(address: Address): Bytes32 {
  const hex = address.slice(2).toLowerCase();
  if (!/^[0-9a-f]{40}$/.test(hex)) throw new Error(`not a 20-byte address: ${address}`);
  return `0x${hex.padStart(64, '0')}`;
}
