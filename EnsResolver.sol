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
        //Calculate the slot for the top-level mapping (version)
        bytes32 topSlot = keccak256(abi.encodePacked(uint256(recordVersion), uint256(slot)));

        //Calculate the slot for the second-level mapping (node)
        bytes32 middleSlot = keccak256(abi.encodePacked(node, topSlot));

        //Calculate the slot for the innermost mapping (coinType)
        uint256 finalSlot = uint256(keccak256(abi.encodePacked(coinType, middleSlot)));
        return abi.decode(retrieveSlotFromL1(
            l1_contract,
            finalSlot
            ), (bytes));
    }
  
      function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
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
