// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ZPad.sol";

contract Staking is Context,Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 private zpad;

    uint256 private bronze = 30000 ether;
    uint256 private silver = 75000 ether;
    uint256 private gold = 170000 ether;

    uint32 private bronze_pool_weight = 10;
    uint32 private silver_pool_weight = 32;
    uint32 private gold_pool_weight = 80;

    mapping(address => uint32) private userWeight;
    mapping(address => uint256) private userStakedValue;

    //events
    event eve_staked (uint256 amount);
    event eve_Unstaked (uint256 amount);

    //constructor
    constructor(address _token){
        zpad = IERC20(_token);
    }

    //setter functions
    function setBronzeValue(uint256 _bronze)public onlyOwner{
        bronze = _bronze;
    } 
    function setSilverValue(uint256 _silver)public onlyOwner{
        silver = _silver;
    } 
    function setGoldValue(uint256 _gold)public onlyOwner{
        gold = _gold;
    }
    function setBronzeWeight(uint32 _weight)public onlyOwner{
        bronze_pool_weight = _weight;
    }
    function setSilverWeight(uint32 _weight)public onlyOwner{
        silver_pool_weight = _weight;
    } 
    function setGoldWeight(uint32 _weight)public onlyOwner{
        gold_pool_weight = _weight;
    }

    //getter functions

     function getUserWeight(address account)public view returns(uint32){
        return userWeight[account];
    }
    
    function getUserStakedValue(address account)public view returns(uint256){
        return userStakedValue[account];
    } 

    //pool weight

    function getPoolWeight(uint256 amount) private view returns(uint32){
        uint32 weight;
        if(amount>=bronze && amount<silver){
            weight =  gold_pool_weight;
        }
        else if(amount>=silver && amount<gold){
            weight = silver_pool_weight;
        }
        else if(amount>=gold){
            weight = gold_pool_weight;
        }
        else{
            weight = 0;
        }
        return weight;
    }

    function Stake(uint256 amount) public nonReentrant{ 
        require(amount>=bronze,"insufficient balance for staking");
        require(zpad.allowance(_msgSender(),address(this))>=amount,"Approve your token");
        zpad.safeTransferFrom(_msgSender(),address(this),amount);
        uint256 balance = amount + userStakedValue[_msgSender()];
        userStakedValue[_msgSender()] = balance;
        userWeight[_msgSender()] = getPoolWeight(balance);
        emit eve_staked(amount);
    }

    function unStake(uint256 amount) public nonReentrant{ 
        uint256 balance =userStakedValue[_msgSender()];
        require(amount<=balance,"insufficient balance for unstaking");
        zpad.safeTransferFrom(address(this),_msgSender(),amount);
        uint256 newBalance = userStakedValue[_msgSender()] - amount;
        if(newBalance==0){
            delete userStakedValue[_msgSender()];
            delete userWeight[_msgSender()];
        }
        else{
            userStakedValue[_msgSender()] = newBalance;
            userWeight[_msgSender()] = getPoolWeight(newBalance);
        }
        emit eve_Unstaked(amount);
    }
    
}