
// Append by elastos
// use filecoin_signer::api::{
//     UnsignedMessageAPI,
// };
use filecoin_signer::{
    key_derive_from_seed,
    key_recover,
    elastos_get_seed_from_mnemonic,
    elastos_get_addr_from_pubkey,
    elastos_sign,
    elastos_verify,
    elastos_gen_serialize_tx,

    PrivateKey,
    PublicKey,

    PRIVATE_KEY_SIZE,
    PUBLIC_KEY_SIZE,
};
use std::convert::TryInto;

create_fn!(elastos_filecoin_signer_get_seed_from_mnemonic|Java_elastos_FilecoinSigner_GetSeedFromMnemonic: (
    mnemonic: str_arg_ty!(),
    password: str_arg_ty!(),
    error: &mut ExternError
) -> str_ret_ty!(), |etc| {
    call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
        let mnemonic = get_string!(etc, mnemonic)?;
        let password = get_string!(etc, password)?;
        let seed = elastos_get_seed_from_mnemonic(
            get_string_ref(&mnemonic),
            get_string_ref(&password),
        )?;

        create_string!(etc, hex::encode(seed))
    })
});

create_fn!(elastos_filecoin_signer_get_privkey_from_seed|Java_elastos_FilecoinSigner_GetPrivKeyFromSeed: (
    seed: *const u8,
    seed_len: i32,
    path: str_arg_ty!(),
    error: &mut ExternError
) -> str_ret_ty!(), |etc| {
    call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
            let seed = unsafe { std::slice::from_raw_parts(seed, seed_len.try_into().unwrap()) };
            let path = get_string!(etc, path)?;
            let ek = key_derive_from_seed(seed, get_string_ref(&path))?;
            create_string!(etc, base64::encode(&ek.private_key.0))
    })
});

create_fn!(elastos_filecoin_signer_get_pubkey_from_privkey|Java_elastos_FilecoinSigner_GetPubKeyFromPrivKey: (
    privkey: str_arg_ty!(),
    error: &mut ExternError
) -> str_ret_ty!(), |etc| {
    call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
        let privkey = get_string!(etc, privkey)?;
        let privkey = get_string_ref(&privkey).to_string();
        let privkey_hex = base64::decode(privkey).expect("Decoding private key failed");
        let mut privkey = PrivateKey { 0: [0; PRIVATE_KEY_SIZE] };
        privkey.0.copy_from_slice(&privkey_hex[..PRIVATE_KEY_SIZE]);
        
        let ek = key_recover(&privkey, false)?;
        create_string!(etc, base64::encode(&ek.public_key.0))
    })
});

create_fn!(elastos_filecoin_signer_get_address|Java_Elastos_FilecoinSigner_GetAddress: (
    pubkey: str_arg_ty!(),
    error: &mut ExternError
) -> str_ret_ty!(), |etc| {
    call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
        let pubkey = get_string!(etc, pubkey)?;
        let pubkey = get_string_ref(&pubkey).to_string();
        let pubkey_hex = base64::decode(pubkey).expect("Decoding public key failed");
        let mut pubkey = PublicKey { 0: [0; PUBLIC_KEY_SIZE] };
        pubkey.0.copy_from_slice(&pubkey_hex[..PUBLIC_KEY_SIZE]);
        
        let addr = elastos_get_addr_from_pubkey(&pubkey, false)?;
        create_string!(etc, addr)
    })
});

create_fn!(elastos_filecoin_signer_sign|Java_Elastos_FilecoinSigner_Sign: (
    privkey: str_arg_ty!(),
    data: *const u8,
    data_len: i32,
    error: &mut ExternError
) -> str_ret_ty!(), |etc| {
    call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
        let privkey = get_string!(etc, privkey)?;
        let privkey = get_string_ref(&privkey).to_string();
        let privkey_hex = base64::decode(privkey).expect("Decoding private key failed");
        let mut privkey = PrivateKey { 0: [0; PRIVATE_KEY_SIZE] };
        privkey.0.copy_from_slice(&privkey_hex[..PRIVATE_KEY_SIZE]);
        
        let data = unsafe { std::slice::from_raw_parts(data, data_len.try_into().unwrap()) };

        let signature = elastos_sign(&privkey, data)?;
        // println!("sign signature: {:x?}", signature.as_bytes());
        create_string!(etc, hex::encode(signature.as_bytes()))
    })
});

create_fn!(elastos_filecoin_signer_verify|Java_Elastos_FilecoinSigner_Verify: (
    pubkey: str_arg_ty!(),
    signature: *const u8,
    signature_len: i32,
    data: *const u8,
    data_len: i32,
    error: &mut ExternError
) -> str_ret_ty!(), |etc| {
    call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
        let pubkey = get_string!(etc, pubkey)?;
        let pubkey = get_string_ref(&pubkey).to_string();
        let pubkey_hex = base64::decode(pubkey).expect("Decoding public key failed");
        let mut pubkey = PublicKey { 0: [0; PUBLIC_KEY_SIZE] };
        pubkey.0.copy_from_slice(&pubkey_hex[..PUBLIC_KEY_SIZE]);
        
        let data = unsafe { std::slice::from_raw_parts(data, data_len.try_into().unwrap()) };
        let signature = unsafe { std::slice::from_raw_parts(signature, signature_len.try_into().unwrap()) };
        // println!("verify signature: {:x?}", signature);

        let verify = elastos_verify(&pubkey, signature, data)?;
        let result = match verify {
            true => "t",
            false => "f",
        };
        create_string!(etc, result.to_string())
    })
});

create_fn!(elastos_filecoin_signer_serialize_tx|Java_Elastos_FilecoinSigner_SerializeTx: (
    unsigned_message_json: str_arg_ty!(),
    error: &mut ExternError
) -> str_ret_ty!(), |etc| {
    call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
        let unsigned_message_json = get_string!(etc, unsigned_message_json)?;
        let unsigned_message_cbor = elastos_gen_serialize_tx(get_string_ref(&unsigned_message_json))?;
        create_string!(etc, hex::encode(&unsigned_message_cbor.0))
    })
});
