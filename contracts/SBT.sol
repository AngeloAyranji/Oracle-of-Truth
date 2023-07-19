// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.9.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.2/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.9.2/access/Ownable.sol";

contract SBT is ERC20, ERC20Burnable, Ownable {

    constructor() ERC20("SoulBoundToken", "SBT") {}

     function batchMint(address[] memory to, uint256 amount) public {
        for (uint256 i = 0; i < to.length; i++) {
            _mint(to[i], amount);
        }
    }

    function transfer(address to, uint256 value) public pure override returns (bool) {
        revert("Transfers are currently disabled for this token.");
    }

    function transferFrom(address from, address to, uint256 value) public pure override returns (bool) {
        revert("Transfers are currently disabled for this token.");
    }
}
