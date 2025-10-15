const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const { ethers, upgrades } = require("hardhat");

module.exports = buildModule("RccTokenModule", (m) => {
  // 部署 RccToken 合约，传入初始持有者地址作为参数
  const rccToken = m.contract("RccToken");
  return { rccToken };
});
