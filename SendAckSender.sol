// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { StringToAddress, AddressToString } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/libs/AddressString.sol';

contract SendAckSender is AxelarExecutable {
    using StringToAddress for string;
    using AddressToString for address;

    error NotEnoughValueForGas();

    event ContractCallSent(string destinationChain, string contractAddress, bytes payload, uint256 nonce);
    event FalseAcknowledgment(string destinationChain, string contractAddress, uint256 nonce);

    uint256 public nonce;
    mapping(uint256 => bool) public executed;
    mapping(uint256 => bytes32) public destination;
    IAxelarGasService public immutable gasService;
    string public thisChain;

    constructor(
        address gateway_,
        address gasReceiver_,
        string memory thisChain_
    ) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
        thisChain = thisChain_;
    }

    function _getDestinationHash(string memory destinationChain, string memory contractAddress) internal pure returns (bytes32) {
        return keccak256(abi.encode(destinationChain, contractAddress));
    }

    function sendContractCall(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external payable {
        uint256 nonce_ = nonce;
        bytes memory modifiedPayload = abi.encode(nonce_, payload);

        if (msg.value == 0)  revert NotEnoughValueForGas();

        gasService.payNativeGasForContractCall{ value: msg.value }(
            address(this),
            destinationChain,
            contractAddress,
            modifiedPayload,
            msg.sender
        );


        gateway.callContract(destinationChain, contractAddress, modifiedPayload);
        emit ContractCallSent(destinationChain, contractAddress, payload, nonce_);
        destination[nonce_] = _getDestinationHash(destinationChain, contractAddress);
        nonce = nonce_ + 1;
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        uint256 nonce_ = abi.decode(payload, (uint256));
        if (destination[nonce_] != _getDestinationHash(sourceChain, sourceAddress)) {
            emit FalseAcknowledgment(sourceChain, sourceAddress, nonce_);
            return;
        }
        executed[nonce_] = true;
        //get some gas back.
        destination[nonce_] = 0;
    }
}

contract DeFiModule {

    string filecoinCID; // The current frontends CID

    // events
    
    constructor() {

    }
    
    function distributeFees() external {
        sendContractCall(
            filecoin-2, // filecoin EDIT
            0x0000000000000000000000000000000000000000,  // filecoinPindepdence Contract EDIT
            abi.encode(filecoinCID);
        )
    }
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload

    function _execute() internal override {
        calculatePayPerPinner();
        payPinners();
    }

    function checkPinners() internal {

    }

    function calculatePayPerPinner() internal pure {

    }

    function payPinners() internal {

    }

    function addFees() external onlyOwner {

    }

    function changeCID(string _filecoinCID) external onlyOwner {
        filecoinCID = _filecoinCID;
    }

}