// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SendAckReceiver } from './SendAckReceiver.sol';
import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';

contract SendAckReceiverImplementation is SendAckReceiver {
    constructor(address gateway_) SendAckReceiver(gateway_) {}

    string[] public messages;

    function messagesLength() external view returns (uint256) {
        return messages.length;
    }

    // override this to do stuff
    function _executePostAck(
        string memory, /*sourceChain*/
        string memory, /*sourceAddress*/
        bytes memory payload
    ) internal override {
        string memory message = abi.decode(payload, (string));
        messages.push(message);
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