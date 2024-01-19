// "Real World" use case summary:
//   - Anyone can create/delete their own clowns.
//   - Anyone can race to push/pull their clowns into a single car object with a max capacity of 20.
//   - Nobody owns the car (shared).
//   - A "clown horn" is emited when a clown makes it into the car.
//   - Clown ownership are transferable only if in the car (clowns outside a car are "sad and worthless")
//   - Clown objects support Display of their name.
//   - A freely transferable BodyShop capability can increase the car capacity.
//
// Covers Sui By Examples sections:
//   2.3: Entry functions
//   2.5: Shared Object
//   2.6: Transfer
//   2.7: Custom Transfer
//   2.8: Events
//   2.9: One-Time-Witness (for Display)
//   2.11: Object Display
//   3.1: Capability

module prereqs::clowns_and_a_car {
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext, sender};
    use std::string::{String, utf8};
    use sui::event;
    use sui::package;
    use sui::display;

    const INITIAL_CAR_CAPACITY: u64 = 20;    

    const ECarFull: u64 =0x1;
    const EClownNotInCar: u64 = 0x2;
    const EClownAlreadyInCar: u64 = 0x3;
    const ECantDeleteClownInCar: u64 = 0x4;    
    const ECapacityCanOnlyIncrease: u64 = 0x5;    
    const EInternalErrorWithCount: u64 = 0x6;
    const ENonTransfereableWorthlessClown: u64 = 0x7;

    struct CLOWNS_AND_A_CAR has drop {} // One-time-witness type.

    struct Clown has key {
        id: UID,                        
        name: String,
        in_the_car: bool,
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
        clown_id: ID,
        clown_name: String,
    }

    fun init( otw: CLOWNS_AND_A_CAR, ctx: &mut TxContext ) {
        // Create the single freely transferable BodyShop capability.
        transfer::public_transfer(BodyShopCap {
            id: object::new(ctx),
        }, sender(ctx));

        // Create the single shared car.
        transfer::share_object( Car {
            id: object::new(ctx),
            capacity: INITIAL_CAR_CAPACITY,
            clown_count: 0
        } );

        let publisher = package::claim(otw, ctx);

        // Setup name filed Display for Clown objects.
        let keys = vector[utf8(b"name")];
        let values = vector[utf8(b"{name}")];
        let display = display::new_with_fields<Clown>(&publisher, keys, values, ctx);
        display::update_version(&mut display);        
        transfer::public_transfer(display, sender(ctx));

        transfer::public_transfer(publisher, sender(ctx));
    }

    public entry fun create_clown( name: String, ctx: &mut TxContext ) {
        // The caller is the initial owner.
        let new_clown = Clown {
            id: object::new(ctx),
            name,
            in_the_car: false
        };
        transfer::transfer(new_clown, sender(ctx));
    }

    public entry fun transfer_clown( clown: Clown, to: address, _: &mut TxContext ) {
        // Only clown in the car are worth transfering!
        assert!(clown.in_the_car == true, ENonTransfereableWorthlessClown);
        transfer::transfer(clown, to);
    }

    public entry fun delete_clown( clown: Clown, _: &mut TxContext ) {
        let Clown { id, name: _, in_the_car } = clown;
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

    public entry fun increase_car_capacity( _: &BodyShopCap, car: &mut Car, new_capacity: u64, _: &mut TxContext ) {
        assert!(new_capacity > car.capacity, ECapacityCanOnlyIncrease);
        car.capacity = new_capacity;
    }

    // Utility function...
    fun clown_horn( self: &Clown ) {
        event::emit( ClownHornEvent {
            clown_id: object::uid_to_inner(&self.id),
            clown_name: self.name
        } );
    }

    /*** TESTS ***/

    #[test_only] use sui::test_scenario as ts;

    #[test]
    fun test_simple() {
        let user1 = @0x1;
        let user2 = @0x2;
        let scenario = ts::begin(@0x0);
        
        // TODO More because...not really testing here.
        {
            ts::next_tx(&mut scenario, user1);
            let otw = CLOWNS_AND_A_CAR{};
            init(otw, ts::ctx(&mut scenario));
        };

        {
            ts::next_tx(&mut scenario, user2);
            create_clown(utf8(b"bozo"),ts::ctx(&mut scenario));
        };

        ts::end(scenario);
    }
}
