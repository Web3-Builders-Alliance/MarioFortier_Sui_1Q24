module sui_bank::oracle {
  // === Imports ===

  use sui::math as sui_math;

  use switchboard::aggregator::{Self, Aggregator};
  use switchboard::math;
  
  use sui::tx_context::{Self,TxContext};
  use std::vector;

  friend sui_bank::amm;

  // === Errors ===

  const EPriceIsNegative: u64 = 0;

  // === Structs ===

  struct Price {
    latest_result: u128,
    scaling_factor: u128,
    latest_timestamp: u64,
  }

  struct SaferOracle {
    aggregator: Aggregator,
    last_timestamp: u64, // 0 when not applicable.
    last_price: u128, // 0 when unknown.
    max_delta_tolerance: u64, // Max % change allowed from last price check.
  }

  struct SecretKey has drop {} // What is that for?

  // === Public-Mutative Functions ===

  public fun create_oracle(ctx: &mut TxContext) : SaferOracle {
    // Instantiate the aggregator.
    let aggregator = switchboard::aggregator::new<SecretKey>(
            b"test", // name: 
            @0x955e87b8bf01e8f8a739e07c7556956108fa93aa02dae0b017083bfbe99cbd34, // queue_addr: 
            1, // batch_size: 
            1, // min_oracle_results: 
            1, // min_job_results: 
            0, // min_update_delay_seconds: 
            math::zero(), // variance_threshold: 
            0, // force_report_period: 
            false, // disable_crank: 
            0, // history_limit: 
            0, // read_charge: 
            @0x0, // reward_escrow: 
            vector::empty(), // read_whitelist: 
            false, // limit_reads_to_whitelist: 
            0, // created_at: 
            tx_context::sender(ctx), // authority, - this is the owner of the aggregator
            &SecretKey {}, // _friend_key: scopes the function to only by the package of aggregator creator (intenrnal)
            ctx,
        );

    SaferOracle {
      aggregator: aggregator,
      last_timestamp: 0,
      last_price: 0,
      max_delta_tolerance: 0
    }
  }

  public fun new_price(feed: &Aggregator): Price {
    let (latest_result, latest_timestamp) = aggregator::latest_value(feed);

    let (value, scaling_factor, neg) = math::unpack(latest_result);

    assert!(!neg, EPriceIsNegative);

    Price {
      latest_result: value,
      scaling_factor: (sui_math::pow(10, scaling_factor) as u128),
      latest_timestamp
    }
  }

  public fun destroy_price(self: Price): (u128, u128, u64) {
    let Price { latest_result, scaling_factor, latest_timestamp } = self;
    (latest_result, scaling_factor, latest_timestamp)
  }

  // === Test Functions ===

  #[test_only]
  
  public fun new_price_for_testing(latest_result: u128, scaling_factor: u128, latest_timestamp: u64): Price {
    Price {
      latest_result,
      scaling_factor,
      latest_timestamp
    }
  }
}