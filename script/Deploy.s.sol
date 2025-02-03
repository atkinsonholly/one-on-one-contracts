// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28 <0.9.0;

import { OneOnOne } from "../src/OneOnOne.sol";

import { BaseScript } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (OneOnOne oneOnOne) {
        oneOnOne = new OneOnOne();
    }
}
