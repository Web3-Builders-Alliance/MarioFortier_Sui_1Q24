import { TransactionBlock } from "@mysten/sui.js/transactions";
import { client, keypair, PACKAGE } from "./config.js";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { GetOwnedObjectsParams } from "@mysten/sui.js/client";
import { PaginatedObjectsResponse } from "@mysten/sui.js/dist/esm/types/objects.js";

const { execSync } = require("child_process");

function abort(message: string): never {
  throw new Error(message);
}

// Initialize users, each with their own key.
interface User {
  name: string;
  key?: string; // User's public key.
  account?: string; // Account sui address.
}

var users: User[] = [{ name: "Tom" }, { name: "Dick" }, { name: "Harry" }];
for (let user of users) {
  user.key = Ed25519Keypair.generate().getPublicKey().toSuiAddress();
}

// Single PTB to create accounts for all users.
const tx = new TransactionBlock();

for (let user of users) {
  let [account] = tx.moveCall({
    target: `${PACKAGE}::bank::new_account`,
    arguments: [],
  });

  tx.transferObjects([account], user.key);
}

const result = await client.signAndExecuteTransactionBlock({
  signer: keypair,
  transactionBlock: tx,
  options: {
    showObjectChanges: true,
  },
  requestType: "WaitForLocalExecution",
});

console.log("result: ", JSON.stringify(result, null, 2));

// Add a few Sui to each ${PACKAGE}::bank::Account
for (let user of users) {
  // Get the user Account object address.
  let key = user.key || abort("missing key");
  let params: GetOwnedObjectsParams = {
    owner: key,
    filter: {
      MatchAll: [
        {
          StructType: `${PACKAGE}::bank::Account`,
        },
        {
          AddressOwner: key,
        },
      ],
    },
  };
  let resp: PaginatedObjectsResponse = await client.getOwnedObjects(params);
  // TODO Handle pagination properly, for now assume a single object.
  // Example of format:
  //  {"data":[{"data": { "objectId":"0x25adee6829d6f73fef7526200f4dd606d564824df01770216e1c1076d47c48b4",
  //                  "version":"1125766"
  //                  "digest":"6jhaCUjwYMMMrcwTamFaXscq6WjKVwmpuT9kXmwTgg4D"
  //                   }
  //           }],
  //   "nextCursor":"0x25adee6829d6f73fef7526200f4dd606d564824df01770216e1c1076d47c48b4",
  //   "hasNextPage":false
  //   }
  user.account = resp.data[0].data.objectId;

  if (resp.hasNextPage) {
    abort("getOwnedObjects pagination not yet implemented");
  }

  console.log(user.name, "bank::Account is", user.account);
}

// Split a few MIST for each user from the keypair account.
