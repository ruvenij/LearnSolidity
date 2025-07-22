// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Make a contract called calculator
// create result variabe to store the result
// add, subtract and multiply functions
// create a function to get result

contract Calculator {
    uint256 result = 0;

    function add(uint256 input) public  {
        result += input;
    }

    function subtract(uint256 input) public {
        result -= input;
    }

    function multiply(uint256 input) public {
        result *= input;
    }

    function getResult() public view returns (uint256) {
        return result;
    }
}