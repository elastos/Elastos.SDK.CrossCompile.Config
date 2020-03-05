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

ALIOSS_VERSION="3.9.1";
ALIOSS_URL="https://github.com/aliyun/aliyun-oss-c-sdk/archive/$ALIOSS_VERSION.tar.gz";
ALIOSS_NAME="aliyun-oss-c-sdk-$ALIOSS_VERSION";
ALIOSS_TARBALL="$ALIOSS_NAME.tar.gz";

