// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NftAuction
{

    //结构体
   struct Auction{
  // 卖家
  address seller;
  // 拍卖持续时间
   uint256 duration;

   // 起始价格
   uint256 startPrice;
   //开始时间
   uint256 startTime;   
   // 是否结束
   bool ended;
   // 最高出价者
   address highestBidder;
   // 最高价格
   uint256 highestBid;

   //NFT合约地址
   address nftContract;
   //NFT ID
   uint256 tokenId;  

   }
   //状态变量
   mapping (uint256 => Auction) public auctions;
   //下一个拍卖ID
   uint256 public nextAuctionId;
   //管理员地址
   address public admin;

   constructor(){
      admin=msg.sender;
   }
   //创建拍卖
   function createAuction(uint256 _duration,uint256 _startPrice,address _nftAddress,uint256 _tokenId)  public {
      //只有管理员才可以创建拍卖
      require(msg.sender==admin,"only admin can create auctions");
      //检查参数
      // _validateAuctionParameters(_duration,_startPrice);
      require(_duration>1000*60,"Duration must be greater than 0");
      require(_startPrice>0,"Start price must be greater than 0");

      //转移到NFT合约
      IERC721(_nftAddress).approve(address(this),_tokenId);   

      auctions[nextAuctionId]=Auction({
         seller:msg.sender,
         duration:block.timestamp+_duration,
         startPrice:_startPrice,
         ended:false,
         highestBidder:address(0),
         highestBid:0,
         startTime:block.timestamp,
         nftContract:_nftAddress,
         tokenId:_tokenId
      });
      nextAuctionId++;
   }

   //买家参与买单
   function placeBid(uint256 _auctionId)external payable{
      Auction storage auction=auctions[_auctionId];
      //检查拍卖是否结束
      require(!auction.ended&&auction.startTime +auction.duration<block.timestamp,"Auction has ended");
      //检查出价是否高于起始价格和当前最高价
      require(msg.value>auction.highestBid&&msg.value>=auction.startPrice,"Bid must be greater than highest bid");
      //退回之前的最高出价
      if(auction.highestBidder!=address(0)){
         payable(auction.highestBidder).transfer(auction.highestBid);
      }
      //更新最高出价者和最高价
      auction.highestBidder=msg.sender;
      auction.highestBid=msg.value;
   }

   //结束拍卖
   function endAuction(uint256 _auctionId) external{
      Auction storage auction=auctions[_auctionId];
      //检查拍卖是否结束
      require(!auction.ended&&auction.startTime +auction.duration<block.timestamp,"Auction has ended");
      auction.ended=true;
      //如果有出价，转移NFT给最高出价者，转移资金给卖家
      if(auction.highestBidder!=address(0)){
         IERC721(auction.nftContract).transferFrom(address(this),auction.highestBidder,auction.tokenId);
         payable(auction.seller).transfer(auction.highestBid);
      }else{
         //没有人出价，退回NFT给卖家
         IERC721(auction.nftContract).transferFrom(address(this),auction.seller,auction.tokenId);
      }
   }
}
