#!/bin/bash

set -o errexit
set -o nounset

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$PERSONALSTORAGE_SDK_OSS_NAME" ]; then
		cp -r "$BUILD_TARBALL_DIR/$PERSONALSTORAGE_SDK_OSS_NAME" "$BUILD_DIR/$PERSONALSTORAGE_SDK_OSS_NAME";
	fi
	loginfo "${PERSONALSTORAGE_SDK_OSS_TARBALL//\//-} has been unpacked."
	cd "$BUILD_DIR/$PERSONALSTORAGE_SDK_OSS_NAME";

	#export CFLAGS="-DPERSONALSTORAGE_SDK_OSS_NOHAVE_SYSTEM"
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
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$PERSONALSTORAGE_SDK_OSS_BASE_URL/$PERSONALSTORAGE_SDK_OSS_TARBALL";
    local tarball_version="$PERSONALSTORAGE_SDK_OSS_VERSION";
    local tarball_path="$BUILD_TARBALL_DIR/$PERSONALSTORAGE_SDK_OSS_NAME";
	clone_from_github "$tarball_url" "$tarball_path" "$tarball_version";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
