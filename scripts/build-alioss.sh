#!/bin/bash

set -o errexit
set -o nounset

build_alioss()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$ALIOSS_NAME" ]; then
        mkdir -p "$BUILD_DIR/$ALIOSS_NAME";
        tar xf "$BUILD_TARBALL_DIR/$ALIOSS_TARBALL" --directory "$BUILD_DIR/$ALIOSS_NAME" --strip-components=1;
	fi
	loginfo "$ALIOSS_TARBALL has been unpacked."
	cd "$BUILD_DIR/$ALIOSS_NAME";

	if [ ! -e ".configured" ]; then
        local cmakeFilePath="$BUILD_DIR/$ALIOSS_NAME/sample/CMakeLists.txt";
        echo ''                                         >> "$cmakeFilePath";
        echo 'target_link_libraries(${PROJECT_NAME} z)' >> "$cmakeFilePath";

        cmake "$BUILD_DIR/$ALIOSS_NAME" \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DCMAKE_PREFIX_PATH="$OUTPUT_DIR" \
            -DOPENSSL_ROOT_DIR="$OUTPUT_DIR";
        touch ".configured";
    fi
	loginfo "$ALIOSS_TARBALL has been configured."

    if [ ! -e ".installed" ]; then
        mkdir -p "$OUTPUT_DIR/include/";
        make -j$MAX_JOBS;
        make install;
        touch ".installed";
    fi
    loginfo "$ALIOSS_TARBALL has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";
	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";

    local tarball_url="$ALIOSS_URL";
    local tarball_path="$BUILD_TARBALL_DIR/$ALIOSS_TARBALL";
	download_tarball "$tarball_url" "$tarball_path";

	build_alioss $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
