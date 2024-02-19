// This contract will seed the pool and allow users to trade agaisnt it 
// It will also reward users with a token every 2 swaps

#[test_only]
module dex::dex {
  /*
  use std::option;
  use std::type_name::{get, TypeName};

  use sui::transfer;
  use sui::sui::SUI;
  use sui::clock::{Clock};
  use sui::balance::{Self, Supply};
  use sui::object::{Self, UID};
  use sui::table::{Self, Table};
  use sui::dynamic_field as df;
  use sui::tx_context::{Self, TxContext};
  use sui::coin::{Self, TreasuryCap, Coin};

  use deepbook::clob_v2::{Self as clob, Pool};
  use deepbook::custodian_v2::AccountCap;

  use dex::eth::ETH;
  use dex::usdc::USDC;
*/
  
  use dex::eth::{Self, ETH};
  use dex::usdc::{Self, USDC};
  use sui::test_scenario::{Self};
  use deepbook::clob_v2::{Self, Pool};
  use sui::coin::{Self};
  use sui::sui::{SUI};
  use sui::transfer::{Self};
  use sui::clock::{Self};

  #[test]
  fun test_all() {
    let pool_owner = @0x1;
    let user = @0x2;

    let scenario_val = test_scenario::begin(pool_owner);
    let scenario = &mut scenario_val;

    eth::init_for_testing(test_scenario::ctx(scenario));
    usdc::init_for_testing(test_scenario::ctx(scenario));

    test_scenario::next_tx(scenario, pool_owner);
    {
      //Txn1 create_pool() as admin
      // tick_size : 1 is 1e-9 USDC
      // lot_size: 1
      let creation_fee = coin::mint_for_testing<SUI>(100000000000,test_scenario::ctx(scenario));
      clob_v2::create_pool<ETH, USDC>(1000000000, 1, creation_fee, test_scenario::ctx(scenario));            

    };

    test_scenario::next_tx(scenario, user);
    {
      //Txn2 create_user_account() as user
      let pool = test_scenario::take_shared<Pool<ETH,USDC>>(scenario);
      let account_cap = clob_v2::create_account( test_scenario::ctx(scenario));
      let clock = clock::create_for_testing(test_scenario::ctx(scenario));
      let isBid = true; // Buying ETH for USDC.

      // Returns (base quantity filled, quote quantity filled, whether a maker order is being placed, order id of the maker order).      
      // let eth_coin = coin::mint_for_testing<ETH>(2000000000, test_scenario::ctx(scenario));
      let usdc_coin = coin::mint_for_testing<USDC>(20000000000, test_scenario::ctx(scenario));
      //clob_v2::deposit_base<ETH,USDC>(&mut pool, eth_coin, &account_cap);
      clob_v2::deposit_quote<ETH,USDC>(&mut pool, usdc_coin, &account_cap);

      let qte = 1000000000;
      let price = 1000000000;
      let (base_filled, quote_filled, is_placed, maker_order_id) = clob_v2::place_limit_order( &mut pool, 1, price, qte, 0, isBid, 1000, 0, &clock, &account_cap, test_scenario::ctx(scenario));

      assert!(is_placed == true, 0);

      // To fill it have to create another order from another user (isBid = true)

      // TODO Check it is in the pool using the maker_order_id

      transfer::public_transfer(account_cap, user);
      test_scenario::return_shared(pool);
      clock::destroy_for_testing(clock);
    };

    test_scenario::end(scenario_val);
    //Txn2 and 3 create_user_account place_order as user.    
  }
}

