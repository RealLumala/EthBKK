use std::collections::HashMap;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Clone)]
pub struct StakingInfo {
    amount: u64,
    start_time: u64,
    reward_rate: u64, // Reward rate per second
}

pub struct StakingContract {
    staking_pool: HashMap<u64, StakingInfo>,
    total_staked: u64,
}

impl StakingContract {
    pub fn new() -> Self {
        StakingContract {
            staking_pool: HashMap::new(),
            total_staked: 0,
        }
    }

    // Stake tokens
    pub fn stake(&mut self, user_id: u64, amount: u64) -> Result<(), String> {
        let current_time = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_err(|_| "Time went backwards")?
            .as_secs();

        let staking_info = StakingInfo {
            amount,
            start_time: current_time,
            reward_rate: 1, // 1 token per second as reward rate
        };

        self.staking_pool.insert(user_id, staking_info);
        self.total_staked += amount;
        Ok(())
    }

    // Unstake tokens and calculate rewards
    pub fn unstake(&mut self, user_id: u64) -> Result<u64, String> {
        let staking_info = self.staking_pool.get(&user_id)
            .ok_or_else(|| "User not found in staking pool".to_string())?;

        let current_time = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_err(|_| "Time went backwards")?
            .as_secs();

        let staking_duration = current_time - staking_info.start_time;
        let rewards = staking_duration * staking_info.reward_rate;
        let total_amount = staking_info.amount + rewards;

        self.staking_pool.remove(&user_id);
        self.total_staked -= staking_info.amount;

        Ok(total_amount)
    }

    // Get current staking information for a user
    pub fn get_staking_info(&self, user_id: u64) -> Option<&StakingInfo> {
        self.staking_pool.get(&user_id)
    }

    // Calculate current rewards for a user
    pub fn calculate_rewards(&self, user_id: u64) -> Result<u64, String> {
        let staking_info = self.staking_pool.get(&user_id)
            .ok_or_else(|| "User not found in staking pool".to_string())?;

        let current_time = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_err(|_| "Time went backwards")?
            .as_secs();

        let staking_duration = current_time - staking_info.start_time;
        Ok(staking_duration * staking_info.reward_rate)
    }

    // Get total staked amount
    pub fn get_total_staked(&self) -> u64 {
        self.total_staked
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_staking_contract() {
        let mut contract = StakingContract::new();
        let user_id: u64 = 1;
        let stake_amount: u64 = 1000;

        // Test staking
        assert!(contract.stake(user_id, stake_amount).is_ok());
        assert_eq!(contract.get_total_staked(), stake_amount);

        // Test getting staking info
        let info = contract.get_staking_info(user_id).unwrap();
        assert_eq!(info.amount, stake_amount);

        // Test reward calculation
        let rewards = contract.calculate_rewards(user_id).unwrap();
        assert!(rewards >= 0);

        // Test unstaking
        let total_amount = contract.unstake(user_id).unwrap();
        assert!(total_amount >= stake_amount);
        assert_eq!(contract.get_total_staked(), 0);
    }
} 