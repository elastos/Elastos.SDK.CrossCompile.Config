#!/bin/bash

set -o errexit
set -o nounset

download_tarball()
{
	if [ ! -e "$TARBALL_DIR/.$CURL_NAME" ]; then
		curl_url="$CURL_BASE_URL/$CURL_TARBALL";
		echo curl "$curl_url" --output "$TARBALL_DIR/$CURL_TARBALL";
		curl "$curl_url" --output "$TARBALL_DIR/$CURL_TARBALL";
		echo "$curl_url" > "$TARBALL_DIR/.$CURL_NAME";
	fi

	loginfo "$CURL_TARBALL has been downloaded."
}

build_curl()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$CURL_NAME" ]; then
		tar xf "$TARBALL_DIR/$CURL_TARBALL";
	fi
	loginfo "$CURL_TARBALL has been unpacked."
	cd "$BUILD_DIR/$CURL_NAME";
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
		$@

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
	download_tarball;

	build_curl $CONFIG_PARAM;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
