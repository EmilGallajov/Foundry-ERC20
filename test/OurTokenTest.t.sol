// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {

    OurToken public ourToken;
    DeployOurToken public deployer;

    address anar = makeAddr("anar");
    address revan = makeAddr("revan");
    address randomUser = makeAddr("random");

    uint256 public constant STARTING_BALANCE = 2 ether;
    uint256 public constant INITIAL_SUPPLY = 5 ether;

    function setUp() external {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        address tokenOwner = ourToken.balanceOf(address(this)) > 0 ? address(this) : msg.sender; 

        vm.prank(tokenOwner); // Use the actual token owner
        ourToken.transfer(anar, STARTING_BALANCE);   
    }

    // ✅ 1. Check if the initial supply is correct
    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    // ✅ 2. Ensure only the deployer has tokens initially
    function testOnlyOwnerReceivesTokensInitially() public {
        assertEq(ourToken.balanceOf(anar), STARTING_BALANCE);
        assertEq(ourToken.balanceOf(revan), 0);
        assertEq(ourToken.balanceOf(randomUser), 0);
    }

    // ✅ 3. Test direct transfer
    function testDirectTransfer() public {
        uint256 transferAmount = 1 ether;

        vm.prank(anar);
        ourToken.transfer(revan, transferAmount);

        assertEq(ourToken.balanceOf(revan), transferAmount);
        assertEq(ourToken.balanceOf(anar), STARTING_BALANCE - transferAmount);
    }

    // ✅ 4. Test allowance decrease after transferFrom
    function testAllowanceDecrease() public {
        uint256 initialAllowance = 1 ether;
        uint256 transferAmount = 0.5 ether;

        vm.prank(anar);
        ourToken.approve(revan, initialAllowance);

        vm.prank(revan);
        ourToken.transferFrom(anar, revan, transferAmount);

        assertEq(ourToken.allowance(anar, revan), initialAllowance - transferAmount);
    }

    // ✅ 5. Test transfer failure due to insufficient balance
    function testTransferFailsWhenInsufficientBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1 ether; // More than anar has

        vm.prank(anar);
        vm.expectRevert(); // Expect revert due to insufficient balance
        ourToken.transfer(revan, transferAmount);
    }

    // ✅ 6. Test transferFrom failure due to insufficient allowance
    function testTransferFailsWhenInsufficientAllowance() public {
        uint256 transferAmount = 100;
        uint256 approveToken = 50;
        vm.prank(anar);
        ourToken.approve(revan, approveToken); // Only approving 50 tokens

        vm.prank(revan);
        vm.expectRevert(); // Expect revert due to not enough allowance
        ourToken.transferFrom(anar, revan, transferAmount);
    }
}
