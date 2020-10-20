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

        $SED_CMD 's|rlib|dylib|'                               rust/Cargo.toml;
        $SED_CMD 's|^byteorder .*|#&|'                         rust/Cargo.toml;
        $SED_CMD 's|^drop_struct_macro_derive .*|#&|'          rust/Cargo.toml;
        $SED_CMD 's|^ff .*|#&|'                                rust/Cargo.toml;
        $SED_CMD 's|^log .*|#&|'                               rust/Cargo.toml;
        $SED_CMD 's|^paired .*|#&|'                            rust/Cargo.toml;
        $SED_CMD 's|^fil_logger .*|#&|'                        rust/Cargo.toml;
        $SED_CMD 's|^anyhow .*|#&|'                            rust/Cargo.toml;
        $SED_CMD 's|^bellperson .*|#&|'                        rust/Cargo.toml;
        $SED_CMD 's|^serde_json .*|#&|'                        rust/Cargo.toml;
        $SED_CMD 's|^serde_json .*|#&|'                        rust/Cargo.toml;
        $SED_CMD 's|^neptune .*|#&|'                           rust/Cargo.toml;
        $SED_CMD 's|^neptune-triton .*|#&|'                    rust/Cargo.toml;
        $SED_CMD 's|^\[dependencies.filecoin-proofs-api\]|#&|' rust/Cargo.toml;
        $SED_CMD 's|^package = "filecoin-proofs-api"|#&|'      rust/Cargo.toml;
        $SED_CMD 's|^version = "5.1.1"|#&|'                    rust/Cargo.toml;
        $SED_CMD 's|^\[dev-dependencies\]|#&|'                 rust/Cargo.toml;
        $SED_CMD 's|^tempfile = ".*"|#&|'                      rust/Cargo.toml;

        $SED_CMD 's|^pub mod proofs;||'                        rust/src/lib.rs;
        $SED_CMD 's|^pub mod util;||'                          rust/src/lib.rs;

        $SED_CMD "s|^use crate::proofs::types::fil_32ByteArray;|#[repr(C)] pub struct fil_32ByteArray { pub inner: [u8; 32], }|g" \
                                                               rust/src/bls/api.rs;

        touch ".configured";
    fi
	loginfo "${FILECOIN_FFI_TARBALL} has been configured."
}

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$FILECOIN_FFI_NAME" ]; then
		cp -r "$BUILD_TARBALL_DIR/$FILECOIN_FFI_NAME" "$BUILD_DIR/$FILECOIN_FFI_NAME";
	fi
	loginfo "${FILECOIN_FFI_TARBALL//\//-} has been unpacked."
	cd "$BUILD_DIR/$FILECOIN_FFI_NAME";

    config_tarball;

	if [ ! -e ".installed" ]; then
        check_cargo;

        local toolchain=;
        if [[ "$CFG_TARGET_PLATFORM" == "Android" ]]; then
            toolchain="${ANDROID_TOOLCHAIN}";
        elif [[ "$CFG_TARGET_PLATFORM" == "iOS" ]]; then
            toolchain="${IOS_TOOLCHAIN/darwin/ios}";
        fi

        pushd rust;
        if [[ ! -z "$toolchain" ]]; then
            rustup target add "${toolchain}";
            cargo build --package=filcrypto --target="${toolchain}" --release;
        else
            cargo build --package=filcrypto --release;
        fi

        mkdir -p "$OUTPUT_DIR"/{lib,include}/;
        cp "target/${toolchain}/release/libfilcrypto.a" "$OUTPUT_DIR/lib";
        cp "$(find target/${toolchain}/release -name filcrypto.h)" "$OUTPUT_DIR/include";

        popd;
        touch ".installed";
    fi
	loginfo "$FILECOIN_FFI_TARBALL has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$FILECOIN_FFI_BASE_URL/$FILECOIN_FFI_TARBALL";
    local tarball_version="$FILECOIN_FFI_VERSION";
    local tarball_path="$BUILD_TARBALL_DIR/$FILECOIN_FFI_NAME";
	clone_from_github "$tarball_url" "$tarball_path" "$tarball_version";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
