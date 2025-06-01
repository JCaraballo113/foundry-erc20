// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/src/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {
    DeployOurToken public deployer;
    OurToken public token;

    address bob = makeAddr("Bob");
    address alice = makeAddr("Alice");

    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        token = deployer.run();

        vm.prank(msg.sender);
        token.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(token.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowances() public {
        vm.prank(bob);
        token.approve(alice, 50 ether);

        vm.prank(alice);
        token.transferFrom(bob, alice, 25 ether);

        assertEq(token.balanceOf(alice), 25 ether);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - 25 ether);
        assertEq(token.allowance(bob, alice), 25 ether);
    }

    function testTotalSupply() public view {
        assertEq(token.totalSupply(), 1000 ether);
    }

    function testDeployerInitialBalance() public view {
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testTransferInsufficientBalanceReverts() public {
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(bob, 1 ether);
    }

    function testApproveAndAllowance() public {
        vm.prank(bob);
        token.approve(alice, 10 ether);
        assertEq(token.allowance(bob, alice), 10 ether);
    }

    function testTransferFromInsufficientAllowanceReverts() public {
        vm.prank(bob);
        token.approve(alice, 1 ether);

        vm.prank(alice);
        vm.expectRevert();
        token.transferFrom(bob, alice, 2 ether);
    }

    function testTransferToZeroAddressReverts() public {
        vm.prank(bob);
        vm.expectRevert();
        token.transfer(address(0), 1 ether);
    }

    function testApproveToZeroAddressReverts() public {
        vm.prank(bob);
        vm.expectRevert();
        token.approve(address(0), 1 ether);
    }

    function testMintsOwnerInitialSupply() public view {
        // Check that the deployer has the initial supply
        assertEq(
            token.balanceOf(address(msg.sender)) + STARTING_BALANCE, // Bob's balance
            1000 ether
        );
    }
}
