// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { StringToAddress, AddressToString } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/libs/AddressString.sol';

contract DeFiModule is AxelarExecutable {
    using StringToAddress for string;
    using AddressToString for address;
    IAxelarGasService public immutable gasService;
    
    string filecoinCID; // The current frontends CID

    error NotEnoughValueForGas();

    // https://docs.axelar.dev/resources/mainnet
    // EDIT
    constructor (
        // address gateway,
        // address gasService
    ) AxelarExecutable(0xe432150cce91c13a887f7D836923d5597adD8E31) {
        gasService = IAxelarGasService(0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6);
    }
    
    function distributeFees(
        string calldata destinationChain,
        string calldata contractAddress
    ) external payable {
        bytes memory payload = abi.encode(filecoinCID);

        if (msg.value == 0)  revert NotEnoughValueForGas();

        gasService.payNativeGasForContractCall{ value: msg.value }(
            address(this),
            "filecoin-2", // filecoin EDIT
            "0x0000000000000000000000000000000000000000",  // filecoinPindepdence Contract EDIT
            payload,
            msg.sender
        );

        gateway.callContract(destinationChain, contractAddress, payload);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        address pinners = abi.decode(payload, (address[]));
        calculatePayPerPinner();
        payPinners();
    }

    function calculatePayPerPinner() internal pure {

    }

    function payPinners() internal {

    }


    // admin functions

    function addFees() external {

    }

    function changeCID(string _filecoinCID) external {
        filecoinCID = _filecoinCID;
    }

}