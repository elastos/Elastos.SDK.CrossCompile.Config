#!/bin/bash

set -o errexit
set -o nounset

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$CPPCODEC_NAME" ]; then
        mkdir -p "$BUILD_DIR/$CPPCODEC_NAME";
		tar xf "$BUILD_TARBALL_DIR/$CPPCODEC_TARBALL" -C "$BUILD_DIR/$CPPCODEC_NAME" --strip-components=1;
	fi
	loginfo "${CPPCODEC_TARBALL//\//-} has been unpacked."
	cd "$BUILD_DIR/$CPPCODEC_NAME";

	if [ ! -e ".configured" ]; then
        cmake_ext_args="";
        if [[ "$CFG_TARGET_PLATFORM" == "iOS" ]]; then
            cmake_ext_args+="-DCMAKE_OSX_SYSROOT='$SYSROOT'";
        fi
        cmake "$BUILD_DIR/$CPPCODEC_NAME" \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DCMAKE_PREFIX_PATH="$OUTPUT_DIR" \
            -DBUILD_TESTING=OFF \
            $cmake_ext_args;
        touch ".configured";
    fi
	loginfo "${CPPCODEC_TARBALL} has been configured."

	if [ ! -e ".installed" ]; then
        make -j$MAX_JOBS install;
        touch ".installed";
    fi
	loginfo "$CPPCODEC_TARBALL has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$CPPCODEC_URL";
    local tarball_path="$BUILD_TARBALL_DIR/$CPPCODEC_TARBALL";
	download_tarball "$tarball_url" "$tarball_path";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
