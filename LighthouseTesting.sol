pragma solidity 0.8.21;

import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";

interface IDealStatus {
    function submit(bytes calldata _cid) external returns (uint256);
    function getActiveDeals(bytes calldata _cid) external returns (LighthouseTesting.Deal[] memory);
}

contract LighthouseTesting {
    IDealStatus public dealStatus;
    
    mapping(string => address[]) public pinnerList;
    struct Deal {
        uint64 dealId;
        uint64 minerId;
    }
    
    constructor() {
        dealStatus = IDealStatus(0x6ec8722e6543fB5976a547434c8644b51e24785b);   // Lighthouse SC on Filecoin Calibration Testnet
    }

    function _execute(string calldata cid) public {
        // Get an array of Deal Structs for all active deals for a CID
        bytes memory _cid = abi.encode(cid);
        Deal[] memory deals = dealStatus.getActiveDeals(_cid);


        for (uint256 i = 0; i < deals.length; i++) {
            // Get the dealID within each Deal struct
            uint64 dealId = deals[i].dealId;
            
            // Get the filecoin address of the provider for this dealId
            uint64 prov = MarketAPI.getDealProvider(dealId);
            
            // convert provider number to ethereum address
            address pinner = uint64ToAddress(prov);

            // add this adress to an array of addresses
            pinnerList[cid].push(pinner);
        }

    }

    uint256 txId;
    function submitCid(string calldata cid) public returns(uint) {
        bytes memory _cid = abi.encode(cid);
        txId = dealStatus.submit(_cid);
        return txId;
    }

    uint64 public savedId;
    function getDealId(string calldata cid, uint dealNum) public {
        bytes memory _cid = abi.encode(cid);
        Deal[] memory deals = dealStatus.getActiveDeals(_cid);
        savedId = deals[dealNum].dealId;
    }

    uint64 public provider;
    function getDealProvider(uint64 dealId) public {
        provider = MarketAPI.getDealProvider(dealId);
    }
    
    function uint64ToAddress(uint64 value) public pure returns (address) {
        return address(uint160(value));
    }

    // 0x000000000000000000000000000000000000dead
    function addToPinnerList(address test, string memory _cid) public returns(address) {
        pinnerList[_cid].push(test);
    }

}
