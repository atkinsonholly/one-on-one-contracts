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
    address payable beneficiary;
    uint256 price = 0.001 ether;

    function setUp() public virtual {
        oneOnOne = new OneOnOne();
        owner1 = address(1);
        owner2 = address(2);
        owner3 = payable(address(2));
        beneficiary = payable(address(3));
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
        oneOnOne.mintWithETH{value: price}(owner1);

        assertEq(oneOnOne.balanceOf(owner1), 1);
        assertEq(oneOnOne.ownerOf(1), owner1);
        assertEq(oneOnOne.idOf(owner1), 1);
    }

    function testMintWithETH2() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner1, 1);
        oneOnOne.mintWithETH{value: price*2}(owner1);

        assertEq(oneOnOne.balanceOf(owner1), 1);
        assertEq(oneOnOne.ownerOf(1), owner1);
    }

    function testMintWithETHMultiple() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        oneOnOne.mintWithETH{value: price}(owner2);

        assertEq(oneOnOne.balanceOf(owner1), 1);
        assertEq(oneOnOne.ownerOf(1), owner1);
        assertEq(oneOnOne.idOf(owner2), 2);
    }

    function testExists() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        assertTrue(oneOnOne.exists(1));
    }

    function testCannotExceedBalaceOfOne() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        assertEq(oneOnOne.balanceOf(owner1), 1);

        vm.expectRevert(AccountBalanceNotZero.selector);
        oneOnOne.mintWithETH{value: price}(owner1);
    }

    function testCannotExceedMintingLimit() public {
        // Set the counter to 10
        // See https://book.getfoundry.sh/cheatcodes/store
        vm.store(address(oneOnOne), bytes32(uint256(0)), bytes32(uint256(10)));
        assertEq(oneOnOne.counter(), 10);

        vm.expectRevert(ExceedsMintingLimit.selector);
        oneOnOne.mintWithETH{value: price}(owner1);
    }

    function testCannotMintToZeroAddress() public {
        vm.expectRevert(TransferToZeroAddress.selector);
        oneOnOne.mintWithETH{value: price}(address(0));
    }

    function testCannotMintWithNotEnoughETH() public {
        vm.expectRevert(NotEnoughETH.selector);
        oneOnOne.mintWithETH{value: price/10}(owner1);
    }

    function testBurn() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        assertEq(oneOnOne.balanceOf(owner1), 1);
        assertEq(oneOnOne.idOf(owner1), 1);
        vm.expectEmit(true, true, true, true);
        emit Transfer(owner1, address(0), 1);

        vm.prank(owner1);
        oneOnOne.burn(1);
        assertEq(oneOnOne.balanceOf(owner1), 0);
        assertFalse(exists(1));

        vm.expectRevert(DoesNotOwnToken.selector);
        oneOnOne.idOf(owner1);
    }

    function testBurnMultiple() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        oneOnOne.mintWithETH{value: price}(owner2);

        vm.prank(owner1);
        oneOnOne.burn(1);
        assertEq(oneOnOne.balanceOf(owner1), 0);
        assertFalse(exists(1));

        vm.expectRevert(DoesNotOwnToken.selector);
        oneOnOne.idOf(owner1);

        vm.prank(owner2);
        oneOnOne.burn(2);
        assertEq(oneOnOne.balanceOf(owner2), 0);
        assertFalse(exists(2));
    }

    function testRetrieveETH() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        oneOnOne.mintWithETH{value: price}(owner2);
        vm.prank(owner());
        oneOnOne.retrieveETH(beneficiary);
        assertEq(beneficiary.balance, price*2);
    }

    function testCannotRetrieveETHIfNotOwner() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        oneOnOne.mintWithETH{value: price}(owner2);
        vm.prank(owner3);
        vm.expectRevert(Unauthorized.selector);
        oneOnOne.retrieveETH(owner3);
    }

    function testCannotBurnIfNotOwner() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        vm.prank(owner2);
        vm.expectRevert(Unauthorized.selector);
        oneOnOne.burn(1);
    }

    function testCannotOwnMoreThanOneToken() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        oneOnOne.mintWithETH{value: price}(owner2);
         vm.prank(owner1);
        vm.expectRevert(AccountBalanceNotZero.selector);
        oneOnOne.transferFrom(owner1, owner2, 1);
    }

    function testCannotOwnMoreThanOneToken2() public {
        oneOnOne.mintWithETH{value: price}(owner1);
        oneOnOne.mintWithETH{value: price}(owner2);
        vm.prank(owner1);
        vm.expectRevert(AccountBalanceNotZero.selector);
        oneOnOne.safeTransferFrom(owner1, owner2, 1);
    }
}
