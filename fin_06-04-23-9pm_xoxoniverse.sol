// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
 
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
 
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
 
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

/*
total supply: 250T 
    93% for liquidity
    7% for listings

No Team Token
No Dev Token
No Presale

buy and sell tax (for community)
    auto burn up to max autoburn
    addliquidity and lp are burned automatically

with max amount per wallet in early stage only
whitelist are also for early stage only
blocklist
renounce contract ownership

DEFAULT_ADMIN_ROLE = admin
SETTER_ROLE = used to set settings
LIST_ROLE = blacklist and whitelist 
LIQUIDITY_ROLE = manual liquidity clicker

Stage 0 - initial liquidity, no swap
Stage 1 - swap is for whitelisted only with limit per wallet
Stage 2 - swap is open with limit per wallet
Stage 3 - swap is open without limit, contract ownership is renounced

Stage 0 - initial liquidity
    flaAutBur = false;
    flaLiq = false;
    flaSwa = false;
    flaMaxTokBalPerWal = false;
    staRun = 0;

    maxTokBalPerWal = maxTokBalPerWal = 0;

    feeSelAutBur = 0;
    feeSelLiq = 0;
    feeBuyAutBur = 0;
    feeBuyLiq = 0;

Stage 1 - whitelisted with limit per wallet
    flaAutBur = false;
    flaLiq = false;
    flaSwa = false;
    flaMaxTokBalPerWal = true;
    staRun = 1;

    maxTokBalPerWal = maxTokBalPerWal = (maxSup * 5) / 1000; // 0.5% of maxSup

    feeSelAutBur = 0;
    feeSelLiq = 0;
    feeBuyAutBur = 0;
    feeBuyLiq = 0;

Stage 2 - open with limit per wallet
    flaAutBur = true;
    flaLiq = true;
    flaSwa = true;
    flaMaxTokBalPerWal = true;
    staRun = 2;

    maxTokBalPerWal = maxTokBalPerWal = (maxSup * 5) / 1000; // 0.5% of maxSup

    feeSelAutBur = 2;
    feeSelLiq = 1;
    feeBuyAutBur = 2;
    feeBuyLiq = 1;

Stage 3 - open no limit, contract is renounced
    flaAutBur = true;
    flaLiq = true;
    flaSwa = true;
    flaMaxTokBalPerWal = false;
    staRun = 3;

    maxTokBalPerWal = 0;

    feeSelAutBur = 2;
    feeSelLiq = 1;
    feeBuyAutBur = 2;
    feeBuyLiq = 1;

*/










contract MyPIToken is ERC20, ERC20Burnable, Ownable, Pausable, AccessControl, ReentrancyGuard {
    uint256 public amoForTaxLiq;
    uint256 public totTaxLiq;
    uint256 public totTaxAutBur;

    uint256 public maxSup = 250000000 * 10**decimals(); 
    uint256 public tokForLiq = maxSup * 93 / 100; // 93% of maxSup 
    uint256 public tokForLis = maxSup - tokForLiq; // 7% of maxSup 
    uint256 public maxTokForAutBur = (maxSup * 1) / 1000; // 0.1% of maxSup 
    uint256 public maxTokBalPerWal = (maxSup * 5) / 1000; // 0.5% of maxSup 
    uint256 public forLiqThrHol = (maxSup * 2) / 1000; // 0.2% of maxSup 

    bool private isLiquidity;
    modifier lockTheSwap {
        isLiquidity = true;
        _;
        isLiquidity = false;
    }
    
    bool public flaAutBur;
    bool public flaLiq;
    bool public flaSwa;
    bool public flaMaxTokBalPerWal;

    IUniswapV2Router02 public immutable rou;
    address public rouV2Add;
    address public rouV2Pai;
    address public addForLis;
    address public addForLiq; 
 
    uint256 public staRun = 0;
    uint256 public feeSelAutBur = 0;
    uint256 public feeSelLiq = 0;
    uint256 public feeBuyAutBur = 0;
    uint256 public feeBuyLiq = 0;

    mapping(address => bool) public whiLis;
    mapping(address => bool) public blaLis;

    event eveBurTax(address indexed from, uint256 value);
    event eveLiqTax(address indexed from, uint256 value);
    event eveTra(address indexed from, address indexed to, uint256 value);
    event eveSel(address indexed from, address indexed to, uint256 value);
    event eveBuy(address indexed from, address indexed to, uint256 value);
    event eveAddLiq(uint256 half, uint256 otherhalf);
    event eveStaRun(uint256 status);
    event eveRolGra(bytes32 indexed role, bool account, address indexed sender);
    event eveRolRev(bytes32 indexed role, bool account, address indexed sender);
 
    bytes32 public constant SETTER_ROLE = keccak256("SETTER_ROLE");
    bytes32 public constant LIST_ROLE = keccak256("LIST_ROLE");
    bytes32 public constant LIQUIDITY_ROLE = keccak256("LIQUIDITY_ROLE");

    constructor() ERC20("MyPIToken", "MYPI") {
        rouV2Add = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        addForLis = 0xeC0637b1D865cd4723aFA613e77F444D7281cae6;
        addForLiq = address(this);

        rou = IUniswapV2Router02(rouV2Add);
        rouV2Pai = IUniswapV2Factory(rou.factory()).createPair(address(this), rou.WETH());
    
 
        flaAutBur = false;
        flaLiq = false;
        flaSwa = false;
        flaMaxTokBalPerWal = false;

        whiLis[msg.sender] = true;
        whiLis[address(this)] = true; 

        _mint(msg.sender, tokForLiq);
        _mint(addForLis, tokForLis); 
 
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); 
        _grantRole(SETTER_ROLE, msg.sender);
        _grantRole(LIST_ROLE, msg.sender);
        _grantRole(LIQUIDITY_ROLE, msg.sender);
    } 

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    } 
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    } 

    function addRole(uint256 index, address minter) public onlyRole(DEFAULT_ADMIN_ROLE) { 
        if (index == 1) {
            grantRole(SETTER_ROLE, minter); 
        } else if (index == 2) {
            grantRole(LIST_ROLE, minter);
        } else if (index == 3) {
            grantRole(LIQUIDITY_ROLE, minter);
        } 
    }
    function removeRole(uint256 index, address minter) public onlyRole(DEFAULT_ADMIN_ROLE) { 
        if (index == 1) {
            revokeRole(SETTER_ROLE, minter); 
        } else if (index == 2) {
            revokeRole(LIST_ROLE, minter);
        } else if (index == 3) {
            revokeRole(LIQUIDITY_ROLE, minter);
        } 
    } 
 
    function enableMaximumTokenBalancePerWallet(bool enabled) external onlyRole(SETTER_ROLE) {
        flaMaxTokBalPerWal = enabled;
    }
    function updateMaximumTokenBalancePerWallet(uint256 newMaxTokenBalance) external onlyRole(SETTER_ROLE) {
        maxTokBalPerWal = newMaxTokenBalance;
    } 
    function updateAddressForListings(address newAddress) external onlyRole(SETTER_ROLE) {
        addForLis = newAddress;
    } 
    function updateAddressForLiquidity(address newAddress) external onlyRole(SETTER_ROLE) {
        addForLiq = newAddress;
    } 
 
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(balanceOf(sender) >= amount, "Insufficient balance");
        require(!paused(), "Token transfers are paused");
        uint256 forAutoBurn = 0;
        uint256 forLiquidity = 0;
        bool isSell = recipient == rouV2Pai;
        bool isBuy = sender == rouV2Pai; 
        bool isSwap = flaSwa;
        bool isAutBur = flaAutBur; 
        if (totTaxAutBur >= maxTokForAutBur) { flaAutBur = false; isAutBur = flaAutBur; }
        if (staRun <= 1) {
            if (_isWhitelisted(sender)) { isSwap = true; } 
            if (_isWhitelisted(recipient)) { isSwap = true; } 
            if (isSell) { require(isSwap,"Swap not yet Enabled"); }
            if (isBuy) { require(isSwap,"Swap not yet Enabled"); }
        } else {
            if (isSell) { if (isAutBur) { forAutoBurn = amount * feeSelAutBur / 100; } if (flaLiq) { forLiquidity = amount * feeSelLiq / 100; } } 
            if (isBuy) { if (isAutBur) { forAutoBurn = amount * feeBuyAutBur / 100; } if (flaLiq) { forLiquidity = amount * feeBuyLiq / 100; } }
        }
        if (flaMaxTokBalPerWal && recipient != address(0)) { require( balanceOf(recipient) + amount - forAutoBurn - forLiquidity <= maxTokBalPerWal, "Recipient Balance would Exceed Maximum Allowed" ); } 
        uint256 finalAmount = amount - forAutoBurn - forLiquidity;
        super._transfer(sender, recipient, finalAmount);
        emit eveTra(sender, recipient, finalAmount);
        if (forAutoBurn > 0) {
            _burn(sender, forAutoBurn);
            totTaxAutBur += forAutoBurn;
            emit eveBurTax(sender, forAutoBurn);
        }
        if (forLiquidity > 0) {
            amoForTaxLiq += forLiquidity;
            totTaxLiq += forLiquidity;
            emit eveLiqTax(sender, forAutoBurn);
            super._transfer(sender, addForLiq, forLiquidity);
            emit eveTra(sender, addForLiq, forLiquidity);
        }
    }
 
    function addLiquidityManually() external onlyRole(LIQUIDITY_ROLE) lockTheSwap {
        require(flaLiq, "Liquidity is not Enabled");
        if (amoForTaxLiq >= forLiqThrHol) {
            uint256 half = amoForTaxLiq / 2;
            uint256 otherHalf = amoForTaxLiq - half;

            uint256 initialBalance = address(this).balance;

            swapTokensForEth(otherHalf); 

            uint256 newBalance = address(this).balance - initialBalance;

            addLiquidity(half, newBalance);
            amoForTaxLiq = 0;
            emit eveAddLiq(half, newBalance);

        }
    } 
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = rou.WETH();

        _approve(address(this), address(rou), tokenAmount);

        rou.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(rou), tokenAmount);

        rou.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(0),
            block.timestamp
        );
    }

    function addToWhitelist(address[] calldata addresses) external onlyRole(LIST_ROLE) {
        for (uint256 i = 0; i < addresses.length; i++) {
            whiLis[addresses[i]] = true;
        }
    }
    function removeFromWhitelist(address[] calldata addresses) external onlyRole(LIST_ROLE) {
        for (uint256 i = 0; i < addresses.length; i++) {
            whiLis[addresses[i]] = false;
        }
    }
    function addToBlacklist(address[] calldata addresses) external onlyRole(LIST_ROLE) {
        for (uint256 i = 0; i < addresses.length; i++) {
            blaLis[addresses[i]] = true;
        }
    }
    function removeFromBlacklist(address[] calldata addresses) external onlyRole(LIST_ROLE) {
        for (uint256 i = 0; i < addresses.length; i++) {
            blaLis[addresses[i]] = false;
        }
    } 
    function _isWhitelisted(address account) internal view returns (bool) {
        return whiLis[account];
    }
    function _isBlacklisted(address account) internal view returns (bool) {
        return blaLis[account];
    }
    
    function enableGo0() external onlyRole(SETTER_ROLE) {
        flaAutBur = false;
        flaLiq = false;
        flaSwa = false;
        flaMaxTokBalPerWal = false;
        staRun = 0;

        maxTokBalPerWal = maxTokBalPerWal = 0;

        feeSelAutBur = 0;
        feeSelLiq = 0;
        feeBuyAutBur = 0;
        feeBuyLiq = 0;
        emit eveStaRun(staRun);
    }
    function enableRun1() external onlyRole(SETTER_ROLE) {
        flaAutBur = false;
        flaLiq = false;
        flaSwa = false;
        flaMaxTokBalPerWal = true;
        staRun = 1;

        maxTokBalPerWal = maxTokBalPerWal = (maxSup * 5) / 1000; // 0.5% of maxSup

        feeSelAutBur = 0;
        feeSelLiq = 0;
        feeBuyAutBur = 0;
        feeBuyLiq = 0;
        emit eveStaRun(staRun);
    }
    function enableRun2() external onlyRole(SETTER_ROLE) {
        flaAutBur = true;
        flaLiq = true;
        flaSwa = true;
        flaMaxTokBalPerWal = true;
        staRun = 2;

        maxTokBalPerWal = maxTokBalPerWal = (maxSup * 5) / 1000; // 0.5% of maxSup

        feeSelAutBur = 2;
        feeSelLiq = 4;
        feeBuyAutBur = 2;
        feeBuyLiq = 4;
        emit eveStaRun(staRun);
    }    
    function enableRun3() external onlyRole(SETTER_ROLE) {
        flaAutBur = true;
        flaLiq = true;
        flaSwa = true;
        flaMaxTokBalPerWal = false;
        staRun = 3;

        maxTokBalPerWal = 0;

        feeSelAutBur = 2;
        feeSelLiq = 1;
        feeBuyAutBur = 2;
        feeBuyLiq = 1;
        emit eveStaRun(staRun);
    }

    receive() external payable {}
}