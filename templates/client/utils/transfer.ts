import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { TransactionBlock } from "@mysten/sui.js/transactions";

import wallet from "./dev-wallet.json";

// Import our dev wallet keypair from the wallet file
const keypair = Ed25519Keypair.fromSecretKey(new Uint8Array(wallet));

// Define our WBA SUI Address
const to = "0x7a4cabf5674575b41fa226a8bb5deb0ce6d89bace1b6bd9df8f90ee18800bf2d";

const client = new SuiClient({ url: getFullnodeUrl("testnet") });

(async () => {
  try {
    //create Transaction Block.
    const txb = new TransactionBlock();
    //Split coins
    let [coin] = txb.splitCoins(txb.gas, [1000]);
    //Add a transferObject transaction
    txb.transferObjects([coin, txb.gas], to);
    let txid = await client.signAndExecuteTransactionBlock({
      signer: keypair,
      transactionBlock: txb,
    });
    console.log(`Success! Check our your TX here:
        https://suiexplorer.com/txblock/${txid.digest}?network=devnet`);
  } catch (e) {
    console.error(`Oops, something went wrong: ${e}`);
  }
})();
