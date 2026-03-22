// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. 导入 Chainlink 的接口（就像导入电话簿）
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    // 声明一个接口变量，用来存储预言机合约的地址
    AggregatorV3Interface internal priceFeed;

    /**
     * 网络: Sepolia 测试网
     * 聚合器: ETH/USD
     * 地址: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor() {
        // 在构造函数里，指定“打电话”给谁（初始化预言机地址）
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    /**
     * 核心功能：获取最新价格并返回一个 18 位精度的“标准价格”
     */
    function getLatestPrice() public view returns (uint256) {
        // 2. 调用预言机，获取数据。我们只需要第二个参数 price
        (
            /* uint80 roundID */,
            int price,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();

        // 3. 将 int 转为 uint256，并进行精度对齐（补齐到 18 位）
        // 因为 Chainlink 默认是 8 位，所以补 10 位（1e10）
        return uint256(price) * 1e10;
    }

    /**
     * 实战转换：输入 ETH 数量（18位），输出总美金价值（18位）
     */
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getLatestPrice(); // 这里拿到的是补齐后的 18 位单价
        
        // 4. 职业写法：先乘后除
        // (18位数量 * 18位单价) / 1e18 = 18位结果
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        
        return ethAmountInUsd;
    }
}
