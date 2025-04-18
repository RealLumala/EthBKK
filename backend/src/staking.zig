const std = @import("std");
const testing = std.testing;

// Staking structure to hold user's staking information
const StakingInfo = struct {
    amount: u64,
    start_time: u64,
    reward_rate: u64, // Reward rate per second
};

// Staking contract structure
const StakingContract = struct {
    staking_pool: std.AutoHashMap(u64, StakingInfo),
    total_staked: u64,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !StakingContract {
        return StakingContract{
            .staking_pool = std.AutoHashMap(u64, StakingInfo).init(allocator),
            .total_staked = 0,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *StakingContract) void {
        self.staking_pool.deinit();
    }

    // Stake tokens
    pub fn stake(self: *StakingContract, user_id: u64, amount: u64) !void {
        const current_time = std.time.timestamp();
        const staking_info = StakingInfo{
            .amount = amount,
            .start_time = @intCast(u64, current_time),
            .reward_rate = 1, // 1 token per second as reward rate
        };

        try self.staking_pool.put(user_id, staking_info);
        self.total_staked += amount;
    }

    // Unstake tokens and calculate rewards
    pub fn unstake(self: *StakingContract, user_id: u64) !u64 {
        const staking_info = self.staking_pool.get(user_id) orelse return 0;
        const current_time = std.time.timestamp();
        const staking_duration = @intCast(u64, current_time) - staking_info.start_time;
        
        // Calculate rewards
        const rewards = staking_duration * staking_info.reward_rate;
        const total_amount = staking_info.amount + rewards;

        _ = self.staking_pool.remove(user_id);
        self.total_staked -= staking_info.amount;

        return total_amount;
    }

    // Get current staking information for a user
    pub fn getStakingInfo(self: *StakingContract, user_id: u64) ?StakingInfo {
        return self.staking_pool.get(user_id);
    }

    // Calculate current rewards for a user
    pub fn calculateRewards(self: *StakingContract, user_id: u64) u64 {
        const staking_info = self.staking_pool.get(user_id) orelse return 0;
        const current_time = std.time.timestamp();
        const staking_duration = @intCast(u64, current_time) - staking_info.start_time;
        
        return staking_duration * staking_info.reward_rate;
    }
};

// Test the staking contract
test "staking contract" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var contract = try StakingContract.init(allocator);
    defer contract.deinit();

    const user_id: u64 = 1;
    const stake_amount: u64 = 1000;

    // Test staking
    try contract.stake(user_id, stake_amount);
    try testing.expectEqual(contract.total_staked, stake_amount);

    // Test getting staking info
    const info = contract.getStakingInfo(user_id).?;
    try testing.expectEqual(info.amount, stake_amount);

    // Test reward calculation
    const rewards = contract.calculateRewards(user_id);
    try testing.expect(rewards >= 0);

    // Test unstaking
    const total_amount = try contract.unstake(user_id);
    try testing.expect(total_amount >= stake_amount);
    try testing.expectEqual(contract.total_staked, 0);
} 