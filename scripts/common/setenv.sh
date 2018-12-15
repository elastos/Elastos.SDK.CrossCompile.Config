#!/bin/bash

set -o errexit
set -o nounset

CURRENT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);

case "$CFG_TARGET_PLATFORM" in
	(Android)
		source "$CURRENT_DIR/setenv-android.sh";
		;;
	(iOS)
		source "$CURRENT_DIR/setenv-ios.sh";
		;;
	(*)
		source "$CURRENT_DIR/setenv-unixlike.sh";
		;;
esac
