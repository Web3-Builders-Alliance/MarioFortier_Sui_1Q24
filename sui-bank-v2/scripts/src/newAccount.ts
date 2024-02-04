import { TransactionBlock } from "@mysten/sui.js/transactions";
import { client, keypair, PACKAGE } from "./config.js";

(async () => {
  try {
    const tx = new TransactionBlock();

    let [account] = tx.moveCall({
      target: `${PACKAGE}::bank::new_account`,
      arguments: [],
    });

    tx.transferObjects([account], keypair.getPublicKey().toSuiAddress());

    const result = await client.signAndExecuteTransactionBlock({
      signer: keypair,
      transactionBlock: tx,
      options: {
        // showEffects: true,
        showObjectChanges: true,
      },
      requestType: "WaitForLocalExecution",
    });

    console.log("result: ", JSON.stringify(result, null, 2));
  } catch (e) {
    console.error(e);
  }
})();

// let params:
// client.getOwnedObjects({});
