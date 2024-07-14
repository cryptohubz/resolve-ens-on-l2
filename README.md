# Leveraging Scroll's L1SLOAD Precompile to Enable ENS Name Resolution on Layer 2 Chains
## Introduction
Ethereum Name Service (ENS) has revolutionized the way we interact with blockchain addresses by replacing long and complex Ethereum addresses with human-readable names. However, one significant limitation hinders the broader adoption of ENS: the inability to resolve ENS names on Layer 2 (L2) chains. This limitation restricts the usage and expansion of ENS names in L2-based smart contracts.

## Problem Statement
ENS names cannot be resolved on L2 chains, preventing their use in L2-based smart contracts. This limitation is a significant barrier to the broader adoption of ENS on L2 and restricts the flexibility and usability of L2 applications.

## Solution
Scroll has introduced a powerful new precompile called l1sload that allows L2 contracts to efficiently read data stored on Layer 1 (L1) without the need for a sizable Merkle proof. This innovation presents a unique opportunity to address the ENS resolution issue on L2 chains.

## Leveraging L1SLOAD Precompile
We leveraged the l1sload precompile to solve the ENS resolution problem on L2. The l1sload precompile enables L2 contracts to read L1 data efficiently and securely. By integrating this precompile into our solution, we can now resolve ENS names on L2, allowing for the seamless use of ENS names in L2-based smart contracts.

## Implementation
This contract, ResolveENSName, is designed to resolve ENS (Ethereum Name Service) names to Ethereum addresses. It uses a specific precompile contract address (L1_SLOAD_ADDRESS) to read data from the L1 state, and the ENS Public Resolver address is hardcoded. The contract computes the storage slot for the ENS record and retrieves the corresponding address.

Constant Definitions
**L1_SLOAD_ADDRESS**: The address of a scroll precompiled contract used to load storage from L1 (Layer 1) on testnet.
**ENS_PUBLIC_RESOLVER**: The address of the ENS Public Resolver contract on testnet.
**COIN_TYPE**: A constant representing the default coin type (60 for Ethereum). The contract can be extended to accept coinType as parameter.  
**SLOT**: A constant representing the storage slot index. We read the versianable_addressses slot which is slot number 2 for public ENS resolver (https://evm.storage/eth/20301910/0x231b0ee14048e9dccd1d247744d114a4eb5e8e63#map)
**RECORD_VERSION**: A constant representing the record version. Record version can also be extracted from the L1 slot 0 of the same contract for the corresponding name hash.

**Function to Resolve ENS**

```
    function resolveENS(bytes32 node) public view returns (address) {
        //Calculate the slot for the top-level mapping (version)
        bytes32 topSlot = keccak256(abi.encodePacked(uint256(RECORD_VERSION), uint256(SLOT)));

        //Calculate the slot for the second-level mapping (node)
        bytes32 middleSlot = keccak256(abi.encodePacked(node, topSlot));

        //Calculate the slot for the innermost mapping (coinType)
        bytes32 finalSlot = keccak256(abi.encodePacked(COIN_TYPE, middleSlot));

        bytes memory input = abi.encodePacked(ENS_PUBLIC_RESOLVER, finalSlot);

        bool success;
        bytes memory result;
        address resolved;

        (success, result) = L1_SLOAD_ADDRESS.staticcall(input);

        if (!success) {
            revert("L1SLOAD failed");
        }

        resolved = getAddressFromBytes(result);

        return resolved;

    }
```
Source Code: https://github.com/cryptohubz/resolve-ens-on-l2/blob/main/EnsResolver.sol

## Benefits
### Enhanced Flexibility
#### User-Friendly: 
ENS names provide a more intuitive and user-friendly way to interact with smart contracts.
#### Dynamic Addressing: 
ENS names allow for dynamic addressing, reducing the need for hardcoded addresses.

### Improved Security
#### Reduced Errors: 
Using ENS names reduces the risk of errors associated with manually entering Ethereum addresses.
#### Upgradability: 
ENS names can be updated, providing a layer of flexibility that hardcoded addresses lack.

### Broader Adoption
#### Layer 2 Expansion: 
Enabling ENS resolution on L2 chains promotes broader adoption and usage of ENS in various L2 applications.
#### Ecosystem Growth: 
This solution contributes to the growth of the Ethereum and L2 ecosystems by enhancing interoperability and usability.

### To-Do List
**Extracting Version from recordVersions Slot:**
* Identify and verify the storage slot layout for the **recordVersions** mapping.
* Implement the function to correctly derive the storage slot for recordVersions[node].
* Test the extraction of the version number using the l1sload precompile.

**Supporting All Resolvers through a Unified Convention:**
* Define a convention for calculating the storage slot numbers for recordVersions and versionable_addresses.
* Ensure the resolver contract supports all types of records (e.g., addresses, text records, content hashes) using the unified slot retrieval method.
* Test the resolver contract with various ENS record types to ensure compatibility and correctness.


### Conclusion
The inability to resolve ENS names on L2 chains has been a significant limitation for developers and users. By leveraging Scroll's l1sload precompile, we have developed a solution that enables efficient and secure ENS name resolution on L2. This innovation not only enhances the flexibility and usability of L2-based smart contracts but also promotes broader adoption and growth within the Ethereum ecosystem.

## Example Application
An example application where this limitation becomes apparent is in the use of ENS names instead of hardcoded Ethereum addresses. Hardcoding addresses in smart contracts is not only cumbersome but also error-prone and inflexible. Using ENS names would provide a more user-friendly and flexible approach, but the inability to resolve these names on L2 chains is a major roadblock.
Details: https://github.com/cryptohubz/resolve-ens-on-l2/blob/main/application_example.md


