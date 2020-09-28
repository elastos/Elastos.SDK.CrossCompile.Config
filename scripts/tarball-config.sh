#!/bin/bash
set -o errexit
set -o nounset

OPENSSL_BASE_URL="https://www.openssl.org/source";
OPENSSL_VERSION="1.1.1a";
OPENSSL_NAME="openssl-$OPENSSL_VERSION";
OPENSSL_TARBALL="$OPENSSL_NAME.tar.gz";

CURL_BASE_URL="https://curl.haxx.se/download";
CURL_VERSION="7.63.0";
CURL_NAME="curl-$CURL_VERSION";
CURL_TARBALL="$CURL_NAME.tar.gz";

SQLITE_BASE_URL="https://www.sqlite.org/2018";
SQLITE_VERSION="autoconf-3250300";
SQLITE_NAME="sqlite-$SQLITE_VERSION";
SQLITE_TARBALL="$SQLITE_NAME.tar.gz";

ELASTOS_SDK_KEYPAIR_C_BASE_URL="https://github.com/elastos";
ELASTOS_SDK_KEYPAIR_C_VERSION="master";
ELASTOS_SDK_KEYPAIR_C_NAME="Elastos.SDK.Keypair.C-$ELASTOS_SDK_KEYPAIR_C_VERSION";
ELASTOS_SDK_KEYPAIR_C_TARBALL="Elastos.SDK.Keypair.C.git";

ELASTOS_NET_CARRIER_NATIVE_SDK_BASE_URL="https://github.com/elastos";
ELASTOS_NET_CARRIER_NATIVE_SDK_VERSION="release-v5.4.1";
ELASTOS_NET_CARRIER_NATIVE_SDK_NAME="Elastos.NET.Carrier.Native.SDK-$ELASTOS_NET_CARRIER_NATIVE_SDK_VERSION";
ELASTOS_NET_CARRIER_NATIVE_SDK_TARBALL="Elastos.NET.Carrier.Native.SDK.git";

JSON_VERSION="v3.7.0";
JSON_URL="https://github.com/nlohmann/json/releases/download/$JSON_VERSION/include.zip";
JSON_NAME="json-$JSON_VERSION";
JSON_TARBALL="$JSON_NAME.zip";

ELASTOS_SDK_ELEPHANTWALLET_CONTACT_BASE_URL="https://github.com/elastos";
ELASTOS_SDK_ELEPHANTWALLET_CONTACT_VERSION="master";
ELASTOS_SDK_ELEPHANTWALLET_CONTACT_NAME="Elastos.SDK.ElephantWallet.Contact-$ELASTOS_SDK_ELEPHANTWALLET_CONTACT_VERSION";
ELASTOS_SDK_ELEPHANTWALLET_CONTACT_TARBALL="Elastos.SDK.ElephantWallet.Contact.git";

APR_VERSION="1.7.0";
APR_URL="http://mirror.bit.edu.cn/apache/apr/apr-$APR_VERSION.tar.gz";
APR_NAME="apr-$APR_VERSION";
APR_TARBALL="$APR_NAME.tar.gz";

APRUTIL_VERSION="1.6.1";
APRUTIL_URL="http://mirror.bit.edu.cn/apache/apr/apr-util-$APRUTIL_VERSION.tar.gz";
APRUTIL_NAME="apr-util-$APRUTIL_VERSION";
APRUTIL_TARBALL="$APRUTIL_NAME.tar.gz";

MINIXML_VERSION="2.12";
MINIXML_URL="https://github.com/michaelrsweet/mxml/releases/download/v$MINIXML_VERSION/mxml-$MINIXML_VERSION.tar.gz";
MINIXML_NAME="minixml-$MINIXML_VERSION";
MINIXML_TARBALL="$MINIXML_NAME.tar.gz";

ALIOSS_VERSION="1.7.0";
ALIOSS_URL="https://github.com/aliyun/aliyun-oss-cpp-sdk/archive/$ALIOSS_VERSION.tar.gz";
ALIOSS_NAME="aliyun-oss-cpp-sdk-$ALIOSS_VERSION";
ALIOSS_TARBALL="$ALIOSS_NAME.tar.gz";

PERSONALSTORAGE_SDK_OSS_BASE_URL="https://github.com/elaphantapp";
PERSONALSTORAGE_SDK_OSS_VERSION="master";
PERSONALSTORAGE_SDK_OSS_NAME="PersonalStorage.SDK.OSS-$PERSONALSTORAGE_SDK_OSS_VERSION";
PERSONALSTORAGE_SDK_OSS_TARBALL="PersonalStorage.SDK.OSS.git";

FILECOIN_FFI_BASE_URL="https://github.com/filecoin-project";
FILECOIN_FFI_VERSION="828a124ce84755e6";
FILECOIN_FFI_NAME="filecoin-ffi-$FILECOIN_FFI_VERSION";
FILECOIN_FFI_TARBALL="filecoin-ffi.git";

FILECOIN_SIGNING_TOOLS_BASE_URL="https://github.com/Zondax";
FILECOIN_SIGNING_TOOLS_VERSION="v0.9.0";
FILECOIN_SIGNING_TOOLS_NAME="filecoin-signing-tools-$FILECOIN_SIGNING_TOOLS_VERSION";
FILECOIN_SIGNING_TOOLS_TARBALL="filecoin-signing-tools.git";

CPP_FILECOIN_BASE_URL="https://github.com/filecoin-project";
CPP_FILECOIN_VERSION="master";
CPP_FILECOIN_NAME="cpp-filecoin-$CPP_FILECOIN_VERSION";
CPP_FILECOIN_TARBALL="cpp-filecoin.git";

BOOST_VERSION="1.74.0";
BOOST_URL="https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${BOOST_VERSION//./_}.tar.bz2";
BOOST_NAME="boost-$BOOST_VERSION";
BOOST_TARBALL="$BOOST_NAME.tar.bz2";

CPP_LIBP2P_BASE_URL="https://github.com/libp2p";
CPP_LIBP2P_VERSION="v0.0.1-p0";
CPP_LIBP2P_NAME="cpp-libp2p-$CPP_LIBP2P_VERSION";
CPP_LIBP2P_TARBALL="cpp-libp2p.git";

GSL_VERSION="3.1.0";
GSL_URL="https://github.com/microsoft/GSL/archive/v${GSL_VERSION}.tar.gz";
GSL_NAME="gsl-$GSL_VERSION";
GSL_TARBALL="${GSL_NAME}.tar.gz";

SPDLOG_VERSION="1.8.0";
SPDLOG_URL="https://github.com/gabime/spdlog/archive/v${SPDLOG_VERSION}.tar.gz";
SPDLOG_NAME="spdlog-$SPDLOG_VERSION";
SPDLOG_TARBALL="${SPDLOG_NAME}.tar.gz";

CPPCODEC_VERSION="0.2";
CPPCODEC_URL="https://github.com/tplgy/cppcodec/archive/v${CPPCODEC_VERSION}.tar.gz";
CPPCODEC_NAME="cppcodec-$CPPCODEC_VERSION";
CPPCODEC_TARBALL="${CPPCODEC_NAME}.tar.gz";
