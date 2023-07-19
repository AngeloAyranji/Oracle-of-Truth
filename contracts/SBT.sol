// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.9.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.2/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.9.2/access/Ownable.sol";

contract SBT is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("SoulBoundToken", "SBT") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function batchMint(address[] memory tos, uint256[] memory amounts) public {
        require(tos.length == amounts.length, "Invalid input lengths");
        for (uint256 i = 0; i < tos.length; i++) {
            _mint(tos[i], amounts[i]);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20)
    {   
        require(msg.sender == to, "Token transfer is restricted");
        super._beforeTokenTransfer(from, to, amount);
    }
}
