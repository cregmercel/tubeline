# App

Order entry for everyone who doesn't write code: connect a wallet on a source chain, choose what you want on Elysium, set your minimum, sign once.

## Screens

- **Order.** From (chain, token, amount) → to (token on Elysium), with a live quote and the minimum you'll accept. One signature; no approval transaction when the token supports Permit2.
- **Track.** The order's journey (signed, in auction, opened, delivered, settled) with each transaction linked on its chain's explorer.
- **History.** Past orders for the connected wallet.

## Principles

- The user sees the exact minimum they are signing, in the token's units, before they sign.
- No order is ever described as filled until the fill is on Elysium.

Built on [`@tubeline/sdk`](../../packages/sdk/).
