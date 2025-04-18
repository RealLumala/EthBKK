// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is ReentrancyGuard, Ownable {
    // Struct to store staking information for each user
    struct StakingInfo {
        uint256 amount;
        uint256 startTime;
        uint256 rewardRate; // Reward rate per second
    }

    // State variables
    IERC20 public stakingToken;
    uint256 public totalStaked;
    mapping(address => StakingInfo) public stakingPool;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 rewards);
    event RewardRateUpdated(uint256 newRate);

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    // Stake tokens
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        
        // Transfer tokens from user to contract
        require(
            stakingToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        // Create or update staking info
        StakingInfo storage info = stakingPool[msg.sender];
        if (info.amount > 0) {
            // If user already has staked tokens, calculate and add rewards
            uint256 rewards = calculateRewards(msg.sender);
            info.amount += rewards;
        }

        info.amount += amount;
        info.startTime = block.timestamp;
        info.rewardRate = 1; // 1 token per second as reward rate

        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    // Unstake tokens and receive rewards
    function unstake() external nonReentrant {
        StakingInfo storage info = stakingPool[msg.sender];
        require(info.amount > 0, "No staked tokens");

        uint256 rewards = calculateRewards(msg.sender);
        uint256 totalAmount = info.amount + rewards;

        // Reset staking info
        delete stakingPool[msg.sender];
        totalStaked -= info.amount;

        // Transfer tokens back to user
        require(
            stakingToken.transfer(msg.sender, totalAmount),
            "Token transfer failed"
        );

        emit Unstaked(msg.sender, info.amount, rewards);
    }

    // Calculate current rewards for a user
    function calculateRewards(address user) public view returns (uint256) {
        StakingInfo memory info = stakingPool[user];
        if (info.amount == 0) return 0;

        uint256 stakingDuration = block.timestamp - info.startTime;
        return stakingDuration * info.rewardRate;
    }

    // Get staking information for a user
    function getStakingInfo(address user) external view returns (
        uint256 amount,
        uint256 startTime,
        uint256 rewardRate,
        uint256 currentRewards
    ) {
        StakingInfo memory info = stakingPool[user];
        return (
            info.amount,
            info.startTime,
            info.rewardRate,
            calculateRewards(user)
        );
    }

    // Update reward rate (only owner)
    function updateRewardRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Reward rate must be greater than 0");
        emit RewardRateUpdated(newRate);
    }

    // Emergency withdraw (only owner)
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = stakingToken.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        require(
            stakingToken.transfer(owner(), balance),
            "Token transfer failed"
        );
    }
} 