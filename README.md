<p align="center">
  <img src="docs/assets/banner.png" alt="Tubeline: one line into Elysium" width="100%">
</p>

<h1 align="center">Tubeline</h1>

<p align="center">
  <strong>One line into Elysium.</strong><br>
  Intent-based cross-chain settlement: sign one order on the chain your funds are on,<br>
  and a courier delivers it on Elysium, at your price or better.
</p>

<p align="center">
  <a href="https://tubeline.space"><strong>tubeline.space</strong></a> · <a href="https://x.com/tubedelivery"><strong>@tubedelivery</strong></a>
</p>

<p align="center">
  <img alt="Status" src="https://img.shields.io/badge/status-in%20development-B08D57?style=flat-square&labelColor=0E0D0B">
  <img alt="Standard" src="https://img.shields.io/badge/orders-ERC--7683-B08D57?style=flat-square&labelColor=0E0D0B">
  <img alt="Signing" src="https://img.shields.io/badge/signing-EIP--712-B08D57?style=flat-square&labelColor=0E0D0B">
  <img alt="Destination" src="https://img.shields.io/badge/destination-Elysium-B08D57?style=flat-square&labelColor=0E0D0B">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-B08D57?style=flat-square&labelColor=0E0D0B">
</p>

---

## The problem

Elysium is "a general-purpose, high-performance L2 for Hyperliquid built by Kinetiq": an Arbitrum Orbit chain that settles to HyperEVM, with HYPE as its gas. The money that wants to get there sits elsewhere: on Ethereum, Arbitrum, Base, Robinhood Chain and a handful of other chains.

Getting from there to here today means bridging by hand. Elysium's canonical bridge runs from HyperEVM only; there is no direct canonical bridge from Ethereum. So the manual route is to bridge to HyperEVM first, then make Elysium's canonical deposit, then swap: several transactions, several fees, network switches, and the hope that nobody trades ahead of you in the public mempool on the way.

## The answer

**Say what you want, not how to get it.**

```
5,000 USDC on Base  →  HYPE on Elysium,  at least 90 HYPE or nothing.
```

(An illustrative order; 90 HYPE is an example figure, not a quote.)

You sign that once. A courier (solver) fills it: Tubeline runs the first one, and outside solvers join after launch to compete for orders. The courier delivers to you on Elysium from their own inventory, in a single transaction, and is repaid from your locked funds on Base only after the delivery is proven. If nobody fills it in time, the order expires and your funds never move.

## Four guarantees, enforced by contract

| | Guarantee | How it is enforced |
|---|---|---|
| **Your price** | You receive your signed minimum or better, or the order expires. | The minimum is inside your EIP-712 signature; the settlement contract will not accept a fill below it. |
| **Sealed** | Your order never touches a public mempool, so no one can trade ahead of it. | Signed orders go to registered couriers through a private auction. |
| **Proven** | A courier is paid only after your delivery is proven. | The origin settler releases escrow only against proof of the fill on Elysium. |
| **Nothing moves** | An unfilled order costs you nothing from Tubeline and leaves your funds where they were. | Gasless orders (Permit2) pull funds only when a courier opens the order to fill it. |

## How it works

```mermaid
sequenceDiagram
    autonumber
    actor U as You (Base)
    participant R as Tubeline relay
    participant C as Courier
    participant O as Origin settler (Base)
    participant D as Destination settler (Elysium)

    U->>R: Sign order: 5,000 USDC → ≥ 90 HYPE (EIP-712, gasless)
    R->>C: Sealed order to registered couriers
    C->>R: Quote: your price or better, your minimum is the floor
    C->>O: openFor(order, signature): 5,000 USDC locked in escrow
    C->>D: fill(orderId): HYPE delivered to you, one transaction, one block
    D-->>O: Proof of fill
    O->>C: Escrow released to the courier
```

Delivery on Elysium is one transaction in one 100 ms block, once a courier fills. That is the delivery leg only; how quickly an order is filled depends on the source chain and the market.

## Architecture

```mermaid
flowchart LR
    subgraph Sources["Source chains"]
        ETH[Ethereum]
        ARB[Arbitrum]
        BASE[Base]
        RH[Robinhood Chain]
        MORE["After launch: Optimism · BNB Chain · Avalanche · Solana"]
    end
    subgraph Tubeline
        SDK["@tubeline/sdk"]
        APP[App]
        RELAY[Relay & private auction]
        COURIER[Courier network]
    end
    subgraph ELY["Elysium"]
        DEST[Destination settler]
        LIQ[On-chain liquidity]
    end
    SDK --> RELAY
    APP --> SDK
    RELAY --> COURIER
    Sources -- "orders open into escrow" --- COURIER
    COURIER -- "fill" --> DEST
    COURIER -. "sources the output token" .- LIQ
    DEST -- "proof of fill" --> Sources
```

| Component | Where | What it does |
|---|---|---|
| Settlement contracts | [`contracts/`](contracts/) | ERC-7683 origin settlers (escrow, released only on proof) on each source chain, and the destination settler on Elysium. |
| SDK | [`packages/sdk/`](packages/sdk/) | `@tubeline/sdk`: build, sign and track orders in a few lines. Shared order types and EIP-712 definitions. |
| Relay | [`services/relay/`](services/relay/) | Receives signed orders, runs the sealed auction between couriers, serves quotes and order status. |
| Courier | [`services/courier/`](services/courier/) | The reference solver: quotes, fills on Elysium, claims repayment, rebalances inventory. |
| App | [`apps/web/`](apps/web/) | Order entry for everyone who doesn't write code. |
| Documentation | [`docs/`](docs/) | Architecture, order lifecycle, security model, roadmap, glossary. |

Read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full design and [`docs/ORDER-LIFECYCLE.md`](docs/ORDER-LIFECYCLE.md) for every state an order passes through.

## Built on open standards

- **[ERC-7683](https://eips.ethereum.org/EIPS/eip-7683)** cross-chain intents: Tubeline orders resolve to the standard `ResolvedCrossChainOrder`, so any ERC-7683 filler can read them.
- **[EIP-712](https://eips.ethereum.org/EIPS/eip-712)** typed signatures: you see exactly what you sign, minimum included.
- **[Permit2](https://github.com/Uniswap/permit2)** for gasless approvals: funds move only when an order is opened.
- **Elysium** (Arbitrum Orbit, settling to HyperEVM) as the one destination, with its 100 ms canonical blocks.

## For developers

```ts
import { tubeline } from '@tubeline/sdk';

const order = await tubeline.order({
  from: { chain: 'base', token: 'USDC', amount: '5000' },
  to:   { token: 'HYPE', minOut: '90' },
});
await order.delivered();
```

The SDK publishes with its documentation. The order types and EIP-712 definitions it is built on are in [`packages/sdk/src/`](packages/sdk/src/) today, and match the contracts field for field.

## Roadmap

- [x] Protocol design: order format, settlement flow, security model
- [x] ERC-7683 interfaces and the Tubeline order type, in Solidity and TypeScript
- [ ] Settlement contracts: origin escrow and destination fill
- [ ] Relay and sealed auction
- [ ] Reference courier
- [ ] SDK release and documentation
- [ ] Elysium testnet
- [ ] External audit
- [ ] Mainnet, bug bounty open from launch
- [ ] Open courier network: outside solvers bring their own inventory

The full plan and what each milestone requires: [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Security

The settlement contracts are audited before mainnet, and a bug bounty opens at launch. The threat model is in [`docs/SECURITY-MODEL.md`](docs/SECURITY-MODEL.md). Report vulnerabilities privately as described in [`SECURITY.md`](SECURITY.md), never in a public issue.

## $TUBE

$TUBE is Tubeline's token on Elysium (chain ID 99901):

```
0xAde5Eb90BF1EC24bFC97d806BDbD338385B80Bcf
```

It is the only $TUBE contract, the same address published on [tubeline.space](https://tubeline.space) and by [@tubedelivery](https://x.com/tubedelivery) on X. Any other address, presale or airdrop claiming to be $TUBE is not ours.

## Repository

```
contracts/          Foundry: ERC-7683 interfaces, order types, settlement contracts
packages/sdk/       @tubeline/sdk (TypeScript)
services/relay/     order intake, sealed auction, quotes, status
services/courier/   reference solver
apps/web/           order entry app
docs/               architecture, order lifecycle, security model, roadmap, glossary
```

Setup, build and test instructions: [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

<sub>Tubeline is independent and is not affiliated with, endorsed by or sponsored by Kinetiq, Hyperliquid or any other network or company named here (among them Robinhood Markets, Inc., whose Robinhood Chain is one of the source chains). Elysium, Kinetiq, Hyperliquid, HyperEVM, HYPE, Robinhood Chain and the other chain names belong to their respective owners and only identify networks. Nothing in this repository is an offer of $TUBE or any other asset, or financial advice.</sub>
