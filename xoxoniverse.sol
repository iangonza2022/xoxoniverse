// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";


library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }
}

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






contract MyPIToken is ERC20, ERC20Burnable, Ownable, Pausable, ReentrancyGuard {
    uint256 public amountForTaxLiquidity;
    uint256 public totalTaxLiquidity;
    uint256 public totalTaxAutoBurn;

    uint256 public maximumSupply = 250000000 * 10**decimals();
    uint256 public tokenomicsForLiquidity = maximumSupply * 93 / 100;
    uint256 public tokenomicsForListings = maximumSupply - tokenomicsForLiquidity;
    uint256 public maximumTokenBalancePerWallet = maximumSupply * 5 / 1000;
    uint256 public forLiquidityThreshold = maximumSupply / 10000;

    bool public flagAutoBurn;
    bool public flagLiquidity;
    bool public flagMaximumTokenBalancePerWallet;

    address public uniswapV2Router;
    address public uniswapV2Pair;
    address public addressForListings;
    address public addressForLiquidity;

    event eventTransfer(address indexed from, address indexed to, uint256 value);

    constructor() ERC20("MyPIToken", "MYPI") {
        uniswapV2Router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        addressForListings = 0xeC0637b1D865cd4723aFA613e77F444D7281cae6;
        addressForLiquidity = address(this);
        uniswapV2Pair = IUniswapV2Factory(IUniswapV2Router02(uniswapV2Router).factory())
            .createPair(address(this), IUniswapV2Router02(uniswapV2Router).WETH());

        flagAutoBurn = false;
        flagLiquidity = false;
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
        uniswapV2Router = newAddress;
    }






function _transfer(
    address sender,
    address recipient,
    uint256 amount
) internal override {
    require(amount > 0, "Transfer amount must be greater than zero");

    // Deduct transfer fees based on the transfer type
    uint256 forAutoBurn = 0;
    uint256 forLiquidity = 0;

    bool isSell = recipient == uniswapV2Pair;
    bool isBuy = sender == uniswapV2Pair;

    if (isSell) {
        if (flagAutoBurn) {
            forAutoBurn = amount * 1 / 100;
        }
        if (flagLiquidity) {
            forLiquidity = amount * 9 / 100;
        }
    } else if (isBuy) {
        if (flagAutoBurn) {
            forAutoBurn = amount * 2 / 100;
        }
        if (flagLiquidity) {
            forLiquidity = amount * 8 / 100;
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








    function enableTaxAutoBurn(bool enabled) external onlyOwner {
        flagAutoBurn = enabled;
    }

    function enableTaxLiquidity(bool enabled) external onlyOwner {
        flagLiquidity = enabled;
    }

    function enableMaximumTokenBalancePerWallet(bool enabled) external onlyOwner {
        flagMaximumTokenBalancePerWallet = enabled;
    }

    receive() external payable {}
}