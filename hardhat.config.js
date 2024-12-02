require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require('solidity-coverage');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
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
    mainnet: {
      url: process.env.ETH_MAINNET_RPC_URL,
      accounts: [process.env.MAINNET_PRIVATE_KEY],
    },
  },
};
