#!/bin/bash

set -o errexit
set -o nounset

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME" ]; then
		cp -r "$BUILD_TARBALL_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME" "$BUILD_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME";
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
    source "$SCRIPT_DIR/common/download-tarball.sh";
    local tarball_url="$ELASTOS_SDK_KEYPAIR_C_BASE_URL/$ELASTOS_SDK_KEYPAIR_C_TARBALL";
    local tarball_path="$BUILD_TARBALL_DIR/$ELASTOS_SDK_KEYPAIR_C_NAME";
	clone_from_github "$tarball_url" "$tarball_path";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
