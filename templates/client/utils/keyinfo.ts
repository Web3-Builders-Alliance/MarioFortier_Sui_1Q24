// Generate a throw away wallet for this execise

import fs from "fs";
import { Secp256r1Keypair } from "@mysten/sui.js/keypairs/secp256r1";
import { Secp256k1Keypair } from "@mysten/sui.js/keypairs/secp256k1";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";

import { fromB64 } from "@mysten/sui.js/utils";
import { toHEX } from "@mysten/sui.js/utils";

// Display info about secret key in dev-wallet.json
//
// Format example:
// {
//   "privateKeyB64": "mdqVWeFekT7pqy5T49+tV12jO0m+ESW7ki4zSU9JiCg="
// }
//
// privateKeyB64 is the value in sui.keystore. This is the only input needed for this
// utility.
import { privateKeyB64 } from "../dev-wallet.json";
let secret_key_with_type = fromB64(privateKeyB64);
let key_type = secret_key_with_type[0];
let secret_key = secret_key_with_type.slice(1);

let out_pub = "";
let out_priv_array = "";
let out_priv_hex = "";
let key_type_str = "";
if (key_type === 0) {
  let kp = Ed25519Keypair.fromSecretKey(secret_key);
  key_type_str = "Ed25519";
  out_pub = `${kp.toSuiAddress()}`;
  out_priv_array = `[${fromB64(kp.export().privateKey)}]`;
  out_priv_hex = `${toHEX(fromB64(kp.export().privateKey))}`;
} else if (key_type === 1) {
  let kp = Secp256k1Keypair.fromSecretKey(secret_key);
  key_type_str = "Secp256k1";
  out_pub = `${kp.toSuiAddress()}`;
  out_priv_array = `[${fromB64(kp.export().privateKey)}]`;
  out_priv_hex = `${toHEX(fromB64(kp.export().privateKey))}`;
} else if (key_type === 2) {
  let kp = Secp256r1Keypair.fromSecretKey(secret_key);
  key_type_str = "Secp256r1";
  out_pub = `${kp.toSuiAddress()}`;
  out_priv_array = `[${fromB64(kp.export().privateKey)}]`;
  out_priv_hex = `${toHEX(fromB64(kp.export().privateKey))}`;
}

console.log(`Key Type          : ${key_type_str}
Public Hex        : ${out_pub}
Private B64       : ${privateKeyB64}
Private Hex       : 0x${out_priv_hex}
Private ArrayBytes: ${out_priv_array}`);
