// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AIRRISE is ERC20, Ownable {

    uint256 public lastMint;
    uint256 public monthlyMintAmount = 1000 * 10 ** 18;
    
    
    mapping(address => bool) public isHolder;
    address[] public holders;

    constructor() ERC20("AIRRISE", "AIR") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
        lastMint = block.timestamp;
        
        
        isHolder[msg.sender] = true;
        holders.push(msg.sender);
    }


    function _update(address from, address to, uint256 value) internal virtual override {
        
        if (to != address(0) && !isHolder[to]) {
            isHolder[to] = true;
            holders.push(to);
        }

  
        if (from != address(0) && to != address(0)) {
            uint256 taxAmount = value / 1000; // 0.1%
            uint256 sendAmount = value - taxAmount;

            super._update(from, owner(), taxAmount);
            
            super._update(from, to, sendAmount);
        } else {
           
            super._update(from, to, value);
        }
    }

    function mintMonthly() public onlyOwner {
        require(block.timestamp >= lastMint + 30 days, "error month");
        uint256 totalHolders = holders.length;
        require(totalHolders >= 10, "not enough holders");

        uint256 perHolder = monthlyMintAmount / 10;

        for(uint i = 0; i < 10; i++) {
         
            uint256 index = uint256(keccak256(abi.encodePacked(block.timestamp, i, totalHolders))) % totalHolders;
            _mint(holders[index], perHolder);
        }

        lastMint = block.timestamp;
    }

    function getHoldersCount() public view returns(uint256) {
        return holders.length;
    }
}