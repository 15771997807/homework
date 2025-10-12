package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	// 1. 连接到 Sepolia 节点
	client, err := ethclient.Dial("https://sepolia.infura.io/v3/a69325388d51440e9aedd75556524657")
	if err != nil {
		log.Fatal(err)
	}

	// 2. 读取发送方私钥
	privateKey, err := crypto.HexToECDSA("0xa169ddd5b584ad3c479c2fc4fd7d330f6ee6b25077fd0e7477d996f6aff12f43")
	if err != nil {
		log.Fatal(err)
	}

	// 3. 获取公钥和地址
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("无法解析公钥")
	}
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)

	// 4. 获取 nonce
	nonce, err := client.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}

	// 5. 设置 gas 参数
	value := big.NewInt(10000000000000000) //0.01 ETH
	gasLimit := uint64(21000)               // 转账固定 gas 限制
	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	// 6. 目标地址
	toAddress := common.HexToAddress("<RECEIVER_ADDRESS>")

	// 7. 构造交易
	tx := types.NewTransaction(nonce, toAddress, value, gasLimit, gasPrice, nil)

	// 8. 签名交易
	chainID, err := client.NetworkID(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)
	if err != nil {
		log.Fatal(err)
	}

	// 9. 广播交易
	err = client.SendTransaction(context.Background(), signedTx)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("交易已发送！哈希: %s\n", signedTx.Hash().Hex())
}
