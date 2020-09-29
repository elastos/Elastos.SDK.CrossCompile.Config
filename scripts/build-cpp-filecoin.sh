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

        $SED_CMD 's|include(filecoin-ffi.cmake)|#&|'                         deps/CMakeLists.txt;
        $SED_CMD 's|include(libsecp256k1.cmake)|#&|'                         deps/CMakeLists.txt;

        $SED_CMD 's|.*|#&|'                                                  core/CMakeLists.txt;
        echo "" >>                                                           core/CMakeLists.txt;
        echo "include_directories(${OUTPUT_DIR}/include)" >>                 core/CMakeLists.txt;
        echo "add_subdirectory(codec/cbor)" >>                               core/CMakeLists.txt;
        echo "add_subdirectory(common)" >>                                   core/CMakeLists.txt;
        echo "add_subdirectory(crypto/blake2)" >>                            core/CMakeLists.txt;
        echo "add_subdirectory(primitives/address)" >>                       core/CMakeLists.txt;
        echo "add_subdirectory(primitives/cid)" >>                           core/CMakeLists.txt;
        echo "add_subdirectory(vm/message)" >>                               core/CMakeLists.txt;

        $SED_CMD 's|.*|#&|'                                                  core/common/CMakeLists.txt;
        echo "" >>                                                           core/common/CMakeLists.txt;
        echo "add_library(blob" >>                                           core/common/CMakeLists.txt;
        echo "blob.cpp" >>                                                   core/common/CMakeLists.txt;
        echo "blob.hpp" >>                                                   core/common/CMakeLists.txt;
        echo ")" >>                                                          core/common/CMakeLists.txt;
        echo "add_library(buffer" >>                                         core/common/CMakeLists.txt;
        echo "buffer.cpp" >>                                                 core/common/CMakeLists.txt;
        echo ")" >>                                                          core/common/CMakeLists.txt;
        echo "add_library(hexutil" >>                                        core/common/CMakeLists.txt;
        echo "hexutil.cpp" >>                                                core/common/CMakeLists.txt;
        echo ")" >>                                                          core/common/CMakeLists.txt;
        $SED_CMD 's|gsl/span|gsl/span_ext|'                                  core/common/buffer.hpp;
        $SED_CMD 's|gsl/span|gsl/span_ext|'                                  core/common/span.hpp;

        $SED_CMD 's|.*|#&|'                                                  core/primitives/address/CMakeLists.txt;
        echo "" >>                                                           core/primitives/address/CMakeLists.txt;
        echo "add_library(address" >>                                        core/primitives/address/CMakeLists.txt;
        echo "address.cpp" >>                                                core/primitives/address/CMakeLists.txt;
        echo "address_codec.cpp" >>                                          core/primitives/address/CMakeLists.txt;
        echo ")" >>                                                          core/primitives/address/CMakeLists.txt;
        $SED_CMD 's|.*Address::makeSecp256k1|static Address makeSecp256k1|'  core/primitives/address/address.cpp;
        $SED_CMD 's|.*Address::makeActorExec|static Address makeActorExec|'  core/primitives/address/address.cpp;
        $SED_CMD 's|.*Address::verifySyntax\(.*\) const {|static bool verifySyntax\1 {Payload data;|' \
                                                                             core/primitives/address/address.cpp;

        $SED_CMD 's|.*|#&|'                                                  core/primitives/cid/CMakeLists.txt;
        echo "" >>                                                           core/primitives/cid/CMakeLists.txt;
        echo "add_library(cid" >>                                            core/primitives/cid/CMakeLists.txt;
        echo "cid.cpp" >>                                                    core/primitives/cid/CMakeLists.txt;
        echo ")" >>                                                          core/primitives/cid/CMakeLists.txt;
        $SED_CMD 's|ptrdiff_t|uint32_t|'                                     core/primitives/cid/cid.cpp;

        $SED_CMD 's|.*|#&|'                                                  core/vm/message/CMakeLists.txt;
        echo "" >>                                                           core/vm/message/CMakeLists.txt;
        echo "add_library(message" >>                                        core/vm/message/CMakeLists.txt;
        echo "message.cpp" >>                                                core/vm/message/CMakeLists.txt;
        echo "message_util.cpp" >>                                           core/vm/message/CMakeLists.txt;
        echo ")" >>                                                          core/vm/message/CMakeLists.txt;
        $SED_CMD 's|.*size(const|// &|'                                      core/vm/message/message_util.hpp;
        $SED_CMD 's|.*size(const|static &|'                                  core/vm/message/message_util.cpp;

        local content=$(cat core/codec/cbor/cbor_encode_stream.hpp);
        local content_head=${content%%namespace fc::codec::cbor*};
        local content_tail=${content#*namespace fc::codec::cbor};
        echo "$content_head" >                                               core/codec/cbor/cbor_encode_stream.hpp;
        echo "#include <gsl/span_ext>" >>                                    core/codec/cbor/cbor_encode_stream.hpp;
        echo "namespace fc::codec::cbor" >>                                  core/codec/cbor/cbor_encode_stream.hpp;
        echo "$content_tail" >>                                              core/codec/cbor/cbor_encode_stream.hpp;

        local content=$(cat core/codec/cbor/cbor_decode_stream.hpp);
        local content_head=${content%%namespace fc::codec::cbor*};
        local content_tail=${content#*namespace fc::codec::cbor};
        echo "$content_head" >                                               core/codec/cbor/cbor_decode_stream.hpp;
        echo "#include <gsl/span_ext>" >>                                    core/codec/cbor/cbor_decode_stream.hpp;
        echo "namespace fc::codec::cbor" >>                                  core/codec/cbor/cbor_decode_stream.hpp;
        echo "$content_tail" >>                                              core/codec/cbor/cbor_decode_stream.hpp;


        cmake "$BUILD_DIR/$CPP_FILECOIN_NAME" \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DCMAKE_PREFIX_PATH="$OUTPUT_DIR" \
            -DTESTING=OFF;
        touch ".configured";
    fi
	loginfo "${CPP_FILECOIN_TARBALL} has been configured."

}

build_tarball()
{
	mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR";
	loginfo "change directory to $BUILD_DIR";

	if [ ! -e "$BUILD_DIR/$CPP_FILECOIN_NAME" ]; then
		cp -r "$BUILD_TARBALL_DIR/$CPP_FILECOIN_NAME" "$BUILD_DIR/$CPP_FILECOIN_NAME";
	fi
	loginfo "${CPP_FILECOIN_TARBALL} has been unpacked."
	cd "$BUILD_DIR/$CPP_FILECOIN_NAME";

    config_tarball;

    pwd
    if [ ! -e ".installed" ]; then
        make -j$MAX_JOBS;

        mkdir -p "$OUTPUT_DIR"/{lib,include/cpp-filecoin}/;
        rsync -Rv $(find core -name "*.hpp") "$OUTPUT_DIR/include/cpp-filecoin";
        local libarray=$(find . -name *.a);
        for lib in ${libarray}; do
            cp -v "$lib" "$OUTPUT_DIR/lib";
            ${ANDROID_TOOLCHAIN}-ranlib "$OUTPUT_DIR/lib/$(basename $lib)";
        done

        mkdir -p "$OUTPUT_DIR/include/cpp-filecoin/tinycbor";
        cp -v $(find deps/tinycbor -name "*.h") "$OUTPUT_DIR/include/cpp-filecoin/tinycbor";

        touch ".installed";
    fi
    loginfo "$CPP_FILECOIN_TARBALL has been installed."

}

main_run()
{
	# build filecoin-ffi, boost first.
	"$SCRIPT_DIR/build-filecoin-ffi.sh" $@;
    "$SCRIPT_DIR/build-boost.sh" $@;
    "$SCRIPT_DIR/build-cpp-libp2p.sh" $@;
    "$SCRIPT_DIR/build-spdlog.sh" $@;
    "$SCRIPT_DIR/build-cppcodec.sh" $@;


	loginfo "parsing options";
	getopt_parse_options $@;

	source "$SCRIPT_DIR/common/setenv.sh";

	source "$SCRIPT_DIR/tarball-config.sh";
    source "$SCRIPT_DIR/download-tarball.sh";
    local tarball_url="$CPP_FILECOIN_BASE_URL/$CPP_FILECOIN_TARBALL";
    local tarball_version="$CPP_FILECOIN_VERSION";
    local tarball_path="$BUILD_TARBALL_DIR/$CPP_FILECOIN_NAME";
	clone_from_github "$tarball_url" "$tarball_path" "$tarball_version";

	build_tarball $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

source "$SCRIPT_DIR/common/getopt.sh";

main_run $@;
