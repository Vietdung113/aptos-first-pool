
module vault::VaultTest {
    #[test_only]
    use vault::Vault;
    use vault::BasicCoin;
    use std::signer;
    struct Coin1 has drop {}

    public fun setup_and_mint(account: &signer, amount: u64){
        BasicCoin::publish_balance<Coin1>(account);
        BasicCoin::mint<Coin1>(signer::address_of(account), amount);
    }

    // Pause testing
    #[test(account = @0x1103)]
    public entry fun test_pause_1(account: signer) {
        Vault::init(&account);
        let init_state = Vault::get_state();
        assert!(init_state == false, 1);
        Vault::pause(&account);
        let current_state = Vault::get_state();
        assert!(current_state == true, 1);
    }

    #[test(account = @0x1234, deployer= @0x1103)]
    #[expected_failure]
    public entry fun test_pause_2(account: signer, deployer: signer) {
        Vault::init(&deployer);
        // let init_state = Vault::get_state();
        // assert!(init_state == false, 1);

        Vault::pause(&account);
        let current_state = Vault::get_state();
        // Debug::print<bool>(&current_state);
        assert!(current_state == true, 1);
    }

    // Unpause testing
    #[test(account = @0x1103)]
    public entry fun test_unpause_1(account: signer) {
        Vault::init(&account);
        let init_state = Vault::get_state();
        assert!(init_state == false, 1);
        Vault::pause(&account);
        let is_paused = Vault::get_state();
        assert!(is_paused == true, 1);

        Vault::unpause(&account);
        let is_paused = Vault::get_state();
        assert!(is_paused == false, 1)
    }

    #[test(account = @0x1234, deployer = @0x1103)]
    public entry fun deposit_1(account: &signer, deployer: &signer){
        Vault::init(deployer);

        // mint 1000 token for user
        setup_and_mint(account, 1000);

        Vault::create_pool<Coin1>(deployer);

        let b = Vault::balance_of<Coin1>(signer::address_of(deployer));
        assert!(b == 0, 0);

        let a = Vault::balance_of<Coin1>(signer::address_of(account));
        assert!(a == 1000,1);
        Vault::deposit<Coin1>(account, 100, Coin1 {});
    }

    #[test(account = @0x1234, owner = @0x1103)]
    public fun deposit_and_withdraw(account: &signer, owner: &signer) {
        Vault::init(owner);

        setup_and_mint(account, 1000);

        Vault::create_pool<Coin1>(owner);
        let b = Vault::balance_of<Coin1>(signer::address_of(owner));
        assert!(b == 0, 0);

        let a = Vault::balance_of<Coin1>(signer::address_of(account));
        assert!(a == 1000,1);
        Vault::deposit<Coin1>(account, 100, Coin1 {});

        Vault::withdraw<Coin1>(account, owner, 10, Coin1 {});
        Vault::withdraw<Coin1>(account, owner, 10, Coin1 {});

    }
    #[test(account = @0x1234, owner = @0x1103)]
    #[expected_failure]
    public fun deposit_and_withdraw_2(account: &signer, owner: &signer) {
        Vault::init(owner);
        setup_and_mint(account, 1000);

        Vault::create_pool<Coin1>(owner);
        let b = Vault::balance_of<Coin1>(signer::address_of(owner));
        assert!(b == 0, 0);

        let a = Vault::balance_of<Coin1>(signer::address_of(account));
        assert!(a == 1000,1);
        Vault::deposit<Coin1>(account, 100, Coin1 {});

        Vault::withdraw<Coin1>(account, owner, 10, Coin1 {});
        Vault::withdraw<Coin1>(account, owner, 100, Coin1 {});
    }

    #[test(account = @0x1234, owner = @0x1103)]
    #[expected_failure]
    public fun deposit_and_withdraw_and_paused(account: &signer, owner: &signer) {
        Vault::init(owner);
        setup_and_mint(account, 1000);

        Vault::create_pool<Coin1>(owner);
        let b = Vault::balance_of<Coin1>(signer::address_of(owner));
        assert!(b == 0, 0);

        let a = Vault::balance_of<Coin1>(signer::address_of(account));
        assert!(a == 1000,1);
        Vault::pause(owner);
        Vault::deposit<Coin1>(account, 100, Coin1 {});
    }

}