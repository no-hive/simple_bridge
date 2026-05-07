![License](https://img.shields.io/github/license/no-hive/simple_bridge?style=flat)
![Last Commit](https://img.shields.io/github/last-commit/no-hive/simple_bridge?style=flat)
![Commit Count](https://img.shields.io/github/commit-activity/t/no-hive/simple_bridge?style=flat)
![Testnet](https://img.shields.io/badge/testnet-untested-darkred?style=flat)
![Mainnet](https://img.shields.io/badge/mainnet-untested-darkred?style=flat)

## Simple cross-chain bridge between two EVM networks.
            
            |xx|              x|   ~
            |xx|      ~      |x|
            |xx|        ~    |x| 
            |xx|             |x|                     If you ever use this code,
        ============|===============|===--            please, star this repo!
       ~~~~~|xx|~~~~~~~~~~~~~|x|~~~ ~~  ~   ~ ~~~  ~~ ~~~~ ~  ~~~  ~    ~~~  ~~~   ~~ 
### Introduction

This code is the improved version of [capebridge](https://github.com/cape4labs/capebridge)'s smart contracts. This project was built for the hackathon, and due to strict time constraints during the hackathon we built it for, the initial implementation lacks everything besides the basic functionality. That's why after the hackathon, I began rewriting the contracts as a learning exercise.

### So what will you find in this repo?

Two smart contracts that can operate between any EVM-compatible L1 and L2 networks. They work with existing tokens and does not use any minting or burning mechanics, that produces smth often called "wrapped tokens". 

### What you won't find in this repo:

The communication between contracts on different networks is up to a network of off-chain nodes. You can find them in original hackathon repo, linked above. There, it is built on Golang language, however, you can build your own version on any language - just make it run in docker container and make sure you understand that for mainnet version you will need independent operators network.

### Finally, what will the final system built with these smart contracts look like:

<img width="2000" height="646" alt="image" src="https://github.com/user-attachments/assets/79f9925b-dcf0-4564-9b80-7599b259aff4" />

### Extra comments

_**Note # 1**: Most of NatSpec comments in the code were written by the ai agents._

_**Note # 2**: only up to 5% of code were written by the ai agents, and even this small contribution was carefully verified._

_**Note # 3**: do use this code for production before you conduct extra security checks._

