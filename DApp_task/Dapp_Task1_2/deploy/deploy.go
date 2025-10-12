package main

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"crypto/ecdsa" 

	"Dapp_Task1_2/counter"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	client, err := ethclient.Dial("https://sepolia.infura.io/v3/a69325388d51440e9aedd75556524657")
	if err != nil {
		log.Fatal(err)
	}

	privateKey, err := crypto.HexToECDSA("a169ddd5b584ad3c479c2fc4fd7d330f6ee6b25077fd0e7477d996f6aff12f43")
	if err != nil {
		log.Fatal(err)
	}

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("无法解析公钥")
	}
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)

	nonce, err := client.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}

	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	auth, err := bind.NewKeyedTransactorWithChainID(privateKey, big.NewInt(11155111)) 
	if err != nil {
		log.Fatal(err)
	}
	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(0)
	auth.GasLimit = uint64(300000)
	auth.GasPrice = gasPrice

	// 部署合约
	address, tx, _, err := counter.DeployCounter(auth, client)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("合约部署交易哈希:", tx.Hash().Hex())
	fmt.Println("合约地址:", address.Hex())
}
