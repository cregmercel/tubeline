# Roadmap

Milestones in order. Each lists what it delivers and what must be true before the next one starts.

## 1. Protocol design ✓

The order format, settlement flow, lifecycle and security model ([ARCHITECTURE.md](ARCHITECTURE.md), [ORDER-LIFECYCLE.md](ORDER-LIFECYCLE.md), [SECURITY-MODEL.md](SECURITY-MODEL.md)). ERC-7683 interfaces and the `TubelineOrder` type in Solidity, mirrored in the SDK.

## 2. Settlement contracts

Origin settler (signature verification, Permit2 escrow, payout on proof, refund after deadline) and destination settler (fill, minimum and deadline enforcement, fill record). Proof-of-fill design chosen. Full unit, fuzz and invariant coverage of the five invariants, plus the SDK parity test.

## 3. Relay and courier

Order intake and validation, the sealed auction, quotes and status. The reference courier: quoting from Robinhood Chain liquidity, open, fill, claim, rebalance, with caps and automatic stops.

## 4. SDK and app

`@tubeline/sdk` released with documentation: quote, sign, submit, track. The order-entry app on top of it.

## 5. Testnet

The whole system on Robinhood Chain testnet and source-chain testnets: real orders, real fills, every failure path exercised (expiry, refund, late proof, paused settler).

## 6. Audit

External audit of the settlement contracts. Findings fixed and re-reviewed. Report published.

## 7. Mainnet

Ethereum, Arbitrum and Base first, with USDC as the input and per-order caps. Bug bounty opens. Deployed addresses listed in [DEPLOYMENTS.md](DEPLOYMENTS.md).

## 8. Every launch chain

Optimism, Polygon, BNB Chain and Avalanche, then Solana through its escrow program, each after its own testing and review.

## 9. Open courier network

Outside couriers register and compete with their own inventory: deeper liquidity, tighter prices, and no single courier in the critical path.
