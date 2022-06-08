pragma solidity 0.7.1;
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
contract UniswapExample {
  address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;
  IUniswapV2Router02 public uniswapRouter;
  address private multiDaiKovan = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
  address private link = 0xa36085F69e2889c224210F603D836748e7dC0088;
  constructor() {
    uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
  }
  function convertEthToDai(uint daiAmount) public payable {
    uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
    uniswapRouter.swapETHForExactTokens{ value: msg.value }(daiAmount, getPathForETHtoDAI(), address(this), deadline);
    
    // refund leftover ETH to user
    (bool success,) = msg.sender.call{ value: address(this).balance }("");
    require(success, "refund failed");
  }
  function swaps(address token1, address token2, uint token1Amount, uint token2Amount) public {
       IERC20(token1).approve(UNISWAP_ROUTER_ADDRESS, token1Amount );
       IERC20(token1).transferFrom(msg.sender, address(this), token1Amount);
       address[] memory path = new address[](2);
       path[0] = token1;
       path[1] = token2;
      uint deadline = block.timestamp + 15;
      uniswapRouter.swapExactTokensForTokens(token1Amount, token2Amount, path, msg.sender, deadline);
  }
  
  function getEstimatedETHforDAI(uint daiAmount) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(daiAmount, getPathForETHtoDAI());
  }
  function getpath() private view returns(address[] memory) {
       address[] memory path = new address[](2);
       path[0] = multiDaiKovan;
    path[1] = link;
    
    
    return path;
  }
  function getPathForETHtoDAI() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = multiDaiKovan;
    
    return path;
  }
    event Log(string message, uint val);
 function addLiquidity(
    address _tokenA,
    address _tokenB,
    uint _amountA,
    uint _amountB
  ) external {
    IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
    IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);
    IERC20(_tokenA).approve(UNISWAP_ROUTER_ADDRESS, _amountA);
    IERC20(_tokenB).approve(UNISWAP_ROUTER_ADDRESS, _amountB);
    (uint amountA, uint amountB, uint liquidity) =
      uniswapRouter.addLiquidity(
        _tokenA,
        _tokenB,
        _amountA,
        _amountB,
        1,
        1,
        address(this),
        block.timestamp + 15
      );
    emit Log("amountA", amountA);
    emit Log("amountB", amountB);
    emit Log("liquidity", liquidity);
  }
  
  function getPathForswapping() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = multiDaiKovan;
    
    return path;
  }
  
  // important to receive ETH
  receive() payable external {}
}
