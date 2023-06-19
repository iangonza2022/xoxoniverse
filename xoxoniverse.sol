// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
 
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

Stealth Launch
No Team Token
No Dev Token
No Presale
With Taxes (but taxes for the benefit the community) 
With Max Amount per Wallet (in early stage only)
Whitelist (in early stage only)
Blocklist (to remove some bots)
Renounced Contract Ownership (on the stage 3)
setter = they can stages and manage blocklisted accounts for security purposes

buy and sell tax 
    auto burn up to max autoburn
    addliquidity and lp are burned automatically


Stage 0 - initial liquidity, no swap
Stage 1 - swap is for whitelisted only with limit per wallet
Stage 2 - swap is open with limit per wallet
Stage 3 - swap is open without limit, contract ownership is renounced

Stage 0 - initial liquidity
        flaAutBur = false;
        flaLiq = false;
        flaSwa = false;
        flaMaxTokBalPerWal = false;
        staGo = 0;

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
        staGo = 1;

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
        staGo = 2;

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
        staGo = 3;

        maxTokBalPerWal = 0;

        feeSelAutBur = 2;
        feeSelLiq = 1;
        feeBuyAutBur = 2;
        feeBuyLiq = 1;
*/




contract MyPIToken is ERC20, ERC20Burnable, Ownable, Pausable, ReentrancyGuard {
    uint256 public amountForTaxLiquidity;
    uint256 public totalTaxLiquidity;
    uint256 public totalTaxAutoBurn;

    uint256 public maximumSupply = 250000000 * 10**decimals();
    uint256 public tokenomicsForLiquidity = maximumSupply * 93 / 100;
    uint256 public tokenomicsForListings = maximumSupply - tokenomicsForLiquidity;
    uint256 public maximumTokenBalancePerWallet = maximumSupply * 5 / 1000;
    uint256 public forLiquidityThreshold = maximumSupply / 10000;

    bool private zIsLiquidity;
    modifier mLockTheSwap {
        zIsLiquidity = true;
        _;
        zIsLiquidity = false;
    }
    
    bool public flagAutoBurn;
    bool public flagLiquidity;
    bool public flagSwap;
    bool public flagMaximumTokenBalancePerWallet;

    IUniswapV2Router02 public immutable router;
    address public uniswapV2RouterAddress;
    address public uniswapV2Pair;
    address public addressForListings;
    address public addressForLiquidity;

    uint public goStatus = 0;

    uint256 public feeSellAutoBurn = 2;
    uint256 public feeSellLiquidity = 8;
    uint256 public feeBuyAutoBurn = 1;
    uint256 public feeBuyLiquidity = 4;

    mapping(address => bool) public whitelist;
    mapping(address => bool) public blacklist;

    event eventTransfer(address indexed from, address indexed to, uint256 value);
    event eventAddLiquidity(uint256 value);

    constructor() ERC20("MyPIToken", "MYPI") {
        uniswapV2RouterAddress = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        addressForListings = 0xeC0637b1D865cd4723aFA613e77F444D7281cae6;
        addressForLiquidity = address(this);

        router = IUniswapV2Router02(uniswapV2RouterAddress); 
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
 
        flagAutoBurn = false;
        flagLiquidity = false;
        flagSwap = false;
        flagMaximumTokenBalancePerWallet = false;

        _mint(msg.sender, tokenomicsForLiquidity);
        _mint(addressForListings, tokenomicsForListings); 
    }

    function updateMaximumTokenBalancePerWallet(uint256 newMaxTokenBalance) external onlyOwner {
        maximumTokenBalancePerWallet = newMaxTokenBalance;
    }

    function updateAddressForListings(address newAddress) external onlyOwner {
        addressForListings = newAddress;
    }

    function updateAddressForLiquidity(address newAddress) external onlyOwner {
        addressForLiquidity = newAddress;
    }

    function updateAddressRouter(address newAddress) external onlyOwner {
        uniswapV2RouterAddress = newAddress;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlacklisted(sender), "Sender is Blacklisted");
        require(!_isBlacklisted(recipient), "Recipient is Blacklisted");

        // Deduct transfer fees based on the transfer type
        uint256 forAutoBurn = 0;
        uint256 forLiquidity = 0;

        bool isSell = recipient == uniswapV2Pair;
        bool isBuy = sender == uniswapV2Pair; 
        bool isSwap = flagSwap;
        bool isWhiteListed = false;

        if (goStatus == 0 ) {
            if (_isWhitelisted(sender)) { 
                isSwap = true; isWhiteListed = true; 
            } 
            require(isSwap, "Swap not yet Enabled");
        } else {
            if (isSell) {
                require(isSwap, "Swap not yet Enabled");
                if (flagAutoBurn) {
                    forAutoBurn = amount * feeSellAutoBurn / 100;
                }
                if (flagLiquidity) {
                    forLiquidity = amount * feeSellLiquidity / 100;
                } 
            } else if (isBuy) {
                require(isSwap, "Swap not yet Enabled");
                if (flagAutoBurn) {
                    forAutoBurn = amount * feeBuyAutoBurn / 100;
                }
                if (flagLiquidity) {
                    forLiquidity = amount * feeBuyLiquidity / 100;
                } 
            } 
        }

        if (flagMaximumTokenBalancePerWallet && recipient != address(0)) {
            require(
                balanceOf(recipient) + amount - forAutoBurn - forLiquidity <= maximumTokenBalancePerWallet,
                "Recipient balance would exceed maximum allowed"
            );
        } 

        uint256 finalAmount = amount - forAutoBurn - forLiquidity;

        super._transfer(sender, recipient, finalAmount);
        emit eventTransfer(sender, recipient, finalAmount);

        if (forAutoBurn > 0) {
            _burn(sender, forAutoBurn);
            totalTaxAutoBurn += forAutoBurn;
        }

        if (forLiquidity > 0) {
            amountForTaxLiquidity += forLiquidity;
            totalTaxLiquidity += forLiquidity;

            super._transfer(sender, addressForLiquidity, forLiquidity);
            emit eventTransfer(sender, addressForLiquidity, forLiquidity);
        }
    }

    function addToWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = true;
        }
    }

    function removeFromWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = false;
        }
    }

    function addToBlacklist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            blacklist[addresses[i]] = true;
        }
    }

    function removeFromBlacklist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            blacklist[addresses[i]] = false;
        }
    }

    function _isWhitelisted(address account) internal view returns (bool) {
        return whitelist[account];
    }

    function _isBlacklisted(address account) internal view returns (bool) {
        return blacklist[account];
    }
    
    function enableTaxAutoBurn(bool enabled) external onlyOwner {
        flagAutoBurn = enabled;
    }

    function enableTaxLiquidity(bool enabled) external onlyOwner {
        flagLiquidity = enabled;
    }

    function enableMaximumTokenBalancePerWallet(bool enabled) external onlyOwner {
        flagMaximumTokenBalancePerWallet = enabled;
    }

    function enableGo0() external onlyOwner {
        flagAutoBurn = false;
        flagLiquidity = false;
        flagSwap = false;
        flagMaximumTokenBalancePerWallet = false;
        goStatus = 0;

        maximumTokenBalancePerWallet = 0;

        feeSellAutoBurn = 0;
        feeSellLiquidity = 0;
        feeBuyAutoBurn = 0;
        feeBuyLiquidity = 0;
    }

    function enableGo1() external onlyOwner {
        flagAutoBurn = true;
        flagLiquidity = true;
        flagSwap = true;
        flagMaximumTokenBalancePerWallet = false;
        goStatus = 100;

        maximumTokenBalancePerWallet = 0;

        feeSellAutoBurn = 2;
        feeSellLiquidity = 4;
        feeBuyAutoBurn = 2;
        feeBuyLiquidity = 4;
    }

    function enableGo2() external onlyOwner {
        flagAutoBurn = true;
        flagLiquidity = true;
        flagSwap = true;
        flagMaximumTokenBalancePerWallet = false;
        goStatus = 200;

        maximumTokenBalancePerWallet = 0;

        feeSellAutoBurn = 2;
        feeSellLiquidity = 1;
        feeBuyAutoBurn = 2;
        feeBuyLiquidity = 1;
    }

    receive() external payable {}
}