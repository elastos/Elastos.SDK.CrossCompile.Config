#!/bin/bash

set -o errexit
set -o nounset

config_tarball()
{
	if [ ! -e ".configured" ]; then
        git checkout -- .;

        $SED_CMD 's|include("cmake/Hunter/init.cmake")|#&|'                  CMakeLists.txt;
        $SED_CMD 's|HunterGate(|message(VERBOSE|'                            CMakeLists.txt;
        $SED_CMD 's|include(cmake/dependencies.cmake)|#&|'                   CMakeLists.txt;
        $SED_CMD 's|add_subdirectory(example)|#&|'                           CMakeLists.txt;
        $SED_CMD 's|add_subdirectory(test)|#&|'                              CMakeLists.txt;

        $SED_CMD 's|.*|#&|'                                                  src/CMakeLists.txt;
        echo "" >>                                                           src/CMakeLists.txt;
        echo "include_directories(${OUTPUT_DIR}/include)" >>                 src/CMakeLists.txt;
        echo "add_subdirectory(common)" >>                                   src/CMakeLists.txt;
        echo "add_subdirectory(crypto)" >>                                   src/CMakeLists.txt;
        echo "add_subdirectory(multi)" >>                                    src/CMakeLists.txt;

        $SED_CMD 's|.*|#&|'                                                  src/common/CMakeLists.txt;
        echo "" >>                                                           src/common/CMakeLists.txt;
        echo "libp2p_add_library(p2p_hexutil" >>                             src/common/CMakeLists.txt;
        echo "hexutil.cpp" >>                                                src/common/CMakeLists.txt;
        echo ")" >>                                                          src/common/CMakeLists.txt;

        $SED_CMD 's|.*|#&|'                                                  src/crypto/CMakeLists.txt;
        echo "" >>                                                           src/crypto/CMakeLists.txt;
        echo "add_subdirectory(sha)" >>                                      src/crypto/CMakeLists.txt;
        $SED_CMD 's|OpenSSL.*|#&|'                                           src/crypto/sha/CMakeLists.txt;

        $SED_CMD 's|.*|#&|'                                                  src/multi/CMakeLists.txt;
        echo "" >>                                                           src/multi/CMakeLists.txt;
        echo "add_subdirectory(multibase_codec)" >>                          src/multi/CMakeLists.txt;
        echo "libp2p_add_library(p2p_multihash" >>                           src/multi/CMakeLists.txt;
        echo "multihash.cpp" >>                                              src/multi/CMakeLists.txt;
        echo ")" >>                                                          src/multi/CMakeLists.txt;
        echo "libp2p_add_library(p2p_uvarint" >>                             src/multi/CMakeLists.txt;
        echo "uvarint.cpp" >>                                                src/multi/CMakeLists.txt;
        echo ")" >>                                                          src/multi/CMakeLists.txt;
        echo "libp2p_add_library(p2p_cid" >>                                 src/multi/CMakeLists.txt;
        echo "content_identifier.cpp" >>                                     src/multi/CMakeLists.txt;
        echo "content_identifier_codec.cpp" >>                               src/multi/CMakeLists.txt;
        echo ")" >>                                                          src/multi/CMakeLists.txt;
        $SED_CMD 's|Boost::boost|#&|'                                        src/multi/multibase_codec/CMakeLists.txt;
        $SED_CMD 's|gsl/span|gsl/span_ext|'                                  src/multi/multibase_codec/codecs/base32.cpp;
        local content=$(cat src/multi/multibase_codec/codecs/base32.cpp);
        echo '#pragma GCC diagnostic ignored "-Wsign-compare"' >             src/multi/multibase_codec/codecs/base32.cpp;
        echo "$content" >>                                                     src/multi/multibase_codec/codecs/base32.cpp;

        cmake_ext_args="";
        if [[ "$CFG_TARGET_PLATFORM" == "iOS" ]]; then
            cmake_ext_args+="-DCMAKE_OSX_SYSROOT='$SYSROOT'";
        fi
        cmake "$BUILD_DIR/$CPP_LIBP2P_NAME" \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DCMAKE_PREFIX_PATH="$OUTPUT_DIR" \
            -DTESTING=OFF \
            -DEXAMPLES=OFF \
            $cmake_ext_args;
        touch ".configured";
    fi
	loginfo "${CPP_LIBP2P_TARBALL} has been configured."

}

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$CPP_LIBP2P_NAME" ]; then
		cp -r "$BUILD_TARBALL_DIR/$CPP_LIBP2P_NAME" "$BUILD_DIR/$CPP_LIBP2P_NAME";
	fi
	loginfo "${CPP_LIBP2P_TARBALL//\//-} has been unpacked."
	cd "$BUILD_DIR/$CPP_LIBP2P_NAME";

    config_tarball;

	if [ ! -e ".installed" ]; then
        make -j$MAX_JOBS install;

        RANLIB=ranlib;
        if [[ "$CFG_TARGET_PLATFORM" == "Android" ]]; then
            RANLIB=${ANDROID_TOOLCHAIN}-ranlib;
        fi

        local libarray=$(find . -name *.a);
        for lib in ${libarray}; do
            cp -v "$lib" "$OUTPUT_DIR/lib";
            ${RANLIB} "$OUTPUT_DIR/lib/$(basename $lib)";
        done

        touch ".installed";
    fi
	loginfo "$CURL_TARBALL has been installed."
}

main_run()
{
	# build gsl first.
	"$SCRIPT_DIR/build-gsl.sh" $@;

	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$CPP_LIBP2P_BASE_URL/$CPP_LIBP2P_TARBALL";
    local tarball_version="$CPP_LIBP2P_VERSION";
    local tarball_path="$BUILD_TARBALL_DIR/$CPP_LIBP2P_NAME";
	clone_from_github "$tarball_url" "$tarball_path" "$tarball_version";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
