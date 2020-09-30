#!/bin/bash

set -o errexit
set -o nounset

config_tarball()
{
	if [ ! -e ".configured" ]; then
        $SED_CMD 's|.*Threads|#&|g'                  CMakeLists.txt;

        cmake_ext_args="";
        if [[ "$CFG_TARGET_PLATFORM" == "iOS" ]]; then
            cmake_ext_args+="-DCMAKE_OSX_SYSROOT='$SYSROOT'";
        fi
        cmake "$BUILD_DIR/$SPDLOG_NAME" \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DCMAKE_PREFIX_PATH="$OUTPUT_DIR" \
            -DSPDLOG_BUILD_EXAMPLE=OFF \
            $cmake_ext_args;
        touch ".configured";
    fi
	loginfo "${CPP_LIBP2P_TARBALL} has been configured."

}


build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$SPDLOG_NAME" ]; then
        mkdir -p "$BUILD_DIR/$SPDLOG_NAME";
		tar xf "$BUILD_TARBALL_DIR/$SPDLOG_TARBALL" -C "$BUILD_DIR/$SPDLOG_NAME" --strip-components=1;
	fi
	loginfo "${SPDLOG_TARBALL//\//-} has been unpacked."
	cd "$BUILD_DIR/$SPDLOG_NAME";

    config_tarball;

	if [ ! -e ".installed" ]; then
        make -j$MAX_JOBS install;

        local libarray=$(find . -name *.a); # reserve header only
        for lib in ${libarray}; do
            rm "$OUTPUT_DIR/lib/$(basename $lib)";
        done
        touch ".installed";
    fi
	loginfo "$SPDLOG_TARBALL has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$SPDLOG_URL";
    local tarball_path="$BUILD_TARBALL_DIR/$SPDLOG_TARBALL";
	download_tarball "$tarball_url" "$tarball_path";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
