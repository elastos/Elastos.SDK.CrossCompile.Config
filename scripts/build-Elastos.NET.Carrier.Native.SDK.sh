#!/bin/bash

set -o errexit
set -o nounset

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME" ]; then
		cp -r "$BUILD_TARBALL_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME" "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME";
	fi
	loginfo "${ELASTOS_NET_CARRIER_NATIVE_SDK_TARBALL//\//-} has been unpacked."
	cd "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME";

	if [ ! -e ".configured" ]; then
        cmake . \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DENABLE_SHARED=OFF;

        touch ".configured";
    fi
	loginfo "$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME has been configured."

    if [ ! -e ".installed" ]; then
        #make -j$MAX_JOBS VERBOSE=1 && make install;
        make -j$MAX_JOBS && make install;
        touch ".installed";
    fi
    loginfo "$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$ELASTOS_NET_CARRIER_NATIVE_SDK_BASE_URL/$ELASTOS_NET_CARRIER_NATIVE_SDK_TARBALL";
    local tarball_version="$ELASTOS_NET_CARRIER_NATIVE_SDK_VERSION";
    local tarball_path="$BUILD_TARBALL_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME";
	clone_from_github "$tarball_url" "$tarball_path" "$tarball_version";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
