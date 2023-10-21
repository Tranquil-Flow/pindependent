pragma solidity 0.8.21;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";

interface IDealStatus {
    function submit(bytes calldata _cid) external returns (uint256);
    function getActiveDeals(bytes calldata _cid) external returns (FilecoinPindepdendent.Deal[] memory);
}

contract FilecoinPindepdendent is AxelarExecutable {
    IAxelarGasService public immutable gasService;
    IDealStatus public dealStatus;

    mapping(string => address[]) public pinnerList;
    address[] public pinners;
    string public cid;
    struct Deal {
        uint64 dealId;
        uint64 minerId;
    }
    
    constructor() AxelarExecutable(0x999117D44220F33e0441fbAb2A5aDB8FF485c54D) {    // 0xe432150cce91c13a887f7D836923d5597adD8E31   EDIT mainnet
        gasService = IAxelarGasService(0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6); //  0x2d5d7d31F671F86C782533cc367F14109a082712  EDIT mainnet
        dealStatus = IDealStatus(0x6ec8722e6543fB5976a547434c8644b51e24785b);   // Lighthouse SC on Filecoin Calibration Testnet
    }
    
    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload_
    ) internal override {
        cid = abi.decode(payload_, (string));
        bytes memory _cid = abi.encode(cid);
        Deal[] memory deals = dealStatus.getActiveDeals(_cid);
        for (uint256 i = 0; i < deals.length; i++) {
            uint64 dealId = deals[i].dealId;
            
            // get the filecoin address of the pinner
            uint64 provider = MarketAPI.getDealProvider(dealId);
            
            // convert provider number to ethereum address
            address pinner = uint64ToAddress(provider);
            // add to list of pinners
            pinnerList[cid].push(pinner);
        }
        bytes memory payload = abi.encode(pinnerList[cid]);        
        gateway.callContract(sourceChain,sourceAddress,payload);
    }

    function uint64ToAddress(uint64 value) public pure returns (address) {
        return address(uint160(value));
    }
}
