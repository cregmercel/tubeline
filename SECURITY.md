# Security policy

Tubeline's contracts will hold user funds in escrow. We treat every report that could put funds at risk as urgent.

## Reporting a vulnerability

**Never open a public issue for a vulnerability.** Report it privately through GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability) on this repository (Security → Report a vulnerability).

Include what you found, how to reproduce it, and what an attacker could gain. We acknowledge reports promptly and keep you informed until a fix ships. Please allow time for the fix before any public disclosure.

## Scope

- Everything in `contracts/`, and the order types and signing code in `packages/sdk/`.
- The relay and courier services in `services/`, where a flaw could move funds, leak orders before they are filled, or let a fill be credited without a delivery.

## Before mainnet

- The settlement contracts are audited externally before any mainnet deployment; the report is published here.
- A bug bounty opens at mainnet launch, with its terms and rewards published at that time.
- Mainnet starts with per-order caps and a pause on new orders that cannot touch funds already in escrow.

The threat model, trust assumptions and invariants are in [`docs/SECURITY-MODEL.md`](docs/SECURITY-MODEL.md).

## Keys

- Never commit a private key. `.env` and `.env.*` are gitignored; `.env.example` is the template.
- Deployments use a dedicated deployer key. Owner roles move to a multisig after deployment.
- Courier hot wallets hold only the float needed for a few hours of fills; the rest stays in a multisig.
