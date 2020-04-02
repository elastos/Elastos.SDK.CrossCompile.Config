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
	cd "$BUILD_DIR/$ALIOSS_NAME/sdk";

	if [ ! -e ".configured" ]; then
        local fixFilepath="$BUILD_DIR/$ALIOSS_NAME/sdk/src/utils/FileSystemUtils.cc";
        local bugfix=$(cat "$fixFilepath");
        bugfix=${bugfix/GetPathInfo(file, size, t)/GetPathInfo(file, t, size)};
        echo "$bugfix" > "$fixFilepath";

        local cmakeFilePath="$BUILD_DIR/$ALIOSS_NAME/sdk/CMakeLists.txt";
        echo 'cmake_minimum_required(VERSION 3.12)'                                             >  "$cmakeFilePath";
        echo 'include('"$SCRIPT_PARENT_DIR"'/cmake/CMakeLists.txt)'                             >> "$cmakeFilePath";
        echo 'project(alibabacloud-oss-cpp-sdk VERSION '${ALIOSS_VERSION}')'                    >> "$cmakeFilePath";
        echo 'message(STATUS "Project version: ${PROJECT_VERSION}")'                            >> "$cmakeFilePath";
        echo 'pkg_search_module(pkg-ssl REQUIRED openssl)'                                      >> "$cmakeFilePath";
        echo 'pkg_search_module(pkg-curl REQUIRED libcurl)'                                     >> "$cmakeFilePath";
        echo 'file( GLOB_RECURSE ${PROJECT_NAME}-SOURCES src *.cc *.cpp)'                       >> "$cmakeFilePath";
        echo 'add_library(${PROJECT_NAME})'                                                     >> "$cmakeFilePath";
        echo 'target_sources(${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}-SOURCES})'               >> "$cmakeFilePath";
        echo 'target_include_directories(${PROJECT_NAME} PRIVATE "include")'                    >> "$cmakeFilePath";
        echo 'target_include_directories(${PROJECT_NAME} PRIVATE "include/alibabacloud/oss")'   >> "$cmakeFilePath";
        echo 'target_include_directories(${PROJECT_NAME} PRIVATE "src/external")'               >> "$cmakeFilePath";
        echo 'target_include_directories(${PROJECT_NAME} PRIVATE "${pkg-ssl_INCLUDE_DIRS}")'    >> "$cmakeFilePath";
        echo 'target_link_libraries(${PROJECT_NAME} PRIVATE "${pkg-ssl_STATIC_LDFLAGS}")'       >> "$cmakeFilePath";
        echo 'target_include_directories(${PROJECT_NAME} PRIVATE "${pkg-curl_INCLUDE_DIRS}")'   >> "$cmakeFilePath";
        echo 'target_link_libraries(${PROJECT_NAME} PRIVATE "${pkg-curl_STATIC_LDFLAGS}")'      >> "$cmakeFilePath";
        echo 'install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ' \
                                             'lib ARCHIVE DESTINATION)' \
                                                                                                >> "$cmakeFilePath";
        echo 'install(DIRECTORY include/alibabacloud DESTINATION include)' \
                                                                                                >> "$cmakeFilePath";

        local cmake_ext_args="";
        if [[ $CFG_TARGET_PLATFORM == "Android" ]]; then
            cmake_ext_args+=" -DCFG_ANDROID_TOOLCHAIN_PATH=$CFG_ANDROID_TOOLCHAIN_PATH";
            cmake_ext_args+=" -DCFG_ANDROID_SDK=$CFG_ANDROID_SDK";
        fi
        echo $cmake_ext_args;
        cmake "$BUILD_DIR/$ALIOSS_NAME/sdk" \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DCMAKE_PREFIX_PATH="$OUTPUT_DIR" \
            -DCFG_TARGET_PLATFORM=$CFG_TARGET_PLATFORM \
            -DCFG_TARGET_ABI=$CFG_TARGET_ABI \
            $cmake_ext_args;
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
