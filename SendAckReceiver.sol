// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';

contract FilecoinPindependence is AxelarExecutable {
    
    mapping(string => address) public pinnerList;

    // EDIT filecoin:  0xe432150cce91c13a887f7D836923d5597adD8E31
    // filecoin testnet: 0x999117D44220F33e0441fbAb2A5aDB8FF485c54D
    constructor() AxelarExecutable(0x999117D44220F33e0441fbAb2A5aDB8FF485c54D) {}

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        string memory cid = abi.decode(payload, (string));
        gateway.callContract(sourceChain, sourceAddress, abi.encode(pinnerList[cid]));
    }

    function submitCID(string calldata cid) external {
        //pinnerList
    }
}