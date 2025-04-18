package main

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// StakingInfo represents the staking information for a user
type StakingInfo struct {
	Amount      int64     `json:"amount"`
	StartTime   time.Time `json:"startTime"`
	RewardRate  int64     `json:"rewardRate"` // Reward rate per second
}

// StakingContract represents the smart contract
type StakingContract struct {
	contractapi.Contract
}

// InitLedger initializes the staking pool
func (s *StakingContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	// Initialize total staked amount
	err := ctx.GetStub().PutState("totalStaked", []byte("0"))
	if err != nil {
		return fmt.Errorf("failed to initialize total staked amount: %v", err)
	}
	return nil
}

// Stake allows a user to stake tokens
func (s *StakingContract) Stake(ctx contractapi.TransactionContextInterface, amount int64) error {
	// Get the client's identity
	clientID, err := ctx.GetClientIdentity().GetID()
	if err != nil {
		return fmt.Errorf("failed to get client identity: %v", err)
	}

	// Create staking info
	stakingInfo := StakingInfo{
		Amount:     amount,
		StartTime:  time.Now(),
		RewardRate: 1, // 1 token per second as reward rate
	}

	// Convert staking info to JSON
	stakingInfoJSON, err := json.Marshal(stakingInfo)
	if err != nil {
		return fmt.Errorf("failed to marshal staking info: %v", err)
	}

	// Store staking info
	err = ctx.GetStub().PutState(clientID, stakingInfoJSON)
	if err != nil {
		return fmt.Errorf("failed to store staking info: %v", err)
	}

	// Update total staked amount
	totalStakedBytes, err := ctx.GetStub().GetState("totalStaked")
	if err != nil {
		return fmt.Errorf("failed to get total staked amount: %v", err)
	}

	var totalStaked int64
	if totalStakedBytes != nil {
		err = json.Unmarshal(totalStakedBytes, &totalStaked)
		if err != nil {
			return fmt.Errorf("failed to unmarshal total staked amount: %v", err)
		}
	}

	totalStaked += amount
	totalStakedJSON, err := json.Marshal(totalStaked)
	if err != nil {
		return fmt.Errorf("failed to marshal total staked amount: %v", err)
	}

	err = ctx.GetStub().PutState("totalStaked", totalStakedJSON)
	if err != nil {
		return fmt.Errorf("failed to update total staked amount: %v", err)
	}

	return nil
}

// Unstake allows a user to unstake tokens and receive rewards
func (s *StakingContract) Unstake(ctx contractapi.TransactionContextInterface) (int64, error) {
	// Get the client's identity
	clientID, err := ctx.GetClientIdentity().GetID()
	if err != nil {
		return 0, fmt.Errorf("failed to get client identity: %v", err)
	}

	// Get staking info
	stakingInfoBytes, err := ctx.GetStub().GetState(clientID)
	if err != nil {
		return 0, fmt.Errorf("failed to get staking info: %v", err)
	}
	if stakingInfoBytes == nil {
		return 0, fmt.Errorf("no staking found for this user")
	}

	var stakingInfo StakingInfo
	err = json.Unmarshal(stakingInfoBytes, &stakingInfo)
	if err != nil {
		return 0, fmt.Errorf("failed to unmarshal staking info: %v", err)
	}

	// Calculate rewards
	stakingDuration := time.Since(stakingInfo.StartTime).Seconds()
	rewards := int64(stakingDuration) * stakingInfo.RewardRate
	totalAmount := stakingInfo.Amount + rewards

	// Delete staking info
	err = ctx.GetStub().DelState(clientID)
	if err != nil {
		return 0, fmt.Errorf("failed to delete staking info: %v", err)
	}

	// Update total staked amount
	totalStakedBytes, err := ctx.GetStub().GetState("totalStaked")
	if err != nil {
		return 0, fmt.Errorf("failed to get total staked amount: %v", err)
	}

	var totalStaked int64
	err = json.Unmarshal(totalStakedBytes, &totalStaked)
	if err != nil {
		return 0, fmt.Errorf("failed to unmarshal total staked amount: %v", err)
	}

	totalStaked -= stakingInfo.Amount
	totalStakedJSON, err := json.Marshal(totalStaked)
	if err != nil {
		return 0, fmt.Errorf("failed to marshal total staked amount: %v", err)
	}

	err = ctx.GetStub().PutState("totalStaked", totalStakedJSON)
	if err != nil {
		return 0, fmt.Errorf("failed to update total staked amount: %v", err)
	}

	return totalAmount, nil
}

// GetStakingInfo returns the staking information for a user
func (s *StakingContract) GetStakingInfo(ctx contractapi.TransactionContextInterface, userID string) (*StakingInfo, error) {
	stakingInfoBytes, err := ctx.GetStub().GetState(userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get staking info: %v", err)
	}
	if stakingInfoBytes == nil {
		return nil, fmt.Errorf("no staking found for this user")
	}

	var stakingInfo StakingInfo
	err = json.Unmarshal(stakingInfoBytes, &stakingInfo)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal staking info: %v", err)
	}

	return &stakingInfo, nil
}

// CalculateRewards calculates the current rewards for a user
func (s *StakingContract) CalculateRewards(ctx contractapi.TransactionContextInterface, userID string) (int64, error) {
	stakingInfo, err := s.GetStakingInfo(ctx, userID)
	if err != nil {
		return 0, err
	}

	stakingDuration := time.Since(stakingInfo.StartTime).Seconds()
	return int64(stakingDuration) * stakingInfo.RewardRate, nil
}

// GetTotalStaked returns the total amount of staked tokens
func (s *StakingContract) GetTotalStaked(ctx contractapi.TransactionContextInterface) (int64, error) {
	totalStakedBytes, err := ctx.GetStub().GetState("totalStaked")
	if err != nil {
		return 0, fmt.Errorf("failed to get total staked amount: %v", err)
	}

	var totalStaked int64
	err = json.Unmarshal(totalStakedBytes, &totalStaked)
	if err != nil {
		return 0, fmt.Errorf("failed to unmarshal total staked amount: %v", err)
	}

	return totalStaked, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&StakingContract{})
	if err != nil {
		fmt.Printf("Error creating staking chaincode: %v", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting staking chaincode: %v", err)
	}
} 