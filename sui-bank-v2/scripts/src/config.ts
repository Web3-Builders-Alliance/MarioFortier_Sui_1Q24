import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
//import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { Secp256r1Keypair } from "@mysten/sui.js/keypairs/secp256r1";
import dotenv from "dotenv";

dotenv.config();

export const keypair = Secp256r1Keypair.fromSecretKey(
  Uint8Array.from(Buffer.from(process.env.KEY!, "base64")).slice(1)
);

export const client = new SuiClient({ url: getFullnodeUrl("testnet") });

// ---------------------------------

export const PACKAGE =
  "0x0114a060ae9e77372754bd4c458b17885570f763ef9c8ed1a162e63044db59e2";
export const BANK =
  "0x353c7fe67ca0ef3eabea399debeac2a1e48da1567b100c33119bc771fc7a7e15";
export const ACCOUNT = "";

export const BANK_CAP_WRAPPER =
  "0xff8f772575a2b3c02b7f5042ce0a21a0a066ac74c41a4c8fe6c4df2fb324271e";
