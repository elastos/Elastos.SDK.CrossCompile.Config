#!/bin/bash

set -o errexit
set -o nounset

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME" ]; then
		cp -r "$BUILD_TARBALL_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME" "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME";
        cd "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME" && git am 259.patch;
	fi
	loginfo "${ELASTOS_NET_CARRIER_NATIVE_SDK_TARBALL//\//-} has been unpacked."
    local project_dir="$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME";
    mkdir -p "$project_dir/build/${CFG_TARGET_PLATFORM}";
	cd "$project_dir/build/${CFG_TARGET_PLATFORM}";
	#cd "$project_dir";

    PATH="/usr/bin:$PATH";
	if [ ! -e ".configured" ]; then
        local ext=;
        if [[ "${CFG_TARGET_PLATFORM}" == "Android" ]]; then
            local cmake_toolchain=$(cat $project_dir/cmake/${CFG_TARGET_PLATFORM}Toolchain.cmake);
            cmake_toolchain=${cmake_toolchain/CMAKE_SYSTEM_VERSION 21/CMAKE_SYSTEM_VERSION 16};
            echo "$cmake_toolchain" > $project_dir/cmake/${CFG_TARGET_PLATFORM}Toolchain.cmake;

            ext+=" -DANDROID_ABI=$CFG_TARGET_ABI";
            ext+=" -DCMAKE_TOOLCHAIN_FILE=$project_dir/cmake/${CFG_TARGET_PLATFORM}Toolchain.cmake";
        elif [[ "${CFG_TARGET_PLATFORM}" == "iOS" ]]; then
            ext+="-DCMAKE_TOOLCHAIN_FILE=$project_dir/cmake/${CFG_TARGET_PLATFORM}Toolchain.cmake";
        fi

        cmake $project_dir \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DENABLE_SHARED=OFF \
            -DENABLE_TESTS=OFF \
            -DENABLE_APPS=OFF \
            -DENABLE_DOCS=OFF \
            $ext;

            #-DENABLE_SHARED=OFF \

        touch ".configured";
    fi
	loginfo "$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME has been configured."

    if [ ! -e ".installed" ]; then
        #make -j$MAX_JOBS VERBOSE=1 && make install;
        make -j$MAX_JOBS && make install;
        cp -f "intermediates/lib/libhive-api.a" "$OUTPUT_DIR/lib";
        cp "intermediates/lib/libhive-api++.a" "$OUTPUT_DIR/lib";
        cp "intermediates/lib/libsrtp.a" "$OUTPUT_DIR/lib";
        cp "intermediates/lib/libtoxcore.a" "$OUTPUT_DIR/lib";
        touch ".installed";
    fi
    loginfo "$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME has been installed."
}

main_run()
{
	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$ELASTOS_NET_CARRIER_NATIVE_SDK_BASE_URL/$ELASTOS_NET_CARRIER_NATIVE_SDK_TARBALL";
    local tarball_version="$ELASTOS_NET_CARRIER_NATIVE_SDK_VERSION";
    local tarball_path="$BUILD_TARBALL_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME";
	clone_from_github "$tarball_url" "$tarball_path" "$tarball_version";

    local patch_name="259.patch";
    if [ ! -e "$tarball_path/$patch_name" ]; then
        cd "$tarball_path" && wget "${tarball_url%.git}/pull/259.patch"
    fi

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
