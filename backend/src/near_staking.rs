use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::collections::UnorderedMap;
use near_sdk::{env, near_bindgen, AccountId, Balance, Promise};

#[near_bindgen]
#[derive(BorshDeserialize, BorshSerialize)]
pub struct StakingContract {
    staking_pool: UnorderedMap<AccountId, StakingInfo>,
    total_staked: Balance,
}

#[derive(BorshDeserialize, BorshSerialize)]
pub struct StakingInfo {
    amount: Balance,
    start_time: u64,
    reward_rate: Balance, // Reward rate per second
}

impl Default for StakingContract {
    fn default() -> Self {
        Self {
            staking_pool: UnorderedMap::new(b"s".to_vec()),
            total_staked: 0,
        }
    }
}

#[near_bindgen]
impl StakingContract {
    // Initialize the contract
    #[init]
    pub fn new() -> Self {
        assert!(!env::state_exists(), "Already initialized");
        Self::default()
    }

    // Stake tokens
    #[payable]
    pub fn stake(&mut self) {
        let amount = env::attached_deposit();
        let account_id = env::predecessor_account_id();
        
        let current_time = env::block_timestamp() / 1_000_000_000; // Convert nanoseconds to seconds
        
        let staking_info = StakingInfo {
            amount,
            start_time: current_time,
            reward_rate: 1, // 1 token per second as reward rate
        };

        self.staking_pool.insert(&account_id, &staking_info);
        self.total_staked += amount;
    }

    // Unstake tokens and calculate rewards
    pub fn unstake(&mut self) -> Promise {
        let account_id = env::predecessor_account_id();
        let staking_info = self.staking_pool.get(&account_id)
            .expect("No staking found for this account");

        let current_time = env::block_timestamp() / 1_000_000_000;
        let staking_duration = current_time - staking_info.start_time;
        
        // Calculate rewards
        let rewards = staking_duration * staking_info.reward_rate;
        let total_amount = staking_info.amount + rewards;

        self.staking_pool.remove(&account_id);
        self.total_staked -= staking_info.amount;

        // Transfer tokens back to the user
        Promise::new(account_id).transfer(total_amount)
    }

    // Get current staking information for a user
    pub fn get_staking_info(&self, account_id: AccountId) -> Option<StakingInfo> {
        self.staking_pool.get(&account_id)
    }

    // Calculate current rewards for a user
    pub fn calculate_rewards(&self, account_id: AccountId) -> Balance {
        let staking_info = self.staking_pool.get(&account_id)
            .expect("No staking found for this account");

        let current_time = env::block_timestamp() / 1_000_000_000;
        let staking_duration = current_time - staking_info.start_time;
        
        staking_duration * staking_info.reward_rate
    }

    // Get total staked amount
    pub fn get_total_staked(&self) -> Balance {
        self.total_staked
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use near_sdk::test_utils::{accounts, VMContextBuilder};
    use near_sdk::{testing_env, MockedBlockchain};

    fn get_context(predecessor_account_id: AccountId) -> VMContextBuilder {
        let mut builder = VMContextBuilder::new();
        builder
            .current_account_id(accounts(0))
            .signer_account_id(predecessor_account_id.clone())
            .predecessor_account_id(predecessor_account_id);
        builder
    }

    #[test]
    fn test_staking() {
        let mut context = get_context(accounts(1));
        testing_env!(context.build());
        
        let mut contract = StakingContract::new();
        
        // Test staking
        testing_env!(context
            .attached_deposit(1000)
            .build());
        contract.stake();
        
        assert_eq!(contract.get_total_staked(), 1000);
        
        // Test getting staking info
        let info = contract.get_staking_info(accounts(1)).unwrap();
        assert_eq!(info.amount, 1000);
        
        // Test reward calculation
        let rewards = contract.calculate_rewards(accounts(1));
        assert!(rewards >= 0);
    }
} 