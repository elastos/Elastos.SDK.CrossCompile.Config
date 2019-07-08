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
ELASTOS_NET_CARRIER_NATIVE_SDK_VERSION="release-v5.3.3";
ELASTOS_NET_CARRIER_NATIVE_SDK_NAME="Elastos.NET.Carrier.Native.SDK-$ELASTOS_NET_CARRIER_NATIVE_SDK_VERSION";
ELASTOS_NET_CARRIER_NATIVE_SDK_TARBALL="Elastos.NET.Carrier.Native.SDK.git";

JSON_VERSION="v3.6.1";
JSON_URL="https://github.com/nlohmann/json/releases/download/$JSON_VERSION/include.zip";
JSON_NAME="json-$JSON_VERSION";
JSON_TARBALL="$JSON_NAME.zip";
