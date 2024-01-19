// Application Summary:
//   - Anyone can create/delete their own clowns.
//   - Anyone can race to push/pull their clowns into a single car object with a max capacity of 20.
//   - Nobody own the car (shared).
//   - A "clown horn" event is emited when a clown makes it into the car.
//   - Clowns transfereable only if in the car (clown outside the car are "worthless").
//   - The freely transfereable BodyShop capability can increase the car capacity.
//
// Covers Sui By Examples sections:
//   2.3: Entry functions
//   2.5: Shared Object
//   2.6: Transfer
//   2.7: Custom Transfer
//   2.8: Events
//   3.1: Capability
module prereqs::clowns_and_a_car {
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::event;

    const INITIAL_CAR_CAPACITY: u64 = 20;    

    const ECarFull: u64 =0x1;
    const EClownNotInCar: u64 = 0x2;
    const EClownAlreadyInCar: u64 = 0x3;
    const ECantDeleteClownInCar: u64 = 0x4;    
    const ECapacityCanOnlyIncrease: u64 = 0x5;    
    const EInternalErrorWithCount: u64 = 0x6;
    const ENonTransfereableWorthlessClown: u64 = 0x7;

    struct Clown has key {
        id: UID, 
        in_the_car: bool 
    }

    struct Car has key {
        id: UID,        
        capacity: u64,
        clown_count: u64
    }

    struct BodyShopCap has key, store {
        id: UID,
    }

    struct ClownHornEvent has copy, drop {        
        clown_id: ID
    }

    fun init(ctx: &mut TxContext) {    
        // Create a single freely transfereable BodyShop capability.
        transfer::public_transfer(BodyShopCap {
            id: object::new(ctx),
        }, tx_context::sender(ctx));

        // Create the shared car.
        transfer::share_object( Car {
            id: object::new(ctx),
            capacity: INITIAL_CAR_CAPACITY,
            clown_count: 0
        } );
    }

    public entry fun create_clown( ctx: &mut TxContext ) {
        // The caller is the initial owner.
        let new_clown = Clown {
            id: object::new(ctx),
            in_the_car: false
        };
        transfer::transfer(new_clown, tx_context::sender(ctx));
    }

    public entry fun transfer_clown( clown: Clown, to: address, _: &mut TxContext ) {
        // Only clown in the car are worth transfering!
        assert!(clown.in_the_car == true, ENonTransfereableWorthlessClown);
        transfer::transfer(clown, to);
    }

    public entry fun delete_clown( clown: Clown, _: &mut TxContext ) {
        let Clown { id, in_the_car } = clown;
        assert!(in_the_car == false, ECantDeleteClownInCar);
        object::delete(id);
    }

    public entry fun push_clown_in_car(car: &mut Car, clown: &mut Clown, _: &mut TxContext ) {
        assert!(clown.in_the_car == false, EClownAlreadyInCar);
        assert!(car.clown_count < car.capacity, ECarFull);
        clown.in_the_car = true;
        car.clown_count = car.clown_count + 1;
        clown_horn(clown);
    }

    public entry fun pull_clown_from_car(car: &mut Car, clown: &mut Clown, _: &mut TxContext ) {
        assert!(clown.in_the_car == true, EClownNotInCar);
        assert!(car.clown_count > 0, EInternalErrorWithCount);
        clown.in_the_car = false;        
        car.clown_count = car.clown_count - 1;
    }

    public entry fun increase_car_capacity( _: &mut BodyShopCap, car: &mut Car, new_capacity: u64, _: &mut TxContext ) {
        assert!(new_capacity > car.capacity, ECapacityCanOnlyIncrease);
        car.capacity = new_capacity;
    }

    // Utility function...
    fun clown_horn( self: &Clown ) {
        event::emit( ClownHornEvent {
            clown_id: object::uid_to_inner(&self.id)
        } );
    }

    /*** TESTS ***/

    #[test_only] use sui::test_scenario as ts;

    #[test]
    fun test_simple() {
        let user1 = @0x1;
        //let user2 = @0x2;
        let scenario = ts::begin(user1);

        // TODO ...not really testing here...
        {
            ts::next_tx(&mut scenario, user1);            
            create_clown(ts::ctx(&mut scenario));
        };

        ts::end(scenario);
    }
}
