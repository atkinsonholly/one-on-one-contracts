// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { OneOnOne } from "../src/OneOnOne.sol";

contract OneOnOneTest is Test {
    OneOnOne internal oneOnOne;

    function setUp() public virtual {
        // Instantiate the contract-under-test.
        oneOnOne = new OneOnOne();
    }

    function test_Name() external view {
        assertEq(oneOnOne.name(), unicode"OneOnOne 💬", "name mismatch");
    }

    function test_Symbol() external view {
        assertEq(oneOnOne.symbol(), "1o1", "symbol mismatch");
    }

}
