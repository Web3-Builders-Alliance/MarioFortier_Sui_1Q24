import { Secp256r1Keypair } from "@mysten/sui.js/keypairs/secp256r1";
import { Secp256k1Keypair } from "@mysten/sui.js/keypairs/secp256k1";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { fromB64 } from "@mysten/sui.js/utils";
import { getFaucetHost, requestSuiFromFaucetV0 } from "@mysten/sui.js/faucet";

// We're going to import our keypair from the wallet file
import { privateKeyB64 } from "../dev-wallet.json";
let secret_key_with_type = fromB64(privateKeyB64);
let key_type = secret_key_with_type[0];
let secret_key = secret_key_with_type.slice(1);

let pub_key = "";
if (key_type === 0) {
  let kp = Ed25519Keypair.fromSecretKey(secret_key);
  pub_key = `${kp.toSuiAddress()}`;
} else if (key_type === 1) {
  let kp = Secp256k1Keypair.fromSecretKey(secret_key);
  pub_key = `${kp.toSuiAddress()}`;
} else if (key_type === 2) {
  let kp = Secp256r1Keypair.fromSecretKey(secret_key);
  pub_key = `${kp.toSuiAddress()}`;
}
console.log(`Requesting SUIS from faucet for ${pub_key}`);
(async () => {
  let recipient = `${pub_key}`;
  try {
    let res = await requestSuiFromFaucetV0({
      host: getFaucetHost("testnet"),
      recipient,
    });
    console.log(`Success! Check our your TX here:
          https://suiscan.xyz/devnet/object/${res.transferredGasObjects[0].id}`);
  } catch (e) {
    console.error(`Oops, something went wrong: ${e}`);
  }
})();
