// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error SmallFee();
error NotEnoughUsdc();

contract Token is ERC721, ERC721URIStorage {

    string TOKEN_URI;

    uint256 constant tokenPrice = 1000; //10$

    address owner = 0x94fD0181973d7304b7654C4c0AdED1b5a140Db7D;

    AggregatorV3Interface priceFeedEth;
    AggregatorV3Interface priceFeedUsdc;

    constructor(string memory _tokenUri) ERC721("Token", "TK") {
        TOKEN_URI = _tokenUri;

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

    function buyWithEth(uint tokenId) external payable returns(uint) {
        (, int256 answer, , , ) = priceFeedEth.latestRoundData();
        uint pr = uint256(answer);

        uint amountUSD  = (msg.value * pr) / 1e18;

        require(amountUSD >= tokenPrice, SmallFee());

        payable(owner).transfer(msg.value);

        return buy(tokenId, msg.sender);
    }

    function buyWithUsdc(uint tokenId, uint _usdc_amount) external payable returns(uint) {
        IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        require(usdc.allowance(msg.sender, address(this)) >= _usdc_amount, NotEnoughUsdc());

        (, int256 answer, , , ) = priceFeedUsdc.latestRoundData();
        uint pr = uint256(answer);

        uint amountUSD  = (_usdc_amount * 1e8) / pr; 

        require(amountUSD >= tokenPrice, SmallFee());

        usdc.transferFrom(msg.sender, owner, _usdc_amount);

        return buy(tokenId, msg.sender);
    }

    function buy(uint tokenId, address buyer) private returns(uint) {
        ERC721._safeMint(buyer, tokenId);
        ERC721URIStorage._setTokenURI(tokenId, TOKEN_URI);

        return tokenId;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }


     function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        ERC721._burn(tokenId);
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
