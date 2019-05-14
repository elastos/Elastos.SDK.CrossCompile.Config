#!/bin/bash

set -o errexit
set -o nounset

build_json()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$JSON_NAME" ]; then
		unzip "$BUILD_TARBALL_DIR/$JSON_TARBALL" -d "$BUILD_DIR/$JSON_NAME";
	fi
	loginfo "$JSON_TARBALL has been unpacked."
	cd "$BUILD_DIR/$JSON_NAME";

	if [ ! -e ".configured" ]; then
        touch ".configured";
    fi
	loginfo "$JSON_TARBALL has been configured."

	#make -j$MAX_JOBS && make install_engine
	if [ ! -e ".installed" ]; then
        cp -r "$BUILD_DIR/$JSON_NAME/include/"* "$OUTPUT_DIR/include";
        touch ".installed";
    fi
	loginfo "$JSON_TARBALL has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";
	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";

    local tarball_url="$JSON_URL";
    local tarball_path="$BUILD_TARBALL_DIR/$JSON_TARBALL";
	download_tarball "$tarball_url" "$tarball_path";

	build_json;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
