async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with:", deployer.address);

    // Deploy BloodDonation contract
    const BloodDonation = await ethers.getContractFactory("BloodDonation");
    const bloodDonation = await BloodDonation.deploy();
    await bloodDonation.deployed();
    console.log("BloodDonation deployed to:", bloodDonation.address);

    // Deploy DonorBadge contract
    const DonorBadge = await ethers.getContractFactory("DonorBadge");
    const donorBadge = await DonorBadge.deploy();
    await donorBadge.deployed();
    console.log("DonorBadge deployed to:", donorBadge.address);

    // Save addresses to file
    const fs = require('fs');
    const addresses = {
        BloodDonation: bloodDonation.address,
        DonorBadge: donorBadge.address,
    };
    fs.writeFileSync('deployed-addresses.json', JSON.stringify(addresses, null, 2));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
