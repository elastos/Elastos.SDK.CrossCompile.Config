
// Append by elastos
pub const PRIVATE_KEY_SIZE: usize = SECRET_KEY_SIZE;
pub const PUBLIC_KEY_SIZE: usize = FULL_PUBLIC_KEY_SIZE;

pub fn elastos_get_seed_from_mnemonic(
    mnemonic: &str,
    password: &str
) -> Result<[u8; 64], SignerError> {
    let mnemonic = bip39::Mnemonic::from_phrase(&mnemonic, Language::English)
        .map_err(|err| SignerError::GenericString(err.to_string()))?;
    let seed = Seed::new(&mnemonic, password);
    Ok(seed.as_bytes().try_into().expect("seed with incorrect length"))
}

pub fn elastos_get_addr_from_pubkey(
    public_key: &PublicKey,
    testnet: bool
) -> Result<String, SignerError> {
    let public_key = secp256k1::PublicKey::parse_slice(&public_key.0, None)?;
    let mut address = Address::new_secp256k1(&public_key.serialize())?;

    if testnet {
        address.set_network(Network::Testnet);
    } else {
        address.set_network(Network::Mainnet);
    }

    Ok(address.to_string())
}

pub fn elastos_sign(
    private_key: &PrivateKey,
    data: &[u8],
) -> Result<Signature, SignerError> {
    let message_cbor = CborBuffer(data.to_vec());

    let secret_key = secp256k1::SecretKey::parse_slice(&private_key.0)?;

    let cid_hashed = utils::get_digest(message_cbor.as_ref())?;

    let message_digest = Message::parse_slice(&cid_hashed)?;

    let (signature_rs, recovery_id) = sign(&message_digest, &secret_key);

    let mut signature = SignatureSECP256K1 { 0: [0; 65] };
    signature.0[..64].copy_from_slice(&signature_rs.serialize()[..]);
    signature.0[64] = recovery_id.serialize();

    let signature = Signature::SignatureSECP256K1(signature);
    Ok(signature)
}

pub fn elastos_verify(
    public_key: &PublicKey,
    signature: &[u8],
    data: &[u8],
) -> Result<bool, SignerError> {
    let cbor_buffer = CborBuffer(data.to_vec());
    let message_digest = utils::get_digest(cbor_buffer.as_ref())?;
    let blob_to_sign = Message::parse_slice(&message_digest)?;

    let signature_rs = secp256k1::Signature::parse_slice(&signature[..SIGNATURE_SIZE])?;

    let public_key = secp256k1::PublicKey::parse_slice(&public_key.0, None)?;

    Ok(verify(&blob_to_sign, &signature_rs, &public_key))
}

pub fn elastos_gen_serialize_tx(
    unsigned_message_json: &str,
) -> Result<CborBuffer, SignerError> {
    let unsigned_message_api: UnsignedMessageAPI
         = serde_json::from_str(unsigned_message_json).expect("Could not deserialize unsigned message");
    let unsigned_message_cbor = transaction_serialize(&unsigned_message_api)?;

    Ok(unsigned_message_cbor)
}

pub fn elastos_is_valid_address(
    address: &str,
) -> Result<bool, SignerError> {
    let _address = Address::from_str(address)?;
    Ok(true)
}
