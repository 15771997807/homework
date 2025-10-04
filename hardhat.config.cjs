// hardhat.config.cjs
require("hardhat-deploy");
require("@nomicfoundation/hardhat-toolbox-viem"); // 如果用不到可以删掉

module.exports = {
  solidity: "0.8.20",
  namedAccounts: {
    deployer: 0,
  },
  paths: {
    deploy: "deploy",
    tests: "test",
  },
};
