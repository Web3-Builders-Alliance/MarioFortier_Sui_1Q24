#[test_only]
module sui_bank::sui_dollar_tests {
    use sui::test_utils::assert_eq;
    use sui::test_scenario as ts;    

    use sui::coin::{Self};
    use sui_bank::sui_dollar::{Self};

    const ADMIN: address = @0xBEEF;

    fun init_test_helper(): ts::Scenario {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        ts::next_tx(scenario, ADMIN);
        {            
            sui_dollar::init_for_testing(ts::ctx(scenario));
        };
        scenario_val
    }


    #[test, allow(unused_mut_ref)]
    fun test_minting() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;        
        
        ts::next_tx(scenario, ADMIN);
        {
            let cap = ts::take_shared<sui_dollar::CapWrapper>(scenario);
            let new_coin = sui_dollar::mint(&mut cap, 1, ts::ctx(scenario));
            assert_eq(coin::value(&new_coin), 1);
            sui_dollar::burn(&mut cap, new_coin);
            ts::return_shared(cap);
        };

        ts::end(scenario_val);
    }
}