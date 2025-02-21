// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error SmallFee();

contract Token is ERC721, ERC721URIStorage {

    string constant i_TOKEN_URI = "https://ipfs.io/ipfs/bafkreievgibi55znfubyt7u4zeh45bq3vkh3jy3bsnkpj7edamos4jrepi";

    uint256 constant USDC_PRICE = 1_000_000_0 ; //10$

    address owner = 0x94fD0181973d7304b7654C4c0AdED1b5a140Db7D;

    address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint256 public constant NFT_PRICE_USD = 10 * 1e18; // $10 with 18 decimal precision

    uint private tokenId = 1;

    AggregatorV3Interface priceFeedEth;
    AggregatorV3Interface priceFeedUsdc;

    constructor() ERC721("Token", "TK") {
        /**
        * Network: Sepolia
        * Aggregator: ETH/USD
        * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        * https://docs.chain.link/data-feeds/price-feeds/addresses/?network=ethereum&page=1
        */

        priceFeedEth = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);


        /**
        * Network: Sepolia
        * Aggregator: USDC/USD
        * Address: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
        * https://docs.chain.link/data-feeds/price-feeds/addresses/?network=ethereum&page=1
        */

        priceFeedUsdc = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
    }

    function getNFTPriceInETH() public view returns (uint256 ethAmount) {
        uint256 ethPrice = getLatestETHPrice();
        return (NFT_PRICE_USD / ethPrice) * 1e18;//convert  
    }

    function getLatestETHPrice() public view returns (uint256 price) {
        (, int256 priceRaw, , , ) = priceFeedEth.latestRoundData(); //2500 * 1e18
        require(priceRaw > 0, "Invalid price data");

        return uint256(priceRaw) * 1e10; //  Convert from 8 to 18 decimals
    }

    function buyWithEth() external payable returns(uint) {
        require(msg.value >= getNFTPriceInETH(), SmallFee());

        payable(owner).transfer(msg.value);

        return mint(msg.sender);
    }

    function buyWithUsdc(uint _usdc_amount) external payable returns(uint) {
        IERC20 usdc = IERC20(USDC_ADDRESS);

        require(_usdc_amount >= USDC_PRICE, SmallFee());

        usdc.transferFrom(msg.sender, owner, _usdc_amount);

        return mint(msg.sender);
    }

    function mint(address buyer) private returns(uint) {
        tokenId++;

        ERC721._safeMint(buyer, tokenId);
        ERC721URIStorage._setTokenURI(tokenId, i_TOKEN_URI);

        return tokenId;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

     function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
     }
}

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
