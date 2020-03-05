#!/bin/bash

set -o errexit
set -o nounset

build_minixml()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$MINIXML_NAME" ]; then
        mkdir -p "$BUILD_DIR/$MINIXML_NAME";
        tar xf "$BUILD_TARBALL_DIR/$MINIXML_TARBALL" --directory "$BUILD_DIR/$MINIXML_NAME" --strip-components=1;
	fi
	loginfo "$MINIXML_TARBALL has been unpacked."
	cd "$BUILD_DIR/$MINIXML_NAME";

	if [ ! -e ".configured" ]; then
        ./configure --prefix=$OUTPUT_DIR \
            --enable-static \
            --disable-shared \
            $@;
        touch ".configured";
    fi
	loginfo "$MINIXML_TARBALL has been configured."

	if [ ! -e ".installed" ]; then
        mkdir -p "$OUTPUT_DIR/include/";
        #make -j$MAX_JOBS libsqlite3.la && make install-libLTLIBRARIES install-includeHEADERS install-pkgconfigDATA
	    make -j$MAX_JOBS && make install;
        touch ".installed";
    fi
	loginfo "$MINIXML_TARBALL has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";
	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";

    local tarball_url="$MINIXML_URL";
    local tarball_path="$BUILD_TARBALL_DIR/$MINIXML_TARBALL";
	download_tarball "$tarball_url" "$tarball_path";

	build_minixml;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
