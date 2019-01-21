#!/bin/bash

set -o errexit
set -o nounset

download_tarball()
{
	if [ ! -e "$TARBALL_DIR/.$ELASTOS_SDK_KEYPAIR_C_NAME" ]; then
		local url="$ELASTOS_SDK_KEYPAIR_C_BASE_URL/$ELASTOS_SDK_KEYPAIR_C_TARBALL";
		echo git clone "$url" "$TARBALL_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME";
		git clone --depth=1 "$url" "$TARBALL_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME";
		echo "$url" > "$TARBALL_DIR/.$ELASTOS_SDK_KEYPAIR_C_NAME";
	fi

	loginfo "$ELASTOS_SDK_KEYPAIR_C_TARBALL has been downloaded."
}

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME" ]; then
		cp -r "$TARBALL_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME" "$BUILD_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME";
	fi
	loginfo "${ELASTOS_SDK_KEYPAIR_C_TARBALL//\//-} has been unpacked."
	cd "$BUILD_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME";

	#export CFLAGS="-DELASTOS_SDK_KEYPAIR_C_NOHAVE_SYSTEM"
	./scripts/build.sh --prefix=$BUILD_ROOT_DIR \
		--enable-static \
		--without-depends \
		$@
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
	download_tarball;

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
