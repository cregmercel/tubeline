# Settlers

The two contracts that hold and move funds.

| Contract | Chain | Implements | Responsibility |
|---|---|---|---|
| `TubelineOriginSettler` | each source chain | `IOriginSettler` | Verify the signed order, escrow the input via Permit2, release it to the courier on proof of fill, refund the user after the fill deadline. |
| `TubelineDestinationSettler` | Robinhood Chain | `IDestinationSettler` | Accept the courier's delivery to the user, enforce the minimum and deadline, record the fill for proof. |

## Invariants they must hold

1. Escrowed funds leave only to the courier who filled (with a valid proof) or back to the user (after the fill deadline). Never both, never anyone else.
2. An order is filled at most once and paid out at most once.
3. A fill delivers at least the signed `minOutputAmount` to the signed `recipient`, before `fillDeadline`.
4. A signature opens at most one order (nonce), only on the settler and chain it names.
5. Pausing stops new orders; it never blocks a refund or a valid payout of an order already open.

Each invariant has an invariant test in `test/`. The full threat model is in [`docs/SECURITY-MODEL.md`](../../../docs/SECURITY-MODEL.md).

## Proof of fill

How the destination tells the origin that an order was filled is chosen per route, behind one interface, so the settlers don't depend on a single messaging system. The options under evaluation (a cross-chain messaging layer, or optimistic proof with a challenge window) and their trade-offs are in [`docs/ARCHITECTURE.md`](../../../docs/ARCHITECTURE.md#proof-of-fill).
