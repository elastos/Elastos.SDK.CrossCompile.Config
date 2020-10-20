#!/bin/bash

set -o errexit
set -o nounset

check_cargo()
{
    if [ -z "$(which cargo)" ]; then
        echo "You have to install cargo first"
        exit 1
    fi
    CARGO_PATH=$(which cargo);

    loginfo "Found cargo at [$CARGO_PATH]";
    local toolchain=;
    if [[ "$CFG_TARGET_PLATFORM" == "Android" ]]; then
        toolchain=${ANDROID_TOOLCHAIN};
    elif [[ "$CFG_TARGET_PLATFORM" == "iOS" ]]; then
        toolchain=${IOS_TOOLCHAIN/darwin/ios};
    fi

    CARGO_CFG_PATH="$(dirname "$CARGO_PATH")/../config";
    if [[ ! -z "$toolchain" ]]; then
        echo "[target.${toolchain}]"            >  "$CARGO_CFG_PATH";
        echo "ar='$CC'"                         >> "$CARGO_CFG_PATH";
        echo "linker='$CC'"                     >> "$CARGO_CFG_PATH";
    else
        rm -f "$CARGO_CFG_PATH";
    fi
}

config_tarball()
{
    if [ ! -e ".configured" ]; then
        git checkout -- .;

        $SED_CMD 's|"cdylib"|"staticlib"|'            signer-ffi/Cargo.toml;
        $SED_CMD 's|^jni .*|#&|'                               signer-ffi/Cargo.toml;
        $SED_CMD 's|^with-jni .*|#&|'                          signer-ffi/Cargo.toml;

        echo '
            pub fn get_seed_from_mnemonic(mnemonic: &str, password: &str) -> Result<[u8; 64], SignerError> {
                let mnemonic = bip39::Mnemonic::from_phrase(&mnemonic, Language::English)
                    .map_err(|err| SignerError::GenericString(err.to_string()))?;
                let seed = Seed::new(&mnemonic, password);
                Ok(seed.as_bytes().try_into().expect("seed with incorrect length"))
            }
        ' >> signer/src/lib.rs;

        echo '
            use filecoin_signer::{get_seed_from_mnemonic, key_derive_from_seed};

            create_fn!(filecoin_signer_get_seed_from_mnemonic|Java_ch_zondax_FilecoinSigner_getSeedFromMnemonic: (
                mnemonic: str_arg_ty!(),
                password: str_arg_ty!(),
                error: &mut ExternError
            ) -> str_ret_ty!(), |etc| {
                call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
                    let mnemonic = get_string!(etc, mnemonic)?;
                    let password = get_string!(etc, password)?;
                    let seed = get_seed_from_mnemonic(
                        get_string_ref(&mnemonic),
                        get_string_ref(&password),
                    )?;

                    create_string!(etc, hex::encode(seed))
                })
            });

            create_fn!(filecoin_signer_key_derive_from_seed|Java_ch_zondax_FilecoinSigner_keyDeriveFromSeed: (
                seed: *const u8,
                path: str_arg_ty!(),
                error: &mut ExternError
            ) -> ptr!(ExtendedKey), |etc| {
                call_with_result(error, || -> Result<ExtendedKey, ExternError> {
                    unsafe {
                        let seed = std::slice::from_raw_parts(seed, 64);
                        let path = get_string!(etc, path)?;
                        Ok(key_derive_from_seed(
                            seed,
                            get_string_ref(&path),
                        )?)
                    }
                })
            });
        ' >> signer-ffi/src/lib.rs;

        echo '
            create_fn!(filecoin_signer_extended_key_address|Java_ch_zondax_FilecoinSigner_extendedKeyAddress: (
                ek: &mut ExtendedKey,
                error: &mut ExternError
            ) -> str_ret_ty!(), |etc| {
                call_with_result(error, || -> Result<str_ret_ty!(), ExternError> {
                    create_string!(etc, ek.address.to_string())
                })
            });
        ' >> signer-ffi/src/extended_key.rs;

        touch ".configured";
    fi
    loginfo "${FILECOIN_SIGNING_TOOLS_TARBALL} has been configured."
}

build_tarball()
{
    mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
    loginfo "change directory to $BUILD_DIR";

    if [ ! -e "$BUILD_DIR/$FILECOIN_SIGNING_TOOLS_NAME" ]; then
        cp -r "$BUILD_TARBALL_DIR/$FILECOIN_SIGNING_TOOLS_NAME" "$BUILD_DIR/$FILECOIN_SIGNING_TOOLS_NAME";
    fi
    loginfo "${FILECOIN_SIGNING_TOOLS_TARBALL//\//-} has been unpacked."
    cd "$BUILD_DIR/$FILECOIN_SIGNING_TOOLS_NAME";

    config_tarball;

    if [ ! -e ".installed" ]; then
        check_cargo;
        rustup install nightly;
        rustup default nightly;

        local toolchain=;
        if [[ "$CFG_TARGET_PLATFORM" == "Android" ]]; then
            toolchain="${ANDROID_TOOLCHAIN}";
        elif [[ "$CFG_TARGET_PLATFORM" == "iOS" ]]; then
            toolchain="${IOS_TOOLCHAIN/darwin/ios}";
        fi

        pushd signer-ffi;

        if [[ ! -z "$toolchain" ]]; then
            rustup target add "${toolchain}";

            loginfo "building filecoin-signer-ffi";
            cargo build --package=filecoin-signer-ffi --target="${toolchain}" --release;
        else
            loginfo "building filecoin-signer-ffi";
            cargo build --package=filecoin-signer-ffi --release;
        fi

        local target_dir="../target/${toolchain}/release";
        #cargo install cbindgen;
        #loginfo "generating filecoin-signer-ffi.h";
        #RUST_BACKTRACE=1 cbindgen --clean --config cbindgen.toml --output "${target_dir}/filecoin-signer-ffi.h";

        mkdir -p "$OUTPUT_DIR"/{lib,include}/;
        cp "${target_dir}/libfilecoin_signer_ffi.a" "$OUTPUT_DIR/lib";
        #cp "$(find ${target_dir} -name filecoin-signer-ffi.h)" "$OUTPUT_DIR/include";

        popd;
        touch ".installed";
    fi
    loginfo "$FILECOIN_SIGNING_TOOLS_TARBALL has been installed."
}

main_run()
{
    loginfo "parsing options";
    getopt_parse_options $@;

    source "$SCRIPT_DIR/common/setenv.sh";

    source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$FILECOIN_SIGNING_TOOLS_BASE_URL/$FILECOIN_SIGNING_TOOLS_TARBALL";
    local tarball_version="$FILECOIN_SIGNING_TOOLS_VERSION";
    local tarball_path="$BUILD_TARBALL_DIR/$FILECOIN_SIGNING_TOOLS_NAME";
    clone_from_github "$tarball_url" "$tarball_path" "$tarball_version";

    build_tarball $@;

    loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
