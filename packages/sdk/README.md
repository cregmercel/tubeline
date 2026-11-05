# @tubeline/sdk

Build, sign and track Tubeline orders from any TypeScript or JavaScript app.

```ts
import { tubeline } from '@tubeline/sdk';

const order = await tubeline.order({
  from: { chain: 'base', token: 'USDC', amount: '5000' },
  to:   { token: 'NVDA', minOut: '26' },
});

order.status;            // 'signed' → 'auction' → 'opened' → 'delivered' → 'settled'
await order.delivered(); // resolves when the courier's fill lands on Robinhood Chain
```

The order client ships with the SDK's first release, alongside the relay. The chains, order types and EIP-712 definitions it is built on are in the package now.

## What's in the package

| Module | Contents |
|---|---|
| `chains.ts` | Robinhood Chain (destination, mainnet and testnet) and the EVM source chains with their ids. |
| `types.ts` | `TubelineOrder`, `TubelineOrderData`, `OrderStatus`, and helpers such as `addressToBytes32`. |
| `eip712.ts` | The order's EIP-712 domain and types, ready for viem's or ethers' `signTypedData`. |
| order client (first release) | Quote, sign, submit and track (`tubeline.order`, above), built on the relay API. |

## Signing an order directly

```ts
import { orderTypedData } from '@tubeline/sdk';

const signature = await walletClient.signTypedData(orderTypedData(order));
```

The user's wallet shows every field of the order, including `minOutputAmount`: the least they will accept on Robinhood Chain.

## One definition, two languages

`ORDER_TYPES` mirrors `TubelineOrderLib.ORDER_TYPE` in [`contracts/src/types/TubelineOrder.sol`](../../contracts/src/types/TubelineOrder.sol) field for field. The parity test in the contracts' test plan (`contracts/test/README.md`) pins this: the SDK and the contract must hash the same order to the same digest, and CI will fail if they don't.

## Development

```bash
npm install          # from the repository root
npm run typecheck
```
