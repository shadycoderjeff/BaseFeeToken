const BaseFeeToken = artifacts.require("BaseFeeToken");


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

contract("BaseFeeToken: initialize", accounts => {
	it("should initialize properly", async () => {
		let bft = await BaseFeeToken.deployed();
		await bft.initialize("BaseFeeToken", "BFT", accounts[5]);
		assert.equal(await bft.name(), "BaseFeeToken");
		assert.equal(await bft.symbol(), "BFT");
		assert.isTrue(await bft.hasRole("0x0000000000000000000000000000000000000000000000000000000000000000", accounts[5]));
	});
});

