pragma solidity ^0.4.22;

import "../SafeMath.sol";
import "../BlocVehicle.sol";
import "./lib/Pausable.sol";

contract BlocVehicleBounty is Pausable {
  using SafeMath for uint256;

  BlocVehicle public token;

  //total bounty token Amount
  uint256 public totalBountyAmount;

  //bounty limit
  uint256 constant tokenAllocation = 10000000 * (1 ether);
  uint256 constant totalSnsLimit = 6000000 * (1 ether);
  uint256 constant totalYoutubeLimit = 1000000 * (1 ether);
  uint256 constant totalBlogLimit = 3000000 * (1 ether);

  //bounty reward
  uint256 constant snsReward = 500 * (1 ether);
  uint256 constant youtubeReward = 50000 * (1 ether);
  uint256 constant blogReward = 5000 * (1 ether);

  //bounty type code
  string constant facebook = "fc";
  string constant telegram = "tl";
  string constant twitter = "tt";
  string constant bitcoinTalk = "bt";

  string constant youtube = "yt";

  string constant englishBlog = "eb";
  string constant japaneseBlog = "jb";
  string constant chineseBlog = "cb";
  string constant koreanBlog = "kb";
  string constant vietnameseBlog = "vb";
  string constant thaiBlog = "tb";
  string constant indonesianBlog = "ib";
  string constant spanishBlog = "sb";

  //defined bounty code
  uint256 constant snsCode = 1;
  uint256 constant youtubeCode = 2;
  uint256 constant blogCode = 3;

  //limit mapping
  struct bountyLimit {
    uint256 typeAmount;
    uint256 limitAmount;
  }
  mapping(string => bountyLimit) private bountyAmount;
  mapping(uint256 => uint256) public totalTypeAmount;

  //reward mapping
  //1 : SNS, 2 : YOUTUBE, 3 : BLOG
  mapping(string => uint256) private bountyType;

  event tokenRewards(address target, uint256 tokenAmount);

  constructor (BlocVehicle _token) public {
    token = _token;

    bountyAmount[facebook].limitAmount = 1000000 * (1 ether);
    bountyAmount[telegram].limitAmount = 1000000 * (1 ether);
    bountyAmount[twitter].limitAmount = 1000000 * (1 ether);
    bountyAmount[bitcoinTalk].limitAmount = 3000000 * (1 ether);
    bountyAmount[youtube].limitAmount = 1000000 * (1 ether);
    bountyAmount[englishBlog].limitAmount = 900000 * (1 ether);
    bountyAmount[japaneseBlog].limitAmount = 600000 * (1 ether);
    bountyAmount[chineseBlog].limitAmount = 600000 * (1 ether);
    bountyAmount[koreanBlog].limitAmount = 300000 * (1 ether);
    bountyAmount[vietnameseBlog].limitAmount = 150000 * (1 ether);
    bountyAmount[thaiBlog].limitAmount = 150000 * (1 ether);
    bountyAmount[indonesianBlog].limitAmount = 150000 * (1 ether);
    bountyAmount[spanishBlog].limitAmount = 150000 * (1 ether);

    bountyType[facebook] = snsCode;
    bountyType[telegram] = snsCode;
    bountyType[twitter] = snsCode;
    bountyType[bitcoinTalk] = snsCode;
    bountyType[youtube] = youtubeCode;
    bountyType[englishBlog] = blogCode;
    bountyType[japaneseBlog] = blogCode;
    bountyType[chineseBlog] = blogCode;
    bountyType[koreanBlog] = blogCode;
    bountyType[vietnameseBlog] = blogCode;
    bountyType[thaiBlog] = blogCode;
    bountyType[indonesianBlog] = blogCode;
    bountyType[spanishBlog] = blogCode;
  }

  function releaseBounty(address rewardBeneficiary, string code, uint256 rewardAmount) onlyOwner public {
    require(rewardBeneficiary != address(0));
    require(bytes(code).length != 0);
    require(rewardAmount != 0);

    uint256 tokenReward;

    tokenReward = bountyTypeDistiction(code);

    require(tokenReward != 0);
    require(tokenReward == rewardAmount);
    require(totalBountyAmount.add(tokenReward) <= tokenAllocation);

    totalBountyAmount = totalBountyAmount.add(tokenReward);
    totalTypeAmount[bountyType[code]] = totalTypeAmount[bountyType[code]].add(tokenReward);
    bountyAmount[code].typeAmount = (bountyAmount[code].typeAmount).add(tokenReward);

    require(token.transfer(rewardBeneficiary, tokenReward));
    emit tokenRewards(rewardBeneficiary, tokenReward);
  }

  function bountyTypeDistiction(string _code) internal view returns(uint256) {
    if(bountyType[_code] == snsCode) {
      require(totalTypeAmount[bountyType[_code]].add(snsReward) <= totalSnsLimit);
      require((bountyAmount[_code].typeAmount).add(snsReward) <= bountyAmount[_code].limitAmount);
      return snsReward;
    } else if(bountyType[_code] == youtubeCode) {
      require(totalTypeAmount[bountyType[_code]].add(youtubeReward) <= totalYoutubeLimit);
      require((bountyAmount[_code].typeAmount).add(youtubeReward) <= bountyAmount[_code].limitAmount);
      return youtubeReward;
    } else if(bountyType[_code] == blogCode) {
      require(totalTypeAmount[bountyType[_code]].add(blogReward) <= totalBlogLimit);
      require((bountyAmount[_code].typeAmount).add(blogReward) <= bountyAmount[_code].limitAmount);
      return blogReward;
    } else {
      return 0;
    }
  }
}
