// Received from Daniel


const { ethers } = require('ethers');

let name = 'scroll.eth';

// to get ENS "node" first normalize the name then hash it.
// still need to assess how to do this in Solidity
// https://docs.ens.domains/resolution/names
let nameNormalized = ethers.ensNormalize(name);
console.log(nameNormalized);
let ensNode = ethers.namehash(nameNormalized);
console.log('ensNode: ', ensNode);

// now use this to lookup the resolver address from the registry
// on mainnet, this is 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e
// assuming this is the "default" public resolver is probably safe,
// so skip this step for now.
// We'll assume the Public Resolver address of:
// 0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41

// Now, use "_addresses" in slot 1
// to look this up:
let abiCoder = ethers.AbiCoder.defaultAbiCoder();
let lookupAddressMapping = ethers.keccak256(
  abiCoder.encode(['bytes32', 'uint256'], [ensNode, 1])
);
// this slot should be a mapping of coin types to addresses for this name:
// console.log(lookupAddressMapping);

// Now, the default coin number for Ethereum is 60, so,
// for the final slot location to use L1SLOAD with, we can use:

let lookupEthereumAddress = ethers.keccak256(
  abiCoder.encode(['uint256', 'bytes32'], [60, lookupAddressMapping])
);

// this should be the resolved address for Ethereum:
// console.log('slot for resolved Etherum address:', lookupEthereumAddress);

console.log('-- Sepolia:');
// Sepolia contract is different!!
// Sepolia Resolver is:
// 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD
// this is the lookup logic:
// mapping(uint64 => mapping(bytes32 => mapping(uint256 => bytes))) versionable_addresses;

let version = 0;

let versionMapSlot = ethers.keccak256(
  abiCoder.encode(['uint64', 'uint256'], [version, 0])
);
console.log('slot of versionMap: ', versionMapSlot);

let sepoliaAddressMapping = ethers.keccak256(
  abiCoder.encode(['bytes32', 'bytes32'], [ensNode, versionMapSlot])
);
console.log(sepoliaAddressMapping);

let lookupSepoliaAddress = ethers.keccak256(
  abiCoder.encode(['uint256', 'bytes32'], [60, sepoliaAddressMapping])
);

console.log(lookupSepoliaAddress);
// should be 0x2f2538a3174297e18d060bf964364ece75cacf9c61bbfa5e4c576320d9b5e582
// works with an RPC request, but acts weird in solidity :()
