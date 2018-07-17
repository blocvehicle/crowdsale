pragma solidity ^0.4.22;

import "../SafeMath.sol";
import "../BlocVehicle.sol";
import "./lib/CappedCrowdsale.sol";
import "./lib/Pausable.sol";

contract BlocVehicleMainsale is CappedCrowdsale, Pausable {
  using SafeMath for uint256;

  struct lock {
    uint256 privateTokens;
    uint256 privateWei;
  }

  mapping(address => lock) public locks;

  // The token being sold
  BlocVehicle public token;


  // Maximum amount raised
  uint256 public maxAmount;

  constructor(uint256 _startTime, uint256 _endTime, uint256 _rate, BlocVehicle _token, address _wallet, uint256 _cap, uint256 _maxAmount) public
    Crowdsale(_startTime, _endTime, _rate, _wallet, _cap)
    CappedCrowdsale(_cap.mul(1 ether))
  {
    require(_token != address(0));
    token = _token;
    maxAmount = _maxAmount.mul(1 ether);
  }

  //Function for withdrawing toekns to buyers
  function withdrawLock(address beneficiary) onlyOwner public {
    locks[beneficiary].privateTokens = 0;
    locks[beneficiary].privateWei = 0;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens();
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   */
  function buyTokens() whenNotPaused public payable {
    require(msg.sender != address(0));
    require(msg.value <= maxAmount);

    address beneficiary = msg.sender;
    uint256 weiAmount = msg.value;

    _preValidatePurchase(beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getMainTokenAmount(weiAmount);

    //token transfer
    require(token.transfer(beneficiary, tokens));

    // update state
    weiRaised = weiRaised.add(weiAmount);

    locks[msg.sender].privateTokens = (locks[msg.sender].privateTokens).add(tokens);
    locks[msg.sender].privateWei = (locks[msg.sender].privateWei).add(weiAmount);

    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    _forwardFunds();
  }
}
