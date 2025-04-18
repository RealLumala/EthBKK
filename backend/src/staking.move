module 0x1::staking {
    use std::signer;
    use std::string;
    use sui::balance;
    use sui::coin;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// Struct to store staking information for each user
    struct StakingInfo has store {
        amount: u64,
        start_time: u64,
        reward_rate: u64, // Reward rate per second
    }

    /// Struct to store the staking pool
    struct StakingPool has key {
        id: UID,
        staking_pool: table::Table<address, StakingInfo>,
        total_staked: u64,
    }

    /// Initialize the staking pool
    public fun init(ctx: &mut TxContext) {
        let staking_pool = StakingPool {
            id: object::new(ctx),
            staking_pool: table::new(),
            total_staked: 0,
        };
        transfer::share_object(staking_pool);
    }

    /// Stake tokens
    public entry fun stake(
        pool: &mut StakingPool,
        coin: coin::Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let amount = coin::value(&coin);
        let sender = tx_context::sender(ctx);
        let current_time = tx_context::epoch(ctx);

        let staking_info = StakingInfo {
            amount,
            start_time: current_time,
            reward_rate: 1, // 1 token per second as reward rate
        };

        table::add(&mut pool.staking_pool, sender, staking_info);
        pool.total_staked = pool.total_staked + amount;
        coin::destroy_zero(coin);
    }

    /// Unstake tokens and calculate rewards
    public entry fun unstake(
        pool: &mut StakingPool,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let staking_info = table::remove(&mut pool.staking_pool, sender);
        let current_time = tx_context::epoch(ctx);
        let staking_duration = current_time - staking_info.start_time;
        
        // Calculate rewards
        let rewards = staking_duration * staking_info.reward_rate;
        let total_amount = staking_info.amount + rewards;

        pool.total_staked = pool.total_staked - staking_info.amount;

        // Transfer tokens back to the user
        let coin = coin::mint(total_amount, ctx);
        transfer::transfer(coin, sender);
    }

    /// Get current staking information for a user
    public fun get_staking_info(
        pool: &StakingPool,
        user: address
    ): StakingInfo {
        *table::borrow(&pool.staking_pool, user)
    }

    /// Calculate current rewards for a user
    public fun calculate_rewards(
        pool: &StakingPool,
        user: address,
        ctx: &TxContext
    ): u64 {
        let staking_info = table::borrow(&pool.staking_pool, user);
        let current_time = tx_context::epoch(ctx);
        let staking_duration = current_time - staking_info.start_time;
        
        staking_duration * staking_info.reward_rate
    }

    /// Get total staked amount
    public fun get_total_staked(pool: &StakingPool): u64 {
        pool.total_staked
    }
} 