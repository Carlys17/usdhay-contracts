# usdhay-contracts

Real, working upgradeable stablecoin + savings vault contracts.

- `USDHAY.sol` — upgradeable ERC-20 (UUPS). Owner can mint/burn/pause.
- `sUSDHAY.sol` — upgradeable ERC-4626 vault that takes USDHAY deposits and distributes yield.
- `DeployProxy.sol` — thin helper for Remix-style ERC1967Proxy deployment.
- `script/Deploy.s.sol` — foundry deploy script: deploys impl + proxy for both, links them.
- `test/USDHAY.t.sol` — foundry tests for both contracts (mint/burn/pause, deposit/yield).

## Quick start

```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install OpenZeppelin/openzeppelin-contracts-upgradeable --no-commit
forge build
forge test
cp .env.example .env  # set PRIVATE_KEY
forge script script/Deploy.s.sol --rpc-url $RPC --broadcast
```

## Architecture

```
ERC1967Proxy  →  USDHAY (impl)        # the stablecoin
ERC1967Proxy  →  sUSDHAY (impl)       # the savings vault, asset = USDHAY(proxy)
```

Both are upgradeable (UUPS) so the contract logic can be replaced without
moving the proxy address or the user balances.

## License

MIT
