// contracts/ExampleToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ZPad is ERC20 {
constructor ()
ERC20("BUSD", "BUSD")
{
    _mint(msg.sender,100000000000 * 10 ** decimals()
);}}