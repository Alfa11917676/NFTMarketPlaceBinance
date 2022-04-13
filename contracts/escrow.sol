pragma solidity ^0.8.0;

import "./Whitelist.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract escrow is whitelistCheck, Ownable {

    event Deposited(address indexed sender, address indexed receiver, uint256 weiAmount);
    event Withdrawn(address indexed sender, address indexed receiver, uint256 weiAmount);
    IERC20 token;
    address public signer;
    mapping(address => mapping (uint => uint)) public _deposits;
    mapping (address => mapping (address => uint)) public _timesDeposited;

    function deposit(Whitelist memory whitelist) external {
        require (getSigner(whitelist)==signer,'!Signer');
        require (msg.sender == whitelist.senderAddress,'!Expected');
        _timesDeposited[msg.sender][whitelist.receiverAddress]+=1;
        _deposits[msg.sender][_timesDeposited[msg.sender][whitelist.receiverAddress]] = whitelist._amount;
        token.transferFrom(msg.sender, address(this), whitelist._amount);
        Deposited(whitelist.senderAddress,whitelist.receiverAddress,whitelist._amount);
    }

    function withdraw(Whitelist memory whitelist, uint slotId ) external {
        require (getSigner(whitelist) == signer,'!Signer');
        require (msg.sender == whitelist.senderAddress || msg.sender == owner(),'!Allowed');
        uint amount = _deposits[whitelist.senderAddress][slotId];
        require (amount > 0,'Insufficient Amount');
        delete _deposits[whitelist.senderAddress][slotId];
        token.transfer(whitelist.receiverAddress,amount);
        emit Withdrawn(msg.sender, whitelist.receiverAddress, amount);
    }
}
