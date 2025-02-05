// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { OneOnOne } from "../src/OneOnOne.sol";

contract OneOnOneTest is OneOnOne, Test {
    OneOnOne internal oneOnOne;

    function setUp() public virtual {
        oneOnOne = new OneOnOne();
    }

    function testName() external view {
        assertEq(oneOnOne.name(), unicode"OneOnOne 💬", "name mismatch");
    }

    function testSymbol() external view {
        assertEq(oneOnOne.symbol(), "1o1", "symbol mismatch");
    }

    // should pass with 0 NFT balance, valid to and sufficient ETH
    // should revert with to == zeroaddress
    // should revert if balanceOf(to) > 0
    // should revert if not enough ETH sent
    function testMintWithETH() public {
        address owner = address(1337);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner, 1);
        oneOnOne.mintWithETH(owner);

        assertEq(oneOnOne.balanceOf(owner), 1);
        assertEq(oneOnOne.ownerOf(1), owner);
    }

    function testCannotExceedBalaceOfOne() public {
        address owner = address(1337);
        oneOnOne.mintWithETH(owner);

        vm.expectRevert(AccountBalanceNotZero.selector);
        oneOnOne.mintWithETH(owner);
    }

    function testCannotExceedMintingLimit() public {
        address owner = address(1337);

        // Set the counter to 10
        // See https://book.getfoundry.sh/cheatcodes/store
        vm.store(address(oneOnOne), bytes32(uint256(0)), bytes32(uint256(10)));
        assertEq(oneOnOne.counter(), 10);

        vm.expectRevert(ExceedsMintingLimit.selector);
        oneOnOne.mintWithETH(owner);
    }
}
