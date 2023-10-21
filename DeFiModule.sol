
pragma solidity 0.8.21;
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
contract DeFiModule is AxelarExecutable {
    IAxelarGasService public immutable gasService;
    address[] public pinners;
    string filecoinCID = "meow";
    string destinationChain;
    string destinationAddress;
    error NotEnoughValueForGas();
    // constructor(address gateway_, address gasService_) AxelarExecutable(gateway_) {
    //     gasService = IAxelarGasService(gasService_);
    // }
    
    // https://docs.axelar.dev/resources/mainnet
    constructor() AxelarExecutable(0xe432150cce91c13a887f7D836923d5597adD8E31) {
        gasService = IAxelarGasService(0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6);
        destinationChain = "filecoin-2";    // EDIT "filecoin"
        destinationAddress = "0x1A8D7458E7dCB408611081D99D3c25324745212C";  // EDIT mainnet deployment
    }
    function sendMessage() external payable {
        if (msg.value == 0)  revert NotEnoughValueForGas();
        bytes memory payload = abi.encode(filecoinCID);
        gasService.payNativeGasForContractCall{value: msg.value} (
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            msg.sender
        );
        gateway.callContract(destinationChain,destinationAddress,payload);
    }
    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload_
    ) internal override {
        pinners = abi.decode(payload_, (address[]));
    }
    // admin function
    function changeCID(string calldata _filecoinCID) external {
        filecoinCID = _filecoinCID;
    }

    function payFees() public {
        uint totalBalance = address(this).balance;
        uint amountPerPinner = totalBalance / pinners.length;
        for (uint i = 0; i < pinners.length; i++) {
            (bool success, ) = payable(pinners[i]).call{value: amountPerPinner}("");
            require(success, "Transfer failed");
        }
    }
    function push(address _m) public {
        pinners.push(_m);
    }
    function addFees() external payable {}
    receive() external payable {}
}
