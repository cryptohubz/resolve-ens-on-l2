// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

 import "hardhat/console.sol";



contract ResolveENS {
    event LogMessage(string message);


    address constant L1_SLOAD_ADDRESS = 0x0000000000000000000000000000000000000101;
    uint256 constant DEFAULT_COIN_TYPE = 60;


    function readSingleSlot(address l1_contract, uint256 slot) public view returns (uint256) {

        bytes memory input = abi.encodePacked(l1_contract, slot);

        bool success;
        bytes memory result;

        (success, result) = L1_SLOAD_ADDRESS.staticcall(input);

        if (!success) {
            revert("L1SLOAD failed");
        }

        return abi.decode(result, (uint256));

    }

    function readMultiSlot(address l1_contract, uint256[] memory slots) public view returns (bytes32[] memory) {

        bytes memory input = abi.encodePacked(l1_contract, slots);

        bool success;
        bytes memory result;

        (success, result) = L1_SLOAD_ADDRESS.staticcall(input);

        if (!success) {
            revert("L1SLOAD failed");
        }

        return convertBytesToBytes32Array(result);

    }

    // readr recordVersion
    // function readRecordVersion(address l1_contract, bytes32 node, uint256 slot) public view returns (bytes memory) {
    //     // Calculate the slot for recordVersion
    //     bytes32 recordVersionSlotHash = keccak256(abi.encode(node, slot));
    //     // Convert bytes32 to dynamic bytes array
    //     // bytes memory hashed = new bytes(32);
    //     // for (uint8 i = 0; i < 32; i++) {
    //     //     hashed[i] = recordVersionSlotHash[i];
    //     // }
    //     bytes32 slotHash = keccak256(abi.encode(l1_contract, recordVersionSlotHash));
    //     // bytes memory hashedSlot = new bytes(32);
    //     // for (uint8 i = 0; i < 32; i++) {
    //     //     hashedSlot[i] = slotHash[i];
    //     // }
    //     bool success;
    //     bytes memory result;
    //     (success, result) = L1_SLOAD_ADDRESS.staticcall(slotHash);
        
    //     // if (!success) {
    //     //     revert("L1SLOAD failed to read recore version");
    //     // }

    //     return result;
    // }

 // readr2 recordVersion
    function readUintRecordVersion(address l1_contract, bytes32 node, uint256 slot) public view returns (uint) {
        // Calculate the slot for recordVersion
        bytes memory recordVersionHash = abi.encodePacked(l1_contract, slot, node);
        bool success;
        bytes memory result;
        (success, result) = L1_SLOAD_ADDRESS.staticcall(recordVersionHash);
        
        if (!success) {
            revert("L1SLOAD failed to read recore version");
        }

        return abi.decode(result, (uint256));
    }

    function retrieveSlotFromL1(address l1StorageAddress, uint slot) internal view returns (bytes memory) {
        bool success;
        bytes memory returnValue;
        (success, returnValue) = L1_SLOAD_ADDRESS.staticcall(abi.encodePacked(l1StorageAddress, slot));
        if(!success)
        {
            revert("L1SLOAD failed");
        }
        return returnValue;
    }


      function resolveEnsName(address l1_contract, bytes32 node, uint256 slot, uint256 recordVersion, uint256 coinType) public view returns (bytes memory) {
        // Calculate the slot for recordVersion
        // versionable_addresses[0]["myname.eth"][60];
        uint slotNumber1 = uint(keccak256(abi.encodePacked(slot,node)));
        uint slotNumber2 = uint(keccak256(abi.encodePacked(uint(uint160(recordVersion)),slotNumber1) ));
        uint slotNumber3 = uint(keccak256(abi.encodePacked(uint(uint160(coinType)),slotNumber2) ));
        return abi.decode(retrieveSlotFromL1(
            l1_contract,
            slotNumber3
            ), (bytes));
    }

      function resolveEns(address l1_contract, bytes32 node, uint256 slot, uint256 recordVersion, uint256 coinType) public view returns (bytes memory) {
        // Calculate the slot for recordVersion
        // versionable_addresses[0]["myname.eth"][60];
        bytes32 topSlot = keccak256(abi.encodePacked(uint256(recordVersion), uint256(slot)));
        bytes32 middleSlot = keccak256(abi.encodePacked(node, topSlot));
        uint256 finalSlot = uint256(keccak256(abi.encodePacked(coinType, middleSlot)));

        return abi.decode(retrieveSlotFromL1(
            l1_contract,
            finalSlot
            ), (bytes));
    }


    

    function resolveEnsName3(address l1_contract, bytes32 node, uint256 slot, uint256 recordVersion, uint256 coinType) public view returns (bytes memory) {
        // Calculate the slot for recordVersion
        // versionable_addresses[0]["myname.eth"][60];
        uint slotNumber = uint(keccak256(abi.encodePacked(slot, recordVersion, node, coinType)));

        return abi.decode(retrieveSlotFromL1(
            l1_contract,
            slotNumber
            ), (bytes));
    }
    
    function resolveEnsName5(address l1_contract, bytes32 node, uint256 slot, uint256 recordVersion, uint256 coinType) public view returns (bytes memory) {
        // Calculate the slot for recordVersion
        // versionable_addresses[0]["myname.eth"][60];
        uint slotNumber = uint(keccak256(abi.encodePacked( uint(recordVersion), uint(node), uint(coinType), uint(slot))));

        return abi.decode(retrieveSlotFromL1(
            l1_contract,
            slotNumber
            ), (bytes));
    }

    function resolveEnsName4(address l1_contract, bytes32 node, uint256 slot, uint256 recordVersion, uint256 coinType) public view returns (bytes memory) {
        // Calculate the slot for recordVersion
        // versionable_addresses[0]["myname.eth"][60];
        uint slotNumber = uint(keccak256(abi.encodePacked(coinType, node, recordVersion, slot)));

        return abi.decode(retrieveSlotFromL1(
            l1_contract,
            slotNumber
            ), (bytes));
    }
    function convertBytesToBytes32Array(bytes memory data) private pure returns (bytes32[] memory) {
        // Calculate the number of 32-byte chunks
        uint256 length = data.length;
        uint256 numChunks = (length + 31) / 32;

        // Create a new bytes32 array
        bytes32[] memory result = new bytes32[](numChunks);

        // Loop through the data and fill the bytes32 array
        for (uint256 i = 0; i < numChunks; i++) {
            bytes32 chunk;
            assembly {
                chunk := mload(add(data, add(32, mul(i, 32))))
            }
            result[i] = chunk;
        }
        return result;
    }

}

