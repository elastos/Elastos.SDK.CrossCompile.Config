#!/bin/bash
set -o errexit
set -o nounset

CURL_BASE_URL="https://curl.haxx.se/download";
CURL_VERSION="7.62.0";
CURL_NAME="curl-$CURL_VERSION";
CURL_TARBALL="$CURL_NAME.tar.gz";

ELASTOS_ORG_WALLET_LIB_C_BASE_URL="https://github.com/elastos";
ELASTOS_ORG_WALLET_LIB_C_VERSION="master";
ELASTOS_ORG_WALLET_LIB_C_NAME="Elastos.ORG.Wallet.Lib.C-$ELASTOS_ORG_WALLET_LIB_C_VERSION";
ELASTOS_ORG_WALLET_LIB_C_TARBALL="Elastos.ORG.Wallet.Lib.C/archive/$ELASTOS_ORG_WALLET_LIB_C_VERSION.zip";

OPENSSL_BASE_URL="https://www.openssl.org/source";
OPENSSL_VERSION="1.1.1a";
OPENSSL_NAME="openssl-$OPENSSL_VERSION";
OPENSSL_TARBALL="$OPENSSL_NAME.tar.gz";

SQLITE_BASE_URL="https://www.sqlite.org/2018";
SQLITE_VERSION="autoconf-3250300";
SQLITE_NAME="sqlite-$SQLITE_VERSION";
SQLITE_TARBALL="$SQLITE_NAME.tar.gz";

