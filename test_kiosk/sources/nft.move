module test_kiosk::nft {
  
  use sui::object::{Self,UID};
  use sui::tx_context::TxContext;

  #[test_only]
  friend test_kiosk::test_kiosk;

  #[test_only]
  friend test_kiosk::test_royalty;

  struct NFT has key, store {
    id: UID
  }

  public(friend) fun mint(ctx: &mut TxContext): NFT {
    NFT {
      id: object::new(ctx)
    }
  }

  public(friend) fun burn(self: NFT) {
    let NFT { id } = self;
    object::delete(id);
  }
}