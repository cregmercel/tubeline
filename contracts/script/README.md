# Deployment scripts

Foundry scripts that deploy the settlers and hand their owner roles to a multisig.

```bash
forge script script/<Script>.s.sol --rpc-url robinhood_testnet --broadcast --verify
```

- Keys come from `.env` (`DEPLOYER_PRIVATE_KEY`), never from the command line or a committed file.
- Every deployment to a real network writes `broadcast/<script>/<chainId>/`; those records are committed. Local-chain runs (31337) are gitignored.
- Order of deployment: destination settler on Robinhood Chain first, then an origin settler per source chain pointing at it, then ownership to the multisig. Each step verifies the previous one on-chain before continuing.
- Addresses of every deployment are listed in [`docs/DEPLOYMENTS.md`](../../docs/DEPLOYMENTS.md).
