import { IERC20__factory } from '../typechain-types/index.ts';
import { loadFixture, ethers, expect } from './setup.ts';

describe("Test Token contract", async function() {
    async function deploy() {
        const ethUser = await ethers.getImpersonatedSigner("0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503");

        const factory = await ethers.getContractFactory("Token", ethUser)
        const contract = await factory.deploy("https://ipfs.io/ipfs/bafkreievgibi55znfubyt7u4zeh45bq3vkh3jy3bsnkpj7edamos4jrepi")
        await contract.waitForDeployment()

        return {ethUser, contract}
    }

    it("should buy token with eth", async function() {//fork сети
        const {ethUser, contract} = await loadFixture(deploy)

        await expect(contract.connect(ethUser).buyWithEth(1, { value: 1 })).to.be.revertedWithCustomError(contract, "SmallFee")

        await contract.connect(ethUser).buyWithEth(1, { value: 1000000000000000 });//ehhers.parseEthers

        expect(await contract.balanceOf(ethUser.getAddress())).to.be.equal(1)
    })

    it("should buy token with usdc", async function() {
        const {ethUser, contract} = await loadFixture(deploy)

        const usdc = await IERC20__factory.connect("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", ethUser)

        await expect(contract.connect(ethUser).buyWithUsdc(1, 1000)).to.be.revertedWithCustomError(contract, "NotEnoughUsdc")

        const usdcAmount = ethers.parseUnits("10", 6); 

        await usdc.approve(contract.getAddress(), usdcAmount);

        await contract.connect(ethUser).buyWithUsdc(1, usdcAmount);
    })
})