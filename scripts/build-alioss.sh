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
	cd "$BUILD_DIR/$ALIOSS_NAME";

	if [ ! -e ".configured" ]; then
        local cmakeFilePath="$BUILD_DIR/$ALIOSS_NAME/CMakeLists.txt";
        echo 'cmake_minimum_required(VERSION 3.12)'                                             >  "$cmakeFilePath";
        echo 'include('"$SCRIPT_PARENT_DIR"'/cmake/CMakeLists.txt)'                             >> "$cmakeFilePath";
        echo 'project(oss_c_sdk)'                                                               >> "$cmakeFilePath";
        echo 'pkg_search_module(pkg-apr REQUIRED apr-1)'                                        >> "$cmakeFilePath";
        echo 'pkg_search_module(pkg-curl REQUIRED libcurl)'                                     >> "$cmakeFilePath";

        echo 'include_directories("${CMAKE_INSTALL_PREFIX}/include")'                           >> "$cmakeFilePath";
        echo 'include_directories("${pkg-curl_INCLUDE_DIRS}")'                                  >> "$cmakeFilePath";
        echo 'include_directories("${pkg-apr_INCLUDE_DIRS}")'                                   >> "$cmakeFilePath";

        echo 'file( GLOB oss_c_sdk-SOURCES "oss_c_sdk/*.c" )'                                   >> "$cmakeFilePath";
        echo 'file( GLOB oss_c_sdk-HEADERS "oss_c_sdk/*.h")'                                    >> "$cmakeFilePath";
        echo 'add_library(oss_c_sdk)'                                                           >> "$cmakeFilePath";
        echo 'target_sources(oss_c_sdk PRIVATE ${oss_c_sdk-SOURCES})'                           >> "$cmakeFilePath";

        echo 'set_target_properties(oss_c_sdk PROPERTIES PUBLIC_HEADER "${oss_c_sdk-HEADERS}")' >> "$cmakeFilePath";
        echo 'install(TARGETS oss_c_sdk LIBRARY DESTINATION lib ARCHIVE DESTINATION lib PUBLIC_HEADER DESTINATION include)' \
                                                                                                >> "$cmakeFilePath";
        echo 'add_subdirectory(oss_c_sdk_sample)'                                               >> "$cmakeFilePath";

        cmake "$BUILD_DIR/$ALIOSS_NAME" \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR";
        touch ".configured";
    fi
	loginfo "$ALIOSS_TARBALL has been configured."

    if [ ! -e ".installed" ]; then
        mkdir -p "$OUTPUT_DIR/include/";
        #make -j$MAX_JOBS libsqlite3.la && make install-libLTLIBRARIES install-includeHEADERS install-pkgconfigDATA
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
