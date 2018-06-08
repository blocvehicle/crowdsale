pragma solidity ^0.4.22;

import "../SafeMath.sol";
import "../BlocVehicle.sol";
import "../lib/CappedCrowdsale.sol";
import "../lib/Pausable.sol";

contract samplePresale is CappedCrowdsale, Pausable {
  using SafeMath for uint256;

  struct lock {
    uint256 privateTokens;
    uint256 privateWei;
  }

  mapping(address => lock) public locks;

  // The token being sold
  BlocVehicle public token;

  // crowdsale softcap
  uint256 public softcap;

  constructor(uint256 _startTime, uint256 _endTime, uint256 _rate, BlocVehicle _token, address _wallet, uint256 _cap)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap.mul(1 ether))
  {
    require(_token != address(0));
    token = _token;
  }

  //Functions for distributing tokens to buyers
  function releaseLock(address beneficiary) onlyOwner public {
    require(locks[beneficiary].privateTokens > 0);
    require(locks[beneficiary].privateWei > 0);

    require(token.transfer(beneficiary, locks[beneficiary].privateTokens));
    locks[beneficiary].privateTokens = 0;
  }

  //When the pre-sale is over, delete the token.
  //The address of the owner and the address of the token must be the same.
  function burnSaleTokens() onlyOwner public {
    token.burnTokens(this, token.balanceOf(this));
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) whenNotPaused public payable {

    require(_beneficiary != address(0));

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    locks[msg.sender].privateTokens = (locks[msg.sender].privateTokens).add(tokens);
    locks[msg.sender].privateWei = (locks[msg.sender].privateWei).add(weiAmount);

    emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    _forwardFunds();
  }
}
