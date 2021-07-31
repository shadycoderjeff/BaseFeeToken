pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./BaseFeeToken.sol";


contract Vault is Initializable {
	BaseFeeToken public token;
	uint cPercent;

	struct Stash {
		uint cBalance;
		uint tokenBalance;
		address owner;
	}
	uint stashId;
	mapping(uint => Stash) stashes;


	function initialize(
		BaseFeeToken _token,
		uint _cPercent
	) public initializer {
		token = _token;
		cPercent = _cPercent;
	}

	function create(uint _numTokens) public payable {
		// TODO: Replace with BASEFEE when it is available
		uint _basefee = 1 gwei;
		uint _maxTokens = msg.value * 100 / _basefee / cPercent;

		require(_numTokens <= _maxTokens);

		Stash storage stash = stashes[stashId++];
		stash.cBalance = msg.value;
		stash.tokenBalance = _numTokens;
		stash.owner = msg.sender;

		token.mint(msg.sender, _numTokens);
	}
}

