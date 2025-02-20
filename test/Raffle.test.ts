import { loadFixture, ethers, expect } from './setup.ts';

describe("Raffle auction", async function() {

    async function deploy() {
        const [user1, user2, user3, user4, user5] = await ethers.getSigners()

        const VRFMock = await ethers.getContractFactory("VRFCoordinatorV2_5Mock");
        const vrfMock = await VRFMock.deploy(0, 0, 0); 
        await vrfMock.waitForDeployment();

        const factory = await ethers.getContractFactory("Raffle")
        const contract = await factory.deploy("63281417366875788024294161379681594420089792472732677376218487019054372611132", vrfMock.getAddress())

        await contract.waitForDeployment()

        return {user1, user2, user3, user4, user5, contract, vrfMock}
    }

    it("should start auction", async function() {
        const {user1, user2, user3, user4, user5, contract, vrfMock} = await loadFixture(deploy)

        await expect(contract.connect(user1).participate()).to.be.revertedWithCustomError(contract, "NotEnoughMoneyToParticipate")

        const costOfAuction = ethers.parseEther("0.001");

        const first = await contract.connect(user1).participate({value: costOfAuction})
        const second = await contract.connect(user2).participate({value: costOfAuction})
        const third = await contract.connect(user3).participate({value: costOfAuction})
        const fourth = await contract.connect(user4).participate({value: costOfAuction})
        const fifth = await contract.connect(user5).participate({value: costOfAuction})

        
    })
})