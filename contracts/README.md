# Contracts

The on-chain half of Tubeline: the settlers that escrow a user's funds on the chain they come from, and accept the courier's delivery on Elysium. Foundry, Solidity 0.8.26.

## Layout

```
src/
  interfaces/IERC7683.sol    ERC-7683 types and the IOriginSettler / IDestinationSettler interfaces
  types/TubelineOrder.sol    TubelineOrderData and its EIP-712 type: the one definition of what a user signs
  settlers/                  origin and destination settlers (see settlers/README.md)
test/                        unit, fuzz, invariant and fork tests (see test/README.md)
script/                      deployment scripts (see script/README.md)
```

## The settlers

**Origin settler** (one per source chain, implements `IOriginSettler`)
- `openFor` verifies the user's EIP-712 signature over the `TubelineOrder`, checks the deadlines and nonce, and pulls the input into escrow through Permit2. Funds move only at this point, when a courier commits to fill.
- Escrow is released to the courier only on proof that the order was filled on Elysium, at or above the user's signed minimum, before the fill deadline.
- An order not filled by its deadline is refundable to the user.

**Destination settler** (Elysium, implements `IDestinationSettler`)
- `fill` transfers the output from the courier to the user's recipient in one transaction, rejects anything below `minOutputAmount` or after `fillDeadline`, and records the fill so it can be proven to the origin chain exactly once.

## Order type

`TubelineOrderData` travels ABI-encoded in the ERC-7683 envelope's `orderData`, identified by `ORDER_DATA_TYPEHASH`. What the user signs is the flattened `TubelineOrder` EIP-712 type, so their wallet shows every field, minimum included. The SDK mirrors the type in [`packages/sdk/src/eip712.ts`](../packages/sdk/src/eip712.ts); the two must match field for field.

## Commands

```bash
forge install foundry-rs/forge-std   # once
forge build
forge test
forge test --match-contract Fork --fork-url $RPC_ELYSIUM
forge fmt
```

## Security

Invariants, trust assumptions and the threat model: [`docs/SECURITY-MODEL.md`](../docs/SECURITY-MODEL.md). External audit before mainnet.
