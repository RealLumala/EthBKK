import React from 'react';
import ConnectWallet from './components/ConnectWallet';
import MintNFT from './components/MintNFT';

function App() {
    return (
        <div>
            <h1>My dApp</h1>
            <ConnectWallet />
            <MintNFT />
        </div>
    );
}

export default App;
