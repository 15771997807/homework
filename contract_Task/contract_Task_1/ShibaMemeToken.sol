// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SHIB风格代币合约，包含交易税、流动性池集成和交易限制功能
contract ShibaMemeToken {
    // 基础状态变量
    string public name = "Shiba Meme Token";
    string public symbol = "SHIBAMEME";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // 代币持有者映射
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) public allowance;

    // 合约所有者
    address public owner;

    // 交易相关变量
    uint256 public taxFee = 5; // 交易税百分比
    address public taxWallet;  // 交易税收集地址

    // 流动性池相关
    address public liquidityPool; // 流动性池地址
    bool public liquidityAdded;   // 流动性是否已添加

    // 交易限制
    uint256 public maxTxAmount; // 最大交易金额
    uint256 public dailyTransactionLimit; // 每日交易限制
    mapping(address => uint256) public lastTransactionTime; // 上次交易时间
    mapping(address => uint256) public dailyTransactionAmount; // 每日交易额

    // 事件定义
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TaxCollected(address indexed from, uint256 amount, address indexed taxWallet);
    event LiquidityAdded(address indexed provider, uint256 amount);
    event LiquidityRemoved(address indexed provider, uint256 amount);

    // 修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /**
     * @dev 构造函数
     */
    constructor(
        uint256 _totalSupply,
        address _taxWallet,
        uint256 _maxTransactionAmount,
        uint256 _dailyTransactionLimit
    ) {
        owner = msg.sender;
        totalSupply = _totalSupply * 10 ** uint256(decimals);
        _balances[owner] = totalSupply;
        taxWallet = _taxWallet;
        maxTxAmount = _maxTransactionAmount * 10 ** uint256(decimals);
        dailyTransactionLimit = _dailyTransactionLimit * 10 ** uint256(decimals);
        emit Transfer(address(0), owner, totalSupply);
    }

    // 获取账户余额
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 转账函数
    function transfer(address to, uint256 amount) public returns (bool) {
        _checkTransactionLimit(msg.sender, amount);
        _updateDailyTransactionCount(msg.sender);

        require(_balances[msg.sender] >= amount, "Insufficient balance");

        uint256 taxAmount = (amount * taxFee) / 100;
        uint256 netAmount = amount - taxAmount;

        // 扣除发送者余额
        _balances[msg.sender] -= amount;
        // 增加接收者余额
        _balances[to] += netAmount;
        // 税费分配
        _balances[taxWallet] += taxAmount;

        emit Transfer(msg.sender, to, netAmount);
        emit Transfer(msg.sender, taxWallet, taxAmount);
        emit TaxCollected(msg.sender, taxAmount, taxWallet);
        return true;
    }

    // 检查交易限制
    function _checkTransactionLimit(address from, uint256 amount) private view {
        require(amount <= maxTxAmount, "Exceeds max transaction amount");
        require(from != address(0), "Invalid address");
    }

    // 更新每日交易统计
    function _updateDailyTransactionCount(address account) private {
        uint256 currentDay = block.timestamp / 1 days;
        if (lastTransactionTime[account] < currentDay) {
            dailyTransactionAmount[account] = 0;
            lastTransactionTime[account] = currentDay;
        }
        require(
            dailyTransactionAmount[account] + 1 <= dailyTransactionLimit,
            "Exceeds daily transaction limit"
        );
        dailyTransactionAmount[account]++;
    }

    // 添加流动性
    function addLiquidity(uint256 amount) public {
        require(liquidityPool != address(0), "Liquidity pool not set");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[liquidityPool] += amount;

        emit Transfer(msg.sender, liquidityPool, amount);
        emit LiquidityAdded(msg.sender, amount);
    }

    // 移除流动性
    function removeLiquidity(uint256 amount) public onlyOwner {
        require(liquidityPool != address(0), "Liquidity pool not set");
        require(_balances[liquidityPool] >= amount, "Insufficient liquidity pool balance");

        _balances[liquidityPool] -= amount;
        _balances[msg.sender] += amount;

        emit Transfer(liquidityPool, msg.sender, amount);
        emit LiquidityRemoved(msg.sender, amount);
    }

    // 更新交易限制
    function updateTransactionLimits(
        uint256 newMaxTxAmount,
        uint256 newDailyLimit
    ) public onlyOwner {
        maxTxAmount = newMaxTxAmount * 10 ** uint256(decimals);
        dailyTransactionLimit = newDailyLimit * 10 ** uint256(decimals);
    }

    // 获取授权额度
    function getAllowance(address _owner, address spender)
        public
        view
        returns (uint256)
    {
        return allowance[_owner][spender];
    }
}
