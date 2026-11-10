# Contributing

## Layout

| Path | What | Toolchain |
|---|---|---|
| `contracts/` | Settlement contracts, ERC-7683 interfaces, order types | [Foundry](https://book.getfoundry.sh/) |
| `packages/sdk/` | `@tubeline/sdk` | Node 22, TypeScript |
| `services/relay/` | Order intake, sealed auction, quotes, status | Node 22, TypeScript |
| `services/courier/` | Reference solver | Node 22, TypeScript |
| `apps/web/` | Order entry app | Node 22, TypeScript |
| `docs/` | Design documents | Markdown, Mermaid |

Every directory has its own README explaining what lives there and how it fits the whole.

## Setup

```bash
# TypeScript workspaces
nvm use            # Node 22 (.nvmrc)
npm install
npm run typecheck

# Contracts
curl -L https://foundry.paradigm.xyz | bash && foundryup
cd contracts
forge install foundry-rs/forge-std
forge build
forge test
```

Copy `.env.example` to `.env` for RPC endpoints and deployment keys. Never commit `.env`.

## Rules

- **The order type has one definition, mirrored exactly.** `contracts/src/types/TubelineOrder.sol` and `packages/sdk/src/eip712.ts` must agree field for field, in the same order. A change to one is a change to both, with a test proving the hashes match.
- **Contracts:** every external function has NatSpec. Every state change that moves funds has a test for the success path and for each revert. Invariants listed in `docs/SECURITY-MODEL.md` get invariant tests.
- **Claims:** documentation states what the code does and what is planned, and says which is which.
- **Pull requests** describe what changed and why, link the issue, and pass CI.

## Commit messages

Imperative and specific: `Add origin settler escrow`, not `updates`.
