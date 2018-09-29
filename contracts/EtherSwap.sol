pragma solidity ^0.4.24;


contract EtherSwap {

    struct Swap {
        address inititator;
        address recipient;
        uint256 endTimeStamp;
        uint256 value;
    }

    mapping(bytes32 => Swap) public swapMap; // the key is the hash

    event SwapInitiatedEvent(bytes32 indexed hash, uint256 indexed value);
    event SwapSuccessEvent(bytes32 indexed hash, uint256 indexed value);

    function secretLock(uint256 _lockTimeSec, bytes32 _hash, address _recipient) external payable returns (bool) {
        require(swapMap[_hash].inititator == address(0x0), "Entry already exists");
        require(msg.value > 0, "Ether is required");

        swapMap[_hash].inititator = msg.sender;
        swapMap[_hash].recipient = _recipient;
        swapMap[_hash].endTimeStamp = now + _lockTimeSec;
        swapMap[_hash].value = msg.value;

        emit SwapInitiatedEvent(_hash, msg.value);
        return true;
    }

    function secretProof(bytes32 _hash, bytes _proof) external returns (bool) {
        require(swapMap[_hash].inititator != address(0x0), "No entry found"); 
        require(swapMap[_hash].endTimeStamp >= now, "TimeStamp violation");

        bytes32 calculatedHash = sha256(_proof);
        require(calculatedHash == _hash, "Hash check failed");

        uint256 value = swapMap[_hash].value;
        address recipient = swapMap[_hash].recipient;
    
        clean(_hash);
        recipient.transfer(value);
        emit SwapSuccessEvent(_hash, value);
    }

    function swapExpiredRefund(bytes32 _hash) external returns (bool) {
        require(swapMap[_hash].inititator != address(0x0), "No entry found");
        require(swapMap[_hash].endTimeStamp < now, "TimeStamp violation");

        uint256 value = swapMap[_hash].value;
        address initiator = swapMap[_hash].inititator;
        clean(_hash);
        
        initiator.transfer(value);
        return true;
    }

    function calcHash(bytes _proof) external pure returns (bytes32) {
        return sha256(_proof);
    }

    function clean(bytes32 _hash) private {

        Swap storage swap = swapMap[_hash];

        delete swap.inititator;
        delete swap.recipient;
        delete swap.endTimeStamp;
        delete swap.value;
        delete swapMap[_hash];
    }
}