//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./EIP712.sol";

contract whitelistCheck is EIP712{

    string private constant SIGNING_DOMAIN = "Escrow";
    string private constant SIGNATURE_VERSION = "1";

    struct Whitelist{
        address senderAddress;
        address receiverAddress;
        uint _amount;
        bytes signature;
    }

    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){}

    function getSigner(Whitelist memory whitelist) internal view returns(address){
        return _verify(whitelist);
    }


    function _hash(Whitelist memory whitelist) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("Whitelist(address senderAddress,address receiverAddress,uint _amount)"),
                whitelist.senderAddress,
                whitelist.receiverAddress,
                whitelist._amount
            )));
    }

    function _verify(Whitelist memory whitelist) internal view returns (address) {
        bytes32 digest = _hash(whitelist);
        return ECDSA.recover(digest, whitelist.signature);
    }

}