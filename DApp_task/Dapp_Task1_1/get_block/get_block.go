package main 

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	// 1. 连接到 Infura Sepolia 网络
	client, err := ethclient.Dial("https://sepolia.infura.io/v3/a69325388d51440e9aedd75556524657")
	if err != nil {
		log.Fatalf("连接失败: %v", err)
	}
	defer client.Close()

	//2.指定要查询的区块号
	blockNumber := big.NewInt(1234567) 

	//3.获取区块信息
	block, err := client.BlockByNumber(context.Background(), blockNumber)
	if err != nil {
		log.Fatalf("获取区块失败: %v", err)
	}
	//4.打印区块信息
	fmt.Printf("区块号: %d\n", block.Number().Uint64())
	fmt.Printf("区块哈希: %s\n", block.Hash().Hex())
	fmt.Printf("区块时间戳: %d\n", block.Time())
	fmt.Printf("区块交易数量: %d\n", len(block.Transactions()))
	
}