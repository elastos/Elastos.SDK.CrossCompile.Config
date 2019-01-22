#!/bin/bash

set -o errexit
set -o nounset

download_tarball()
{
	if [ ! -e "$TARBALL_DIR/.$SQLITE_NAME" ]; then
		sqlite_url="$SQLITE_BASE_URL/$SQLITE_TARBALL";
		echo curl "$sqlite_url" --output "$TARBALL_DIR/$SQLITE_TARBALL";
		curl "$sqlite_url" --output "$TARBALL_DIR/$SQLITE_TARBALL";
		echo "$sqlite_url" > "$TARBALL_DIR/.$SQLITE_NAME";
	fi

	loginfo "$SQLITE_TARBALL has been downloaded."
}

build_sqlite()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$SQLITE_NAME" ]; then
		tar xf "$TARBALL_DIR/$SQLITE_TARBALL";
	fi
	loginfo "$SQLITE_TARBALL has been unpacked."
	cd "$BUILD_DIR/$SQLITE_NAME";

	if [ ! -e ".configured" ]; then
        #export CFLAGS="-DSQLITE_NOHAVE_SYSTEM"
        ./configure --prefix=$OUTPUT_DIR \
            --enable-static \
            --disable-shared \
            --disable-static-shell \
            $@
        touch ".configured";
    fi
	loginfo "$SQLITE_TARBALL has been configured."

	make -j$MAX_JOBS libsqlite3.la && make install-libLTLIBRARIES install-includeHEADERS install-pkgconfigDATA
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";
	case "$CFG_TARGET_PLATFORM" in
		(Android)
			CONFIG_PARAM="--host=$ANDROID_TOOLCHAIN --target=$ANDROID_TOOLCHAIN";
			;;
		(iOS)
			CONFIG_PARAM="--host=$IOS_TOOLCHAIN --target=$IOS_TOOLCHAIN";
			;;
		(*)
			CONFIG_PARAM=;
			;;
	esac

	source "$SCRIPT_DIR/tarball-config.sh";
	download_tarball;

	build_sqlite $CONFIG_PARAM;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
