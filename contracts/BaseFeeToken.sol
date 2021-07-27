pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";


contract BaseFeeToken is
	Initializable,
	ContextUpgradeable,
	IAccessControlUpgradeable,
	IERC165Upgradeable,
	IERC20Upgradeable,
	IERC20MetadataUpgradeable,
	ERC165Upgradeable,
	AccessControlUpgradeable,
	ERC20Upgradeable,
	ERC20BurnableUpgradeable
{
	function initialize(
		string memory _name,
		string memory _symbol,
		address _admin
	) public initializer {
		__Context_init_unchained();
		__ERC165_init_unchained();
		__AccessControl_init_unchained();
		__ERC20_init_unchained(_name, _symbol);
		__ERC20Burnable_init_unchained();
		_setupRole(DEFAULT_ADMIN_ROLE, _admin);
	}

	function supportsInterface(bytes4 _interfaceId)
		public view
		override (IERC165Upgradeable, ERC165Upgradeable, AccessControlUpgradeable)
		returns (bool) {
		return super.supportsInterface(_interfaceId);
	}

	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

	function mint(address _to, uint256 _amount) public override {
		require(
			hasRole(MINTER_ROLE, _msgSender()),
			"BFT: must have minter role to mint"
		);
		_mint(_to, _amount);
	}
}

