#!/bin/bash

set -o errexit
set -o nounset

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$BOOST_NAME" ]; then
        mkdir -p "$BUILD_DIR/$BOOST_NAME";
		tar xf "$BUILD_TARBALL_DIR/$BOOST_TARBALL" -C "$BUILD_DIR/$BOOST_NAME" --strip-components=1;
	fi
	loginfo "$BOOST_TARBALL has been unpacked."
	cd "$BUILD_DIR/$BOOST_NAME";

    if [ ! -e ".installed" ]; then
       env -i ./bootstrap.sh --with-toolset=clang --without-icu --with-libraries=date_time,random,program_options;
        ./b2 \
            --prefix="$OUTPUT_DIR" \
            --build-type=minimal \
            --no-cmake-config \
            cxxflags="$CXXFLAGS" \
            link=static \
            install;

        local libarray=$(find . -name *.a); # reserve header only
        for lib in ${libarray}; do
            rm "$OUTPUT_DIR/lib/$(basename $lib)";
        done
        touch ".installed";
    fi
    loginfo "$BOOST_TARBALL has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$BOOST_URL";
    local tarball_path="$BUILD_TARBALL_DIR/$BOOST_TARBALL";
	download_tarball "$tarball_url" "$tarball_path";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
