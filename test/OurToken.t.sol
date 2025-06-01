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

        assertEq(token.allowance(bob, alice), 50 ether);
    }
}
