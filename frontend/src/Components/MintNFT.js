import { useContract, useSigner } from 'wagmi';
import MyContractABI from '../abi/MyContract.json';

//kept fully private
const contractAddress = 'YOUR_CONTRACT_ADDRESS';

//oNFT minting function
function MintNFT() {
    const { data: signer } = useSigner();
    const contract = useContract({
        addressOrName: contractAddress,
        contractInterface: MyContractABI,
        signerOrProvider: signer,
    });

    const mint = async () => {
        await contract.mint();
    };

    return <button onClick={mint}>Mint NFT</button>;
}

export default MintNFT;


// collective figma designs