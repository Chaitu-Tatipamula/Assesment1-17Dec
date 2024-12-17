// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/// @title BLS Token Contract
contract BLSToken is ERC20, Ownable(msg.sender) {
    constructor() ERC20("Blume Liquid Staking Token", "BLS") {
        _mint(msg.sender, 1_000_000 * 10**decimals());
    }
}

/// @title stBLS Token Contract
contract StakedBLSToken is ERC20, Ownable(msg.sender) {
    address public stakingContract;

    constructor() ERC20("Staked BLS Token", "stBLS") {}

    function setStakingContract(address _stakingContract) external onlyOwner{
        require(stakingContract == address(0), "Staking contract already set");
        require(_stakingContract != address(0), "Invalid staking contract address");
        stakingContract = _stakingContract;
    }

    /// @notice Mint stBLS tokens (only callable by the staking contract)
    function mint(address to, uint256 amount) external {
        require(msg.sender == stakingContract, "Only staking contract can mint");
        _mint(to, amount);
    }

    /// @notice Burn stBLS tokens (only callable by the staking contract)
    function burn(address from, uint256 amount) external {
        require(msg.sender == stakingContract, "Only staking contract can burn");
        _burn(from, amount);
    }
}

/// @title Blume Liquid Staking Contract
contract BlumeLiquidStaking {
    BLSToken public blsToken;
    StakedBLSToken public stakedBlsToken;

    uint256 public totalStaked;

    mapping(address => uint256) public stakedBalances;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(BLSToken _blsToken, StakedBLSToken _stakedBlsToken) {
        blsToken = _blsToken;
        stakedBlsToken = _stakedBlsToken;
    }

    /// @notice Stake BLS tokens to receive stBLS tokens
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        blsToken.transferFrom(msg.sender, address(this), amount);
        stakedBlsToken.mint(msg.sender, amount);
        totalStaked += amount;
        stakedBalances[msg.sender] += amount;

        emit Staked(msg.sender, amount);
    }

    /// @notice Unstake stBLS tokens to receive BLS tokens
    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        stakedBlsToken.burn(msg.sender, amount);
        blsToken.transfer(msg.sender, amount);

        totalStaked -= amount;
        stakedBalances[msg.sender] -= amount;

        emit Unstaked(msg.sender, amount);
    }
}
