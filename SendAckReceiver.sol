// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';

contract SendAckReceiver is AxelarExecutable {
    
    string load;

    constructor(address gateway_) AxelarExecutable(gateway_) {}

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        (uint256 nonce, string memory payloadActual) = abi.decode(payload, (uint256, string));
        load = payloadActual;
        gateway.callContract(sourceChain, sourceAddress, abi.encode(nonce));
    }
}

contract fvmContract {

    mapping(string => address) pinnerList;

    // Receive request to get list of pinners for a cid and return this value
    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
        ) internal override {
        string cid = abi.decode(payload, (string));
        address[] pinners = viewPinnerList(cid);
        gateway.callContract(sourceChain, sourceAddress, abi.encode(pinners));
    }

    function viewPinnerList() external returns (address[]) {

    }

    function submitCID(string cid) external {
        //pinnerList
    }

}