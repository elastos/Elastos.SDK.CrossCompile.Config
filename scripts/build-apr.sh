#!/bin/bash

set -o errexit
set -o nounset

build_apr()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$APR_NAME" ]; then
        mkdir -p "$BUILD_DIR/$APR_NAME";
        tar xf "$BUILD_TARBALL_DIR/$APR_TARBALL" --directory "$BUILD_DIR/$APR_NAME" --strip-components=1;
	fi
	loginfo "$APR_TARBALL has been unpacked."
	cd "$BUILD_DIR/$APR_NAME";

	if [ ! -e ".configured" ]; then
        #./buildconf;
        ./configure --prefix=$OUTPUT_DIR \
            --enable-static \
            --disable-shared \
            ac_cv_file__dev_zero=yes \
            ac_cv_func_setpgrp_void=yes \
            apr_cv_process_shared_works=yes \
            apr_cv_mutex_robust_shared=no \
            apr_cv_tcp_nodelay_with_cork=yes \
            $@;
        touch ".configured";
    fi
	loginfo "$APR_TARBALL has been configured."

	if [ ! -e ".installed" ]; then
        mkdir -p "$OUTPUT_DIR/include/";
        #make -j$MAX_JOBS libsqlite3.la && make install-libLTLIBRARIES install-includeHEADERS install-pkgconfigDATA
	    #make -j$MAX_JOBS CFLAGS=-DAPR_IOVEC_DEFINED;
	    make -j$MAX_JOBS;
        make install;
        touch ".installed";
    fi
	loginfo "$APR_TARBALL has been installed."
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
    source "$SCRIPT_DIR/download-tarball.sh";

    local tarball_url="$APR_URL";
    local tarball_path="$BUILD_TARBALL_DIR/$APR_TARBALL";
	download_tarball "$tarball_url" "$tarball_path";

	build_apr $CONFIG_PARAM;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
