require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require('@openzeppelin/hardhat-upgrades');
require("solidity-coverage");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
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
    coverage: {
      url: 'http://127.0.0.1:8555',
      gas: 0x1fffffffffffff,
      gasPrice: 0x1,
      baseFee: 1,
      initialBaseFee: 1,
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
    coverage: "./coverage",
    coverageJson: "./coverage.json"
  },
  mocha: {
    timeout: 20000
  }
};
