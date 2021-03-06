//SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowance is Ownable {
    using SafeMath for uint;
    
    event AllowanceChanged(address indexed _forWho, address _fromWhom, uint _oldAmount, uint _newAmount);
    
    mapping(address => uint) public allowance;
    
    function addAllowance(address _who, uint _amount) public  onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }
    
    modifier ownerOrAllowed(uint _amount) {
        require(owner() == msg.sender || allowance[msg.sender] >= _amount, "you are not allowed");
        _;
    }
    
    function reduceAllowance(address _who, uint _amount) internal  onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who].sub(_amount));
        allowance[_who] = allowance[_who].sub(_amount);
    }
}

contract SimpleWaller is Ownable, Allowance {
    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);

    
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "There are not enough funds stored in the smart contract");
        if(owner() != msg.sender) {
            reduceAllowance(msg.sender, _amount);
        }
        
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }
    
    
    function renounceOwnership() public view override onlyOwner{
        revert('Cant renouce ownership here');
    }
    
    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
}