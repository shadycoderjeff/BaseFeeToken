pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./BaseFeeToken.sol";


contract Vault is Initializable {
	BaseFeeToken public token;
	uint64 cPercent;

	struct Stash {
		uint cBalance;
		uint tokenBalance;
		address owner;
	}
	uint stashId;
	mapping(uint => Stash) stashes;


	event StashCreated(uint indexed stashId, address indexed owner, uint cBalance, uint tokenBalance);
	event StashCollateralAdded(uint indexed stashId, uint amount);
	event StashCollateralRemoved(uint indexed stashId, uint amount);
	event StashTokensMinted(uint indexed stashId, uint amount);
	event StashTokensBurned(uint indexed stashId, uint amount);
	event StashClosed(uint indexed stashId);
	event StashLiquidated(uint indexed stashId, address indexed liquidator);


	function initialize(
		BaseFeeToken _token,
		uint64 _cPercent
	) public initializer {
		token = _token;
		cPercent = _cPercent;
	}

	function create(uint _numTokens) public payable {
		// TODO: Replace with BASEFEE when it is available
		uint _basefee = 1 gwei;
		uint _maxTokens = msg.value * 100 / _basefee / cPercent;

		require(_numTokens <= _maxTokens);

		uint _stashId = stashId++;
		Stash storage stash = stashes[_stashId];
		stash.cBalance = msg.value;
		stash.tokenBalance = _numTokens;
		stash.owner = msg.sender;

		token.mint(msg.sender, _numTokens);

		emit StashCreated(_stashId, msg.sender, msg.value, _numTokens);
	}

	function addCollateral(uint _stashId) public payable {
		address _owner = stashes[_stashId].owner;
		require(_owner == msg.sender);

		uint _prevBalance = stashes[_stashId].cBalance;
		uint _newBalance = _prevBalance + msg.value;

		stashes[_stashId].cBalance = _newBalance;

		emit StashCollateralAdded(_stashId, msg.value);
	}

	function removeCollateral(uint _stashId, uint _amount) public {
		address _owner = stashes[_stashId].owner;
		require(_owner == msg.sender);

		uint _prevBalance = stashes[_stashId].cBalance;
		uint _newBalance = _prevBalance - _amount;

		// TODO: Replace with BASEFEE when it is available
		uint _basefee = 1 gwei;
		uint _tokenBalance = stashes[_stashId].tokenBalance;
		uint _maxTokens = _newBalance * 100 / _basefee / cPercent;

		require(_tokenBalance <= _maxTokens);

		stashes[_stashId].cBalance = _newBalance;
		// TODO: Maybe add backstop fee?
		// Otherwise, owner can bypass the fee by slowly burning tokens and removing collateral
		payable(msg.sender).transfer(_amount);

		emit StashCollateralRemoved(_stashId, _amount);
	}

	function mintTokens(uint _stashId, uint _amount) public {
		address _owner = stashes[_stashId].owner;
		require(_owner == msg.sender);

		uint _prevBalance = stashes[_stashId].tokenBalance;
		uint _newBalance = _prevBalance + _amount;

		// TODO: Replace with BASEFEE when it is available
		uint _basefee = 1 gwei;
		uint _cBalance = stashes[_stashId].cBalance;
		uint _maxTokens = _cBalance * 100 / _basefee / cPercent;

		require(_newBalance <= _maxTokens);

		stashes[_stashId].tokenBalance = _newBalance;
		token.mint(msg.sender, _amount);

		emit StashTokensMinted(_stashId, _amount);
	}

	function burnTokens(uint _stashId, uint _amount) public {
		address _owner = stashes[_stashId].owner;
		require(_owner == msg.sender);

		uint _prevBalance = stashes[_stashId].tokenBalance;
		uint _newBalance = _prevBalance - _amount;

		stashes[_stashId].tokenBalance = _newBalance;
		token.burnFrom(msg.sender, _amount);

		emit StashTokensBurned(_stashId, _amount);
	}

	function close(uint _stashId) public {
		address _owner = stashes[_stashId].owner;
		require(_owner == msg.sender);

		uint _tokenBalance = stashes[_stashId].tokenBalance;
		uint _cBalance = stashes[_stashId].cBalance;

		token.burnFrom(msg.sender, _tokenBalance);
		// TODO: Add backstop fee
		payable(msg.sender).transfer(_cBalance);

		delete stashes[_stashId];

		emit StashClosed(_stashId);
	}

	function liquidate(uint _stashId) public {
		// TODO: Replace with BASEFEE when it is available
		uint _basefee = 1 gwei;
		uint _tokenBalance = stashes[_stashId].tokenBalance;
		uint _cBalance = stashes[_stashId].cBalance;
		uint _maxTokens = _cBalance * 100 / _basefee / cPercent;

		require(_tokenBalance > _maxTokens);

		// TODO: Replace with auction
		token.burnFrom(msg.sender, _tokenBalance);
		// TODO: Add backstop fee
		payable(msg.sender).transfer(_cBalance);

		delete stashes[_stashId];

		emit StashLiquidated(_stashId, msg.sender);
	}
}

