# Security model

## Assets at risk

- **User input in escrow** on each origin settler, between open and settlement or refund.
- **Courier inventory** on Robinhood Chain, spent at fill and repaid later.
- **Order flow**: an order seen early could be traded against.

## Trust assumptions

| Party | Trusted for | Not trusted for |
|---|---|---|
| User | Their own signature | Anything else |
| Relay | Routing orders and running the auction | Funds, order contents, minimums (all fixed by the signature, enforced on-chain) |
| Courier | Nothing: it is paid only for a proven fill | |
| Proof of fill | Correctly reporting that a fill happened | Depends on the route's design (messaging layer or optimistic challenge); see ARCHITECTURE.md |
| Owner (multisig) | Pausing new orders, adding routes | Moving escrowed funds, changing open orders, blocking refunds |

## Invariants

1. Escrow leaves only to the courier with a valid proof of fill, or to the user after `fillDeadline`. Never both, never anyone else.
2. Each order is filled at most once and paid at most once.
3. A fill delivers at least `minOutputAmount` to `recipient` before `fillDeadline`, or it reverts.
4. A signature opens at most one order, on the settler and chain it names (EIP-712 domain, nonce).
5. Pause stops new orders only; refunds and payouts of open orders always work.

Every invariant has an invariant test in `contracts/test/`.

## Threats and mitigations

| Threat | Mitigation |
|---|---|
| Replay of a signature on another chain or settler | EIP-712 domain binds chain id and settler; nonces are single-use. |
| Front-running a user's order | Orders are sealed to registered couriers and never touch a public mempool; the signed minimum caps any extraction. |
| Fill below the minimum, or to the wrong recipient | Enforced in the destination settler against the signed fields. |
| Paying a courier without a delivery | Escrow releases only on proof of a matching fill. |
| Double payout via duplicate proofs | Fills and payouts are recorded per order id; second attempts revert. |
| Courier fills, then the origin open is reorged away | Couriers fill only once the open is final enough for the source chain; this risk sits with the courier, never the user. |
| Stalled order | Every order ends Expired or Refunded on its own deadlines; no party can hold funds hostage. |
| Compromised owner key | Owner is a multisig; it cannot touch escrow or block refunds. |
| Compromised courier hot key | Hot wallets hold only hours of float; caps and automatic stops bound the loss. |

## Process

- External audit of all settlement contracts before mainnet; the report is published in this repository.
- Mainnet launches with per-order caps, raised as the system proves itself.
- Bug bounty from mainnet launch. Private disclosure: [`SECURITY.md`](../SECURITY.md).
