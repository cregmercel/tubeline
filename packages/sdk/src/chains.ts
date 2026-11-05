/**
 * Chains Tubeline settles between. Robinhood Chain is the one destination; every other chain is a source.
 * EVM chain ids are the networks' own. Solana is a source too, through its own escrow program, and has no
 * EVM chain id, so it is listed separately.
 */

/** The destination: Robinhood Chain mainnet (Arbitrum Orbit, 100 ms blocks). */
export const ROBINHOOD_CHAIN = { id: 4663, name: 'Robinhood Chain' } as const;

/** Robinhood Chain's public testnet. */
export const ROBINHOOD_CHAIN_TESTNET = { id: 46630, name: 'Robinhood Chain Testnet' } as const;

/** EVM source chains, keyed by the short name the SDK accepts (`from: { chain: 'base' }`). */
export const SOURCE_CHAINS = {
  ethereum: { id: 1, name: 'Ethereum' },
  arbitrum: { id: 42161, name: 'Arbitrum' },
  base: { id: 8453, name: 'Base' },
  optimism: { id: 10, name: 'Optimism' },
  polygon: { id: 137, name: 'Polygon' },
  bnb: { id: 56, name: 'BNB Chain' },
  avalanche: { id: 43114, name: 'Avalanche' },
} as const;

export type SourceChain = keyof typeof SOURCE_CHAINS;

/** Looks up a source chain by its short name. */
export function sourceChain(name: SourceChain): (typeof SOURCE_CHAINS)[SourceChain] {
  return SOURCE_CHAINS[name];
}
