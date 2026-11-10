# Courier

The reference solver. A courier turns a signed order into a delivery: it bids in the sealed auction, opens the order on the origin chain, delivers on Elysium from its own inventory, and claims repayment once the fill is proven.

## Loop

1. **Quote.** Price each order from live Elysium liquidity and its own inventory, net of gas, the proof message and rebalancing cost.
2. **Bid.** Submit an output it can deliver at or above the user's minimum.
3. **Open.** On winning, call `openFor` on the origin settler: the user's input moves into escrow.
4. **Fill.** Call `fill` on the destination settler: the output goes to the user on Elysium, in one transaction.
5. **Claim.** Once the proof of fill reaches the origin chain, receive the escrowed input.
6. **Rebalance.** Move repaid funds back onto Elysium, ready for the next order.

## Inventory

Every fill spends the courier's funds on Elysium first and is repaid later on the source chain, so inventory flows one way and must be rebalanced continuously. The faster a repaid dollar gets back to Elysium, the less capital a courier needs for the same volume. The courier can source the output token at fill time from on-chain liquidity rather than holding it, which limits its price risk between orders. Elysium's canonical bridge runs only from HyperEVM, so rebalancing from a source chain goes through HyperEVM or another route the courier chooses.

## Safety

- Hot wallets hold only the float for a few hours of fills; the rest sits in a multisig.
- Per-order and per-hour caps, and an automatic stop if a repayment is late or a proof fails.
- It never fills before the origin-chain open is final enough for the route's reorg risk.

## Open courier network

Tubeline runs the first courier, and its code here is the reference. The network is designed to be open: any operator can run a courier, bring their own inventory and compete in the auction; more couriers means tighter prices for users. Registration and requirements are documented with the relay.
