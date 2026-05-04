<<<<<<< HEAD
## Foundry
=======
## Simple cross-chain bridge between two EVM networks.
            
            |xx|              x|   ~
            |xx|      ~      |x|
            |xx|        ~    |x| 
            |xx|             |x|                     If you ever use this code,
        ============|===============|===--            please, star this repo!
       ~~~~~|xx|~~~~~~~~~~~~~|x|~~~ ~~  ~   ~ ~~~  ~~ ~~~~ ~  ~~~  ~    ~~~  ~~~   ~~ 
### Introduction
>>>>>>> 2c9bb205ed88ed60d29f9bda6f66a62cb61ae31c

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

<<<<<<< HEAD
## Documentation

https://book.getfoundry.sh/
=======
### What you won't find in this repo:

The communication between contracts on different networks is up to a network of off-chain nodes. You can find them in original hackathon repo, linked above. There, it is built on Golang language, however, you can build your own version on any language - just make it run in docker container and make sure you understand that for mainnet version you will need independent operators network.

### Finally, what will the final system built with these smart contracts look like:

<img width="2000" height="646" alt="image" src="https://github.com/user-attachments/assets/79f9925b-dcf0-4564-9b80-7599b259aff4" />
>>>>>>> 2c9bb205ed88ed60d29f9bda6f66a62cb61ae31c

## Usage

### Build

<<<<<<< HEAD
```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
=======
_**Note # 2**: only up to 5% of code were written by the ai agents, and even this small contribution was carefully verified._

_**Note # 3**: do use this code for production before you conduct extra security checks._

>>>>>>> 2c9bb205ed88ed60d29f9bda6f66a62cb61ae31c
