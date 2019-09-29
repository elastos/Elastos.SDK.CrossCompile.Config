#!/bin/bash

CURRENT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);
source "$CURRENT_DIR/base.sh";

SYSTEM_NAME="Android"
SYSTEM_ABIS=(armeabi-v7a arm64-v8a x86_64)
BUILD_DIR="$BUILD_BASE_DIR/$SYSTEM_NAME/$CFG_TARGET_ABI";
OUTPUT_DIR="$BUILD_ROOT_DIR/$SYSTEM_NAME/$CFG_TARGET_ABI";

if [ -z "$ANDROID_NDK_HOME" ]; then
	echo "Please set your ANDROID_NDK_HOME environment variable first"
	exit 1
fi

if [[ "$ANDROID_NDK_HOME" == .* ]]; then
	echo "Please set your ANDROID_NDK_HOME to an absolute path"
	exit 1
fi

SDK_LIST=(16 21 21)
ARCH_LIST=(arm arm64 x86_64)
TOOLCHAIN_LIST=(arm-linux-androideabi aarch64-linux-android x86_64-linux-android)
for idx in "${!SYSTEM_ABIS[@]}"; do
	if [[ "${SYSTEM_ABIS[$idx]}" = "${CFG_TARGET_ABI}" ]]; then
		LIST_IDX=${idx}
		break;
	fi
done

#Configure toolchain
CFG_ANDROID_SDK=${SDK_LIST[$LIST_IDX]};
ANDROID_TOOLCHAIN=${TOOLCHAIN_LIST[$LIST_IDX]};
CFG_ANDROID_TOOLCHAIN_PATH="$BUILD_DIR/toolchain";
if [ ! -e "$BUILD_DIR/.toolchain" ]; then
	rm -rf "$CFG_ANDROID_TOOLCHAIN_PATH"
	$ANDROID_NDK_HOME/build/tools/make-standalone-toolchain.sh \
		--arch=${ARCH_LIST[$LIST_IDX]} \
		--platform=android-${CFG_ANDROID_SDK} \
		--toolchain=${ANDROID_TOOLCHAIN}-clang \
		--stl=libc++ --install-dir="$CFG_ANDROID_TOOLCHAIN_PATH";

	touch "$BUILD_DIR/.toolchain";
fi

export CFG_ANDROID_TOOLCHAIN_PATH
export PATH="$CFG_ANDROID_TOOLCHAIN_PATH/bin:$PATH"
export CC=clang
export CXX=clang++
#export CFLAGS="-D__ANDROID_API__=$CFG_ANDROID_SDK -fPIC -nostdlib"
#export CXXFLAGS="-D__ANDROID_API__=$CFG_ANDROID_SDK -fPIC -nostdlib"
export CFLAGS="-D__ANDROID_API__=$CFG_ANDROID_SDK -fPIC"
export CXXFLAGS="-D__ANDROID_API__=$CFG_ANDROID_SDK -fPIC"

echo "===================================";
echo "ARCH:       ${ARCH_LIST[$LIST_IDX]}";
echo "SDK:        ${CFG_ANDROID_SDK}";
echo "TOOLCHAIN:  ${ANDROID_TOOLCHAIN}";
echo "===================================";
