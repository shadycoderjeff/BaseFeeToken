const {
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const BaseFeeToken = artifacts.require("BaseFeeToken");


contract("BaseFeeToken: initialize", accounts => {
	it("should initialize properly", async () => {
		let bft = await BaseFeeToken.deployed();
		await bft.initialize("BaseFeeToken", "BFT", accounts[5]);
		assert.equal(await bft.name(), "BaseFeeToken");
		assert.equal(await bft.symbol(), "BFT");
		assert.isTrue(await bft.hasRole(constants.ZERO_BYTES32, accounts[5]));
	});
});

contract("BaseFeeToken: supportsInterface", accounts => {
	it("should return false for 0xffffffff", async () => {
		let bft = await BaseFeeToken.deployed();
		assert.isFalse(await bft.supportsInterface("0xffffffff"));
	});

	it("should return true for IERC165Upgradeable", async () => {
		let bft = await BaseFeeToken.deployed();
		assert.isTrue(await bft.supportsInterface("0x01ffc9a7"));
	});

	it("should return true for IAccessControlUpgradeable", async () => {
		let bft = await BaseFeeToken.deployed();
		assert.isTrue(await bft.supportsInterface("0x7965db0b"));
	});
});

contract("BaseFeeToken: mint", accounts => {
	it("should mint only when minter role", async () => {
		let bft = await BaseFeeToken.deployed();
		await bft.initialize("BaseFeeToken", "BFT", accounts[5]);
		await bft.grantRole(web3.utils.sha3("MINTER_ROLE"), accounts[3], {from: accounts[5]});

		expectRevert(
			bft.mint(accounts[4], 1000, {from: accounts[5]}),
			"BFT: must have minter role to mint",
		);

		await bft.mint(accounts[4], 1000, {from: accounts[3]});

		assert.equal(
			await bft.balanceOf(accounts[4]),
			1000
		);
	});
});

