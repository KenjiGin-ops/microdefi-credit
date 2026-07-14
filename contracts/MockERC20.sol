// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockERC20
 * @dev Token de prueba para simular el otorgamiento de credito en el laboratorio.
 */
contract MockERC20 is ERC20 {
    constructor() ERC20("Token Credito Prueba", "TCRED") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
