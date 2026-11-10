# Tests

| Kind | Naming | What it covers |
|---|---|---|
| Unit | `*.t.sol` | Every external function: the success path and each revert. |
| Fuzz | `testFuzz_*` | Order fields, amounts and deadlines across their full ranges. |
| Invariant | `invariant_*` | The settler invariants in `src/settlers/README.md`, under random sequences of open, fill, prove, refund and pause. |
| Fork | `*Fork*.t.sol` | The full lifecycle against live Elysium mainnet contracts (Permit2, tokens), on a local fork. |
| Parity | `OrderParity.t.sol` | The EIP-712 hash of a fixed order equals the hash the SDK computes for it, so contracts and SDK never drift. |

```bash
forge test                                   # unit, fuzz, invariant
FOUNDRY_PROFILE=ci forge test                # deeper fuzz and invariant runs
forge test --match-contract Fork --fork-url $RPC_ELYSIUM   # a local fork of mainnet: nothing is sent
```
