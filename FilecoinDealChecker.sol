pragma solidity 0.8.21;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

contract DeFiModule is AxelarExecutable {
    IAxelarGasService public immutable gasService;

    address[] public pinners;
    string filecoinCID;    // EDIT remove init

    string destinationChain;
    string destinationCheckerAddress;
    string destinationSubmitterAddress;

    error NotEnoughValueForGas();

    // https://docs.axelar.dev/resources/mainnet
    constructor(address gateway_, address gasService_) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasService_);
    // constructor() AxelarExecutable(0xe432150cce91c13a887f7D836923d5597adD8E31) {
    //     gasService = IAxelarGasService(0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6);

        destinationChain = "filecoin-2";    // EDIT "filecoin"
        destinationCheckerAddress = "0x0000000000000000000000000000000000000000";  // EDIT mainnet deployment
        destinationSubmitterAddress = "0x0000000000000000000000000000000000000000";
    }

    function processFees(string calldata cid) external payable {
        if (msg.value == 0)  revert NotEnoughValueForGas();

        bytes memory payload = abi.encode(cid);
        gasService.payNativeGasForContractCall{value: msg.value} (
            address(this),
            destinationChain,
            destinationCheckerAddress,
            payload,
            msg.sender
        );

        gateway.callContract(destinationChain,destinationCheckerAddress,payload);
    }

    function submitCid(string calldata cid) external payable {
        if (msg.value == 0)  revert NotEnoughValueForGas();
        
        bytes memory payload = abi.encode(cid);
        gasService.payNativeGasForContractCall{value: msg.value} (
            address(this),
            destinationChain,
            destinationSubmitterAddress,
            payload,
            msg.sender
        );

        gateway.callContract(destinationChain,destinationSubmitterAddress,payload);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload_
    ) internal override {
        pinners = abi.decode(payload_, (address[]));
        payFees();
    }

    function payFees() public {
        uint totalBalance = address(this).balance;
        uint amountPerPinner = totalBalance / pinners.length;

        for (uint i = 0; i < pinners.length; i++) {
            (bool success, ) = payable(pinners[i]).call{value: amountPerPinner}("");
            require(success, "Transfer failed");
        }
    }

    // admin function
    function changeCID(string calldata _filecoinCID) external {
        filecoinCID = _filecoinCID;
    }

    function addFees() external payable {}

    receive() external payable {}
    
}