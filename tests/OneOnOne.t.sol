// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { OneOnOne } from "../src/OneOnOne.sol";

contract OneOnOneTest is OneOnOne, Test {
    OneOnOne internal oneOnOne;
    address owner1;
    address owner2;
    address payable owner3;
    address payable admin;

    function setUp() public virtual {
        oneOnOne = new OneOnOne();
        owner1 = address(1);
        owner2 = address(2);
        owner3 = payable(address(2));
        admin = payable(address(3));
        deal(owner1, 10e18);
    }

    function testName() external view {
        assertEq(oneOnOne.name(), unicode"OneOnOne 💬", "name mismatch");
    }

    function testSymbol() external view {
        assertEq(oneOnOne.symbol(), "1o1", "symbol mismatch");
    }

    function testMintWithETH() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner1, 1);
        oneOnOne.mintWithETH{value: 0.001 ether}(owner1);

        assertEq(oneOnOne.balanceOf(owner1), 1);
        assertEq(oneOnOne.ownerOf(1), owner1);
    }

    function testMintWithETH2() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner1, 1);
        oneOnOne.mintWithETH{value: 0.002 ether}(owner1);

        assertEq(oneOnOne.balanceOf(owner1), 1);
        assertEq(oneOnOne.ownerOf(1), owner1);
    }

    function testExists() public {
        oneOnOne.mintWithETH{value: 0.001 ether}(owner1);
        assertTrue(oneOnOne.exists(1));
    }

    function testCannotExceedBalaceOfOne() public {
        oneOnOne.mintWithETH{value: 0.001 ether}(owner1);

        vm.expectRevert(AccountBalanceNotZero.selector);
        oneOnOne.mintWithETH{value: 0.001 ether}(owner1);
    }

    function testCannotExceedMintingLimit() public {
        // Set the counter to 10
        // See https://book.getfoundry.sh/cheatcodes/store
        vm.store(address(oneOnOne), bytes32(uint256(0)), bytes32(uint256(10)));
        assertEq(oneOnOne.counter(), 10);

        vm.expectRevert(ExceedsMintingLimit.selector);
        oneOnOne.mintWithETH{value: 0.001 ether}(owner1);
    }

    function testCannotMintToZeroAddress() public {
        vm.expectRevert(TransferToZeroAddress.selector);
        oneOnOne.mintWithETH{value: 0.001 ether}(address(0));
    }

    function testCannotMintWithNotEnoughETH() public {
        vm.expectRevert(NotEnoughETH.selector);
        oneOnOne.mintWithETH{value: 0.0001 ether}(owner1);
    }

    function testBurn() public {
        oneOnOne.mintWithETH{value: 0.001 ether}(owner1);
        assertEq(oneOnOne.balanceOf(owner1), 1);
        vm.expectEmit(true, true, true, true);
        emit Transfer(owner1, address(0), 1);
        vm.prank(owner1);
        oneOnOne.burn(1);

        assertEq(oneOnOne.balanceOf(owner1), 0);
        assertFalse(exists(1));
    }

    function testRetrieveETH() public {
        oneOnOne.mintWithETH{value: 0.001 ether}(owner1);
        oneOnOne.mintWithETH{value: 0.001 ether}(owner2);
        vm.prank(owner());
        oneOnOne.retrieveETH(admin);
        assertEq(admin.balance, 0.002 ether);
    }

    function testCannotRetrieveETHIfNotOwner() public {
        oneOnOne.mintWithETH{value: 0.001 ether}(owner1);
        oneOnOne.mintWithETH{value: 0.001 ether}(owner2);
        vm.prank(owner3);
        vm.expectRevert(Unauthorized.selector);
        oneOnOne.retrieveETH(owner3);
    }
}
