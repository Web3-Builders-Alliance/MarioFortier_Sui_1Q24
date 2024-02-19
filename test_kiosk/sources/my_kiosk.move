module test_kiosk::my_kiosk {
  
  use sui::sui::SUI;
  use sui::object::UID;
  use sui::coin::{Self, Coin};
  use sui::transfer_policy::{Self, TransferPolicyCap, TransferPolicy, TransferRequest};
  use sui::transfer;

  use test_kiosk::nft::NFT;

  #[test_only]
  friend test_kiosk::test_kiosk;
  #[test_only]
  friend test_kiosk::test_royalty;
  
  struct Rule has drop {}  

  struct RuleConfig has store, drop {    
    royalty: u64,    // Mist to be paid upon purchase to the owner of the rule.
    owner: address,
    royalty_collected: u64,
  }

  public fun init_rules(policy: &mut TransferPolicy<NFT>, cap: &TransferPolicyCap<NFT>, owner: address ) {
    transfer_policy::add_rule(Rule {}, policy, cap, RuleConfig { royalty: 1, owner, royalty_collected: 0 });
  }

  public fun royalty_collected(cfg: &RuleConfig): u64 {
    cfg.royalty_collected
  }
}