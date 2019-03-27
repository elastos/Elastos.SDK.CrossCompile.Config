#!/bin/bash

set -o errexit
set -o nounset

download_tarball()
{
	if [ ! -e "$TARBALL_DIR/.$OPENSSL_NAME" ]; then
		openssl_url="$OPENSSL_BASE_URL/$OPENSSL_TARBALL";
		echo curl "$openssl_url" --output "$TARBALL_DIR/$OPENSSL_TARBALL";
		curl "$openssl_url" --output "$TARBALL_DIR/$OPENSSL_TARBALL";
		echo "$openssl_url" > "$TARBALL_DIR/.$OPENSSL_NAME";
	fi

	loginfo "$OPENSSL_TARBALL has been downloaded."
}

build_openssl()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$OPENSSL_NAME" ]; then
		tar xf "$TARBALL_DIR/$OPENSSL_TARBALL";
	fi
	loginfo "$OPENSSL_TARBALL has been unpacked."
	cd "$BUILD_DIR/$OPENSSL_NAME";

	if [ ! -e ".configured" ]; then
        $@ --prefix=$OUTPUT_DIR \
            no-asm \
            no-shared \
            no-cast \
            no-idea \
            no-camellia;
        touch ".configured";
    fi
	loginfo "$OPENSSL_TARBALL has been configured."

	#make -j$MAX_JOBS && make install_engine
	make install_dev
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";
	case "$CFG_TARGET_PLATFORM" in
		(Android)
			export ANDROID_NDK="$CFG_ANDROID_TOOLCHAIN_PATH";
			local arch=${CFG_TARGET_ABI%-*};
			arch=${arch%eabi};
			CONFIG_PARAM="./Configure android-$arch";
			;;
		(iOS)
			[[ "$CFG_TARGET_ABI" = "x86_64" ]] && arch="iossimulator" || arch="ios64"
			CONFIG_PARAM="./Configure $arch-xcrun"
			;;
		(*)
			CONFIG_PARAM="./config";
			;;
	esac

	source "$SCRIPT_DIR/tarball-config.sh";
	download_tarball;

	build_openssl $CONFIG_PARAM;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
