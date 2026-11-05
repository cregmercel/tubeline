# Relay

The off-chain front door. It takes a user's signed order, keeps it sealed, runs the auction between couriers, and reports the order's status back to the user.

## Responsibilities

- **Intake.** Accept signed `TubelineOrder`s from the SDK and the app. Verify the EIP-712 signature, the deadlines, the nonce and the user's balance and Permit2 allowance before an order enters the auction, so couriers only see orders that can actually be opened.
- **Sealed auction.** Send each order only to registered couriers, never to a public mempool. Couriers bid the output they will deliver; the best bid at or above the user's minimum wins. Losing bids are never revealed.
- **Quotes.** Answer "what would 5,000 USDC on Base get me in NVDA right now?" from couriers' standing quotes, so the user can set a sensible minimum before signing.
- **Status.** Track each order from `signed` through `settled` (or `expired` / `refunded`) by watching the settlers on every chain, and push updates to the SDK.

## What it can and can't do

The relay is trusted with order flow, not with funds. It can delay or drop an order (which then expires, with nothing moved), but it cannot move a user's funds, change an order, or lower its minimum: all of that is fixed by the user's signature and enforced by the contracts.

## API surface

| Endpoint | Purpose |
|---|---|
| `POST /quote` | Indicative output for an input, route and size. |
| `POST /orders` | Submit a signed order. |
| `GET /orders/:id` | Order status and its transactions on each chain. |
| `WS /orders/:id/events` | Live status updates. |
| `WS /couriers` | Authenticated courier feed: sealed orders out, bids in. |

Design detail and the auction rules: [`docs/ARCHITECTURE.md`](../../docs/ARCHITECTURE.md#relay-and-auction).
