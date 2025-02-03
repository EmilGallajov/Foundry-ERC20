// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {OurToken} from "src/OurToken.sol";
contract DeployOurToken is Script {
    uint256 public constant INITIAL_SUPPLY = 5 ether;
    function run() external returns (OurToken) {
        vm.startBroadcast();
        OurToken ot = new OurToken(INITIAL_SUPPLY);
        ot.transfer(msg.sender, INITIAL_SUPPLY); // Ensure deployer gets the tokens
        vm.stopBroadcast();
        return ot;
    }
}