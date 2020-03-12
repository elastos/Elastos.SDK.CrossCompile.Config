#!/bin/bash

set -o errexit
set -o nounset

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME" ]; then
		cp -r "$BUILD_TARBALL_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME" "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME";
        #cd "$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME" && git am 259.patch;
	fi
	loginfo "${ELASTOS_NET_CARRIER_NATIVE_SDK_TARBALL//\//-} has been unpacked."
    local project_dir="$BUILD_DIR/$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME";
    mkdir -p "$project_dir/build/${CFG_TARGET_PLATFORM}";
	cd "$project_dir/build/${CFG_TARGET_PLATFORM}";
	#cd "$project_dir";

    #PATH="/usr/bin:$PATH";
    if [ ! -e ".configured" ]; then
        filepath="$project_dir/deps/CMakeLists.txt";
        local cunitIdx=$(grep -n "add_submodule.*CUnit" $filepath);
        cunitIdx=${cunitIdx%%:*};
        if ((cunitIdx > 0)); then
            #echo "cunitIdx=$cunitIdx";
            local bugContent=$(cat "$filepath");
            local bugHead=$(echo "$bugContent" |head -n $((cunitIdx - 1)));
            local bugRemoved="$(echo && echo '#Remove CUnit' && echo ' ')";
            local bugTail=$(echo "$bugContent" |tail -n +$((cunitIdx + 2)));
            local bugfix="$bugHead$bugRemoved$bugTail";
            #echo "bugfix=$bugfix";
            echo "$bugfix" > "$filepath";
        fi

        local ext=;
        if [[ "${CFG_TARGET_PLATFORM}" == "Android" ]]; then
            rm -f .android_toolchain;
            ln -sf $CFG_ANDROID_TOOLCHAIN_PATH .android_toolchain;

            local filepath="$project_dir/cmake/${CFG_TARGET_PLATFORM}Toolchain.cmake";
            local cmake_toolchain=$(cat "$filepath");
            cmake_toolchain=${cmake_toolchain/CMAKE_SYSTEM_VERSION 21/CMAKE_SYSTEM_VERSION ${CFG_ANDROID_SDK}};
            echo "$cmake_toolchain" > "$filepath";

            filepath="$project_dir/deps/platform-specific/CMakeLists.txt";
            local bugfix=$(cat "$filepath");
            bugfix=${bugfix/if(ANDROID)/if(!ANDROID)};
            bugfix=${bugfix/CMAKE_ARGS -DCMAKE_INSTALL_PREFIX/CMAKE_COMMAND CFLAGS=; cmake CMAKE_ARGS -DCMAKE_INSTALL_PREFIX};
            bugfix=${bugfix/CMAKE_ARGS -DCMAKE_INSTALL_PREFIX/CMAKE_ARGS -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_INSTALL_PREFIX};
            echo "$bugfix" > "$filepath";

            filepath="$project_dir/deps/cJSON/CMakeLists.txt";
            local bugfix=$(cat "$filepath");
            bugfix=${bugfix/CMAKE_ARGS -DCMAKE_INSTALL_PREFIX/CMAKE_ARGS -DENABLE_CJSON_TEST=Off -DCMAKE_INSTALL_PREFIX};
            echo "$bugfix" > "$filepath";

            filepath="$project_dir/deps/CUnit/CMakeLists.txt";
            local bugfix=$(cat "$filepath");
            bugfix=${bugfix/CONFIGURE_COMMAND.*/CONFIGURE_COMMAND echo done};
            bugfix=${bugfix/BUILD_COMMAND.*/BUILD_COMMAND echo done};
            bugfix=${bugfix/INSTALL_COMMAND.*/INSTALL_COMMAND echo done};
            echo "$bugfix" > "$filepath";

            filepath="$project_dir/src/session/CMakeLists.txt";
            local bugfix=$(cat "$filepath");
            bugfix=${bugfix/add_subdirectory(pseudotcp)/};
            echo "$bugfix" > "$filepath";

            local eol=$'\n'

            filepath="$project_dir/src/carrier/ela_carrier.c";
            local bugfix=$(cat "$filepath");
            bugfix="#include <unistd.h>$eol$bugfix";
            echo "$bugfix" > "$filepath";

            filepath="$project_dir/src/carrier/dstore/dstore.c";
            local bugfix=$(cat "$filepath");
            bugfix="#define MAXPATHLEN 1024$eol$bugfix";
            echo "$bugfix" > "$filepath";

            SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

            #ext+=" -DANDROID_ABI=$CFG_TARGET_ABI";
            ext+=" -DCFG_ANDROID_SDK=$CFG_ANDROID_SDK";
            ext+=" -DCFG_TARGET_PLATFORM=$CFG_TARGET_PLATFORM";
            ext+=" -DCFG_ANDROID_TOOLCHAIN_PATH=$CFG_ANDROID_TOOLCHAIN_PATH";
            ext+=" -DCFG_TARGET_ABI=$CFG_TARGET_ABI";

            ext+=" -DCMAKE_C_COMPILER_WORKS=true";
            ext+=" -DCMAKE_CXX_COMPILER_WORKS=true";
            ext+=" -DHAVE_SYS_EVENTFD_H=1";
            ext+=" -DCMAKE_CROSSCOMPILING=true";
            ext+=" -DCMAKE_TOOLCHAIN_FILE=$SCRIPT_DIR/../cmake/CMakeLists.txt";
            ext+=" -DCMAKE_ANDROID_ARCH_HEADER_TRIPLE=$ANDROID_TOOLCHAIN";
            #ext+=" -DCMAKE_TOOLCHAIN_FILE=$project_dir/cmake/${CFG_TARGET_PLATFORM}Toolchain.cmake";
        elif [[ "${CFG_TARGET_PLATFORM}" == "iOS" ]]; then
            local filepath="$project_dir/cmake/${CFG_TARGET_PLATFORM}Toolchain.cmake";
            local cmake_toolchain=$(cat "$filepath");
            cmake_toolchain=${cmake_toolchain/IOS_DEPLOYMENT_TARGET \"9.0\"/IOS_DEPLOYMENT_TARGET \"${IPHONEOS_DEPLOYMENT_TARGET}\"};
            echo "$cmake_toolchain" > "$filepath";

            local platform="iphonesimulator";
            if [[ "${CFG_TARGET_ABI}" != "x86_64" ]]; then
                platform="iphoneos";
            fi
            ext+=" -DIOS_PLATFORM=$platform";
            ext+=" -DCMAKE_CROSSCOMPILING=true";
            ext+=" -DCMAKE_TOOLCHAIN_FILE=$project_dir/cmake/${CFG_TARGET_PLATFORM}Toolchain.cmake";
        fi

        cmake $project_dir \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DENABLE_SHARED=OFF \
            -DENABLE_TESTS=OFF \
            -DENABLE_APPS=OFF \
            -DENABLE_DOCS=OFF \
            -DCMAKE_CROSSCOMPILING=ON \
            $ext;

            #-DENABLE_SHARED=OFF \

        touch ".configured";
    fi
	loginfo "$ELASTOS_NET_CARRIER_NATIVE_SDK_NAME has been configured."

    if [ ! -e ".installed" ]; then
        if [[ "${CFG_TARGET_PLATFORM}" == "iOS" ]]; then
            export IPHONEOS_DEPLOYMENT_TARGET=;
            export CFLAGS=;
            export CXXFLAGS=;
            export LDFLAGS=;
        fi
        #make -j$MAX_JOBS VERBOSE=1 && make install;
        make -j$MAX_JOBS && make install;
        if [ $? != 0 ]; then # make again, for hive build bug.
            exit 1;
        fi

        #cp "intermediates/lib/libhive-api.a" "$OUTPUT_DIR/lib";
        #cp "intermediates/lib/libhive-api++.a" "$OUTPUT_DIR/lib";
        #cp "intermediates/lib/libsrtp.a" "$OUTPUT_DIR/lib";
        #cp "intermediates/lib/libtoxcore.a" "$OUTPUT_DIR/lib";
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

    #local patch_name="259.patch";
    #if [ ! -e "$tarball_path/$patch_name" ]; then
        #cd "$tarball_path" && wget "${tarball_url%.git}/pull/259.patch"
    #fi

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
