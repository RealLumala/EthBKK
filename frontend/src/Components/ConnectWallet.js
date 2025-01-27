import { useAccount, useConnect, useDisconnect } from 'wagmi';


//changes to be made with viem
function ConnectWallet() {
    const { connect, connectors } = useConnect();
    const { disconnect } = useDisconnect();
    const { isConnected } = useAccount();

    return (
        <div>
            {isConnected ? (
                <button onClick={() => disconnect()}>Disconnect</button>
            ) : (
                connectors.map((connector) => (
                    <button key={connector.id} onClick={() => connect(connector)}>
                        Connect with {connector.name}
                    </button>
                ))
            )}
        </div>
    );
}

export default ConnectWallet;



// samples drawn from Meteor
// Tag @RealLumala