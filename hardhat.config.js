require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require('solidity-coverage');
require('@openzeppelin/hardhat-upgrades');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.9",
      },
      {
        version: "0.8.20",
      },
    ],
  },
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,
    },
    // mainnet: {
    //   url: process.env.ETH_MAINNET_RPC_URL,
    //   accounts: [process.env.MAINNET_PRIVATE_KEY],
    // },
    // rinkeby: {
    //   url: process.env.ETH_RINKEBY_RPC_URL,
    //   accounts: [process.env.RINKEBY_PRIVATE_KEY],
    // }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
};
