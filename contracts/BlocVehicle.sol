pragma solidity ^0.4.22;

import "./ERC20.sol";
import "./SafeMath.sol";

contract BlocVehicle is ERC20 {

      using SafeMath for uint;
      string public constant name = "BlocVehicle";
      string public constant symbol = "VCL";
      uint256 public constant decimals = 18;
      uint256 _totalSupply = 1000000000 * (10 ** decimals);

      // Balances for each account
      mapping(address => uint256) balances;

      // Owner of account approves the transfer of an amount to another account
      mapping(address => mapping (address => uint256)) allowed;

      // Account frozen
      mapping(address => bool) public frozenAccount;

      // Frozen event
      event FrozenFunds(address target, bool frozen);

      // Owner of this contract
      address public owner;

      // Functions with this modifier can only be executed by the owner
      modifier onlyOwner() {
        require(msg.sender == owner);
        _;
      }

      // Change owner address
      function changeOwner(address _newOwner) onlyOwner public {
        require(_newOwner != address(0));
        owner = _newOwner;
      }

      // Destory tokens
      function burnTokens(address burnedAddress, uint256 amount) onlyOwner public {
        require(burnedAddress != address(0));
        require(amount > 0);
        require(amount <= balances[burnedAddress]);
        balances[burnedAddress] = balances[burnedAddress].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
      }

      // Target Address to be frozen
      function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
      }

      function isFrozenAccount(address _addr) public constant returns (bool) {
        return frozenAccount[_addr];
      }

      // Constructor
      constructor() public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
      }

      // Internal Transfer
      function _transfer(address _from, address _to, uint256 _value) internal {
        //Prevent transfer to 0x0 address
        require(_to != address(0));
        //Check if the sender has enough
        require(balances[_from] >= _value);
        //Check for overflows
        require(balances[_to].add(_value)  >= balances[_to]);
        //Check if sender, recipient is frozen
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);

        //Save for assert
        uint previousBalances = balances[_from].add(balances[_to]);
        //substract
        balances[_from] = balances[_from].sub(_value);
        //add
        balances[_to] = balances[_to].add(_value);
        //logging
        emit Transfer(_from, _to, _value);
        //assert
        assert(balances[_from].add(balances[_to]) == previousBalances);
      }

      // Transfer tokens
      function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
      }

      // Transfer tokens from other address
      function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
      }

      // Token total supply
      function totalSupply() public constant returns (uint256 supply) {
        supply = _totalSupply;
      }

      // Token balances
      function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
      }

      //Approval
      function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
      }

      function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
          allowed[msg.sender][_spender] = 0;
        } else {
          allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
      }

      // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
      // If this function is called again it overwrites the current allowance with _value.
      function approve(address _spender, uint256 _value) public returns (bool success) {
          allowed[msg.sender][_spender] = _value;
          emit Approval(msg.sender, _spender, _value);
          return true;
      }

      function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
      }
}
