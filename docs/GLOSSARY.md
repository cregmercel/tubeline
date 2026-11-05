# Glossary

| Term | Meaning |
|---|---|
| **Intent / order** | What a user wants, signed: an input on a source chain, an output token on Robinhood Chain, the minimum accepted, and deadlines. Not a route. |
| **Courier** | A solver: an operator with inventory on Robinhood Chain who fills orders and is repaid from escrow. "Courier" in Tubeline's own vocabulary, "solver" or "filler" in ERC-7683's. |
| **Origin chain / source chain** | The chain the user's funds are on, where the order is opened and the input escrowed. |
| **Destination chain** | Robinhood Chain, where the order is filled. |
| **Origin settler** | The contract on a source chain that escrows the input and releases it on proof of fill. |
| **Destination settler** | The contract on Robinhood Chain that accepts a courier's delivery to the user. |
| **Open** | A courier commits to an order on the origin chain; the input moves into escrow. |
| **Fill** | The courier delivers the output to the user on Robinhood Chain. |
| **Proof of fill** | Evidence, delivered to the origin chain, that a specific order was filled correctly. |
| **Settlement** | Releasing the escrowed input to the courier after proof of fill. |
| **Minimum (`minOutputAmount`)** | The least output the user accepts. Signed, and enforced by the destination settler. |
| **Sealed auction** | Couriers bid privately on an order; it never appears in a public mempool. |
| **Rebalancing** | A courier moving repaid funds from source chains back onto Robinhood Chain. |
| **ERC-7683** | The cross-chain intents standard Tubeline's orders and settlers implement. |
| **EIP-712** | Typed structured-data signing: the user's wallet shows every field it signs. |
| **Permit2** | Uniswap's approval contract; lets an order move funds by signature, without an approval transaction per order. |
| **Stock Tokens** | ERC-20 tokens on Robinhood Chain giving exposure to equities and ETFs. Not available to US persons. |
