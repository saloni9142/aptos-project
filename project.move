module MyModule::JobReferralPlatform {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a job referral.
    struct JobReferral has store, key {
        referrer: address,
        referral_fee: u64,
        hired: bool,
    }

    /// Function to create a new job referral.
    public fun create_referral(referrer: &signer, referral_fee: u64) {
        let referral = JobReferral {
            referrer: signer::address_of(referrer),
            referral_fee,
            hired: false,
        };
        move_to(referrer, referral);
    }

    /// Function to confirm a hire and pay the referrer.
    public fun confirm_hire(employer: &signer, referrer_address: address) acquires JobReferral {
        let referral = borrow_global_mut<JobReferral>(referrer_address);
        assert!(!referral.hired, 1); // Ensure that the referral hasn't been paid yet.
        referral.hired = true;

        // Pay the referrer the agreed-upon referral fee
        let payment = coin::withdraw<AptosCoin>(employer, referral.referral_fee);
        coin::deposit<AptosCoin>(referrer_address, payment);
    }
}
