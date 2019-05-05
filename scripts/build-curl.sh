#!/bin/bash

set -o errexit
set -o nounset

build_curl()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$CURL_NAME" ]; then
		tar xf "$BUILD_TARBALL_DIR/$CURL_TARBALL";
	fi
	loginfo "$CURL_TARBALL has been unpacked."
	cd "$BUILD_DIR/$CURL_NAME";

	if [ ! -e ".configured" ]; then
        ./configure --prefix=$OUTPUT_DIR \
            --with-ssl=$OUTPUT_DIR \
            --enable-static \
            --disable-shared \
            --disable-verbose \
            --enable-threaded-resolver \
            --enable-ipv6 \
            --disable-dict \
            --disable-ftp \
            --disable-gopher \
            --disable-imap \
            --disable-pop3 \
            --disable-rtsp \
            --disable-smb \
            --disable-smtp \
            --disable-telnet \
            --disable-tftp \
            --disable-ldap \
            --without-libidn2 \
            $@
        touch ".configured";
    fi
	loginfo "$CURL_TARBALL has been configured."

	make -j$MAX_JOBS -C lib libcurl.la V=1 && \
	make -C lib install-libLTLIBRARIES && \
	make -C include/curl install-pkgincludeHEADERS && \
	make install-pkgconfigDATA
}

main_run()
{

	# build openssl first.
	"$SCRIPT_DIR/build-openssl.sh" $@;

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
    source "$SCRIPT_DIR/common/download-tarball.sh";
    local tarball_url="$CURL_BASE_URL/$CURL_TARBALL";
    local tarball_path="$BUILD_TARBALL_DIR/$CURL_TARBALL";
	download_tarball "$tarball_url" "$tarball_path";

	build_curl $CONFIG_PARAM;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
