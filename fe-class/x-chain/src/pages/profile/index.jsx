import { useState, useEffect } from 'react';
import TextField from '@mui/material/TextField';
import Divider from '@mui/material/Divider';

import { 
  ConnectButton, 
  useWallet, 
  useAccountBalance,
  // addressEllipsis,
  
} from "@suiet/wallet-kit";

import {
  getFullnodeUrl, SuiClient
} from "@mysten/sui.js/client"

import { Ed25519Keypair } from '@mysten/sui.js/keypairs/ed25519';

export default function Profile() {
  let [msg, setMsg] = useState("");
  let [msg_signed, setMsgSigned] = useState("");
  const [address, setAddress] = useState(""); 

  useEffect(() => {
    const keypair = new Ed25519Keypair();
    setAddress(keypair.publicKey);
    console.log(keypair);
  }, []);

  // create a client connected to devnet
  const client = new SuiClient({ url: getFullnodeUrl('devnet') });

  const wallet = useWallet();  
  //console.log(wallet);

  const account = useAccountBalance();
  const { error, loading, balance } = account;
  console.log("Error", error);


  async function get_user_signature() {
    try {      
      // convert string to Uint8Array 
      const msgBytes = new TextEncoder().encode(msg)
      
      const result = await wallet.signPersonalMessage({
        message: msgBytes
      })

      console.log(result);

            // verify signature with publicKey and SignedMessage (params are all included in result)
      const verifyResult = await wallet.verifySignedMessage(result, wallet.account.publicKey)
      if (!verifyResult) {
        console.log('signPersonalMessage succeed, but verify signedMessage failed')
      } else {
        console.log(verifyResult);
        console.log('signPersonalMessage succeed, and verify signedMessage succeed!')
        setMsgSigned(result);
      }
    } catch (e) {
      console.error('signPersonalMessage failed', e)
    }
  }

  return (
    <>
    {wallet?.connected ? (
      <div>
        <h1>Wallet Connected</h1>
        <pt>Network: {wallet.chain?.name}</pt>
        <p>Address: {wallet.account.address}</p>
        {loading ? (<div>Loading...</div>) : (
          <p>Balance: {(Number(balance)/10**9).toPrecision(3)} SUI</p>
        )}
        <TextField 
          label="Message to sign" 
          value={msg} 
          onChange={(e) => setMsg(e.target.value)} 
        />
        { msg && <button onClick={get_user_signature}> Sign it! </button> }
        { msg_signed && <div> Signed Message: {msg_signed} </div> }
      </div>
    ) : (
      <div>
        <h1>Wallet Not Connected</h1>
        <ConnectButton />
      </div>
    )}
    </>
  )
}