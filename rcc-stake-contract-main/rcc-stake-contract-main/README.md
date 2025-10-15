# RCC stake contract

操作流程以及命令

## 拉取项目

```
git clone https://github.com/ProjectsTask/rcc-stake-contract
```

## 安装依赖

```
npm install
```

## 编译

```
npx hardhat compile
```

## 部署 Rcc token

```
npx hardhat ignition deploy ./ignition/modules/Rcc.js
```

部署之后在 terminal 拿到合约地址,比如: `0x264e0349deEeb6e8000D40213Daf18f8b3dF02c3`

## 部署完 Rcc Token,拿以上地址作为 RCCStake 合约的初始化参数,在 RCCStake 中设置

```
const RccToken = "0x264e0349deEeb6e8000D40213Daf18f8b3dF02c3";
```

## 将 stake 合约部署到 sepolia 上

```
npx hardhat run scripts/RCCStake.js --network sepolia
```
