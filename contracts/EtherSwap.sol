pragma solidity ^0.4.24;


contract EtherSwap {

    struct Swap {
        address inititator;
        address recipient;
        uint256 endTimeStamp;
        uint256 value;
        bool hasEntry; //mutex and flag to check if there is an entry
    }

    mapping(bytes32 => Swap) public swapMap; // the key is the hash

    event SwapInitiatedEvent(bytes32 indexed hash, uint256 indexed value);
    event SwapSuccessEvent(bytes32 indexed hash, uint256 indexed value);

    function secretLock(uint256 _lockTimeSec, bytes32 _hash, address _recipient) public payable returns (bool) {
        require(swapMap[_hash].hasEntry == false); //check no entry available in map

        require(msg.value > 0);

        swapMap[_hash].hasEntry = true;
        swapMap[_hash].inititator = msg.sender;
        swapMap[_hash].recipient = _recipient;
        swapMap[_hash].endTimeStamp = now + _lockTimeSec;
        swapMap[_hash].value = msg.value;

        emit SwapInitiatedEvent(_hash, msg.value);
        return true;
    }

    function secretProof(bytes32 _hash, bytes _proof) public returns (bool) {
        require(swapMap[_hash].hasEntry); 
        require(swapMap[_hash].endTimeStamp >= now);

        bytes32 calculatedHash = sha256(_proof);
        require(calculatedHash == _hash);

        uint256 value = swapMap[_hash].value;
        address recipient = swapMap[_hash].recipient;
    
        clean(_hash);
        recipient.transfer(value);
        emit SwapSuccessEvent(_hash, value);
    }

    function calcHash(bytes _proof) public pure returns (bytes32) {
        return sha256(_proof);
    }

    function swapExpiredRefund(bytes32 _hash) public returns (bool) {
        require(swapMap[_hash].hasEntry);
        require(swapMap[_hash].endTimeStamp < now);

        uint256 value = swapMap[_hash].value;
        address initiator = swapMap[_hash].inititator;
        clean(_hash);
        
        initiator.transfer(value);

        return true;
    }

    function clean(bytes32 _hash) private {

        Swap storage swap = swapMap[_hash];

        delete swap.hasEntry;
        delete swap.inititator;
        delete swap.recipient;
        delete swap.endTimeStamp;
        delete swap.value;
        delete swapMap[_hash];
    }
}