# BaseFeeToken

## Motivation

- Ethereum is introducing a BASEFEE parameter in EIP 1559
- BASEFEE is unpredictable, users cannot plan ahead
- A token pegged to BASEFEE can be used as a hedge
- Beyond that, use cases like metatransactions are better denominated in terms of BASEFEE and can use the token as the means of exchange

## Design

### Minting
- Users lock X ETH in a contract and mint Y BaseFeeTokens where
    `X / Y >= C * BASEFEE`, C is the collateralization ratio
- Owner can add/remove from the stash at any time as long as the above condition is satisfied
- The stash can be liquidated at any time by the owner by paying back Y BaseFeeTokens and receiving X ETH in exchange
- If `X / Y` is ever lower than `C * BASEFEE`, the stash is undercollateralized and can be liquidated by anybody
    - Exact method (e.g. FCFS, auctions, etc) yet to be determined
- No oracles needed anywhere, `BASEFEE` is available in the EVM directly
- `BASEFEE` can theoretically double/halve in 6 blocks, C needs to be large enough to cover a reasonable liquidation window of N blocks

### Trading
- BaseFeeTokens can trade against ETH for users who want to use it but do not want to manage stashes themselves
- Order matching exchanges work fine
- Uniswap pools are painful since miners can easily manipulate the BASEFEE up/down and drain liquidity every time
    - The price discovery aspect of uniswap (essentially what we get in return by allowing liquidity draining on price movements) is wholly unnecessary _in the long term_, its simply available as the `BASEFEE` param in the EVM
    - It is still useful in the short term to absorb liquidity shocks
- Smarter oracle-less AMM pools are needed which allow uniswap like movements, but also ground the price in the `BASEFEE` parameter somehow to minimize the liquidity draining
    - Need to figure out exact mechanisms
