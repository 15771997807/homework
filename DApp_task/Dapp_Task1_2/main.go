package main

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"crypto/ecdsa"

	"Dapp_Task1_2/counter"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	// 1. 连接到 Infura Sepolia 节点
	client, err := ethclient.Dial("https://sepolia.infura.io/v3/a69325388d51440e9aedd75556524657")
	if err != nil {
		log.Fatal(err)
	}

	// 2. 读取私钥（测试账户）
	privateKey, err := crypto.HexToECDSA("a169ddd5b584ad3c479c2fc4fd7d330f6ee6b25077fd0e7477d996f6aff12f43")
	if err != nil {
		log.Fatal(err)
	}

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("无效公钥")
	}
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)

	// 3. 创建授权事务 (Transactor)
	nonce, _ := client.PendingNonceAt(context.Background(), fromAddress)
	gasPrice, _ := client.SuggestGasPrice(context.Background())
	auth, _ := bind.NewKeyedTransactorWithChainID(privateKey, big.NewInt(11155111)) 
	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(0)
	auth.GasLimit = uint64(300000)
	auth.GasPrice = gasPrice

	// 4. 加载已部署的合约
	contractAddress := common.HexToAddress("0xE354ef9D9abbd024084cf9d930d132954B651461")
	counterInstance, err := counter.NewCounter(contractAddress, client)
	if err != nil {
		log.Fatal(err)
	}

	// 5. 调用 increment() 增加计数
	tx, err := counterInstance.Increment(auth)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("执行 increment() 的交易哈希:", tx.Hash().Hex())

	// 6. 调用 view 函数 getCount()
	count, err := counterInstance.GetCount(nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("当前计数值:", count)
}
