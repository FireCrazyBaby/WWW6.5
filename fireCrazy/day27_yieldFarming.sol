// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 简易收益耕作合约 (YieldFarming)
 * @notice 实现代币质押、按秒计息及奖励提取功能
 */
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract YieldFarming {
    struct StakerInfo {
        uint256 stakedAmount;   // 用户当前质押的代币数量
        uint256 rewardDebt;     // 累积但尚未领取的奖励
        uint256 lastUpdateTime; // 上次计算奖励的时间戳
    }

    IERC20 public stakingToken; // 质押代币合约地址
    IERC20 public rewardToken;  // 奖励代币合约地址
    uint256 public rewardRatePerSecond; // 每单位质押代币每秒产生的奖励率

    mapping(address => StakerInfo) public stakers;

    constructor(address _stake, address _reward, uint256 _rate) {
        stakingToken = IERC20(_stake);
        rewardToken = IERC20(_reward);
        rewardRatePerSecond = _rate;
    }

    /**
     * @dev 内部函数：更新特定用户的奖励账本
     */
    function _updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];
        
        if (staker.stakedAmount > 0) {
            // 奖励计算公式：质押量 * 奖励率 * 时间差
            uint256 timeElapsed = block.timestamp - staker.lastUpdateTime;
            uint256 pending = staker.stakedAmount * rewardRatePerSecond * timeElapsed;
            staker.rewardDebt += pending;
        }
        
        // 无论是否有质押，都更新时间戳以防止时间跨度重复计算
        staker.lastUpdateTime = block.timestamp;
    }

    /**
     * @dev 质押代币
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0");
        
        _updateRewards(msg.sender);
        
        // 转移代币到本合约 (需用户先授权)
        bool success = stakingToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Stake transfer failed");
        
        stakers[msg.sender].stakedAmount += amount;
    }

    /**
     * @dev 提取所有已累积的奖励
     */
    function claimRewards() external {
        _updateRewards(msg.sender);
        
        uint256 reward = stakers[msg.sender].rewardDebt;
