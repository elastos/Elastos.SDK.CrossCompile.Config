#!/bin/bash

set -o errexit
set -o nounset

GETOPT_IGNORE_UNRECOGNIZED=${GETOPT_IGNORE_UNRECOGNIZED:=false};

getopt_parse_options()
{
	local getopt_cmd="getopt";
	if [ "$(uname -s)" == "Darwin" ]; then
        getopt_cmd="$(ls /usr/local/Cellar/gnu-getopt/*/bin/getopt)";
	fi

    local ret=";";
	type getopt_extfunc_options &>/dev/null && ret=$(getopt_extfunc_options);
	getopt_ext=([0]="${ret%;*}" [1]=${ret##*;});

	local args="--name getopt-script --options p:f:m:${getopt_ext[0]}ch \
                --longoptions prefix:,platform:,arch:,${getopt_ext[1]},clean,help";
	#echo "getopt args: $args";

	if [[ $GETOPT_IGNORE_UNRECOGNIZED  == true ]]; then
		local getopt_opts=$($getopt_cmd --quiet $args -- "$@");
		eval set -- "$getopt_opts";
	else
		local getopt_opts=$($getopt_cmd $args  -- "$@" 2>&1);
		if [[ "$getopt_opts" =~ "getopt:" ]]; then
			echo "Failed: $getopt_opts" >&2;
			exit 1;
		fi
		eval set -- "$getopt_opts";
	fi
	while true; do
		case "$1" in
			(-p | --prefix)
				CFG_TARGET_BUILDROOT=$2;
				shift 2;
				;;
			(-f | --platform)
				CFG_TARGET_PLATFORM=$2;
				shift 2;
				;;
			(-m | --arch)
				CFG_TARGET_ABI=$2;
				shift 2;
				;;
			(-c | --clean)
				getopt_clean;
				exit 0;
				;;
			(-h | --help)
				getopt_print_usage;
				exit 0;
				;;
			(- | --)
				shift;
				break;
				;;
			(*)
				type getopt_extfunc_processor &>/dev/null && getopt_extfunc_processor "$1" "$2";
				if ((  $getopt_extfunc_processor_ret > 0 )); then
					shift $getopt_extfunc_processor_ret;
				else
					echo "Internal error! $1 $2";
					exit 1;
				fi
				;;
		esac
	done

	if [[ -z "$CFG_TARGET_ABI" ]]; then
		case "$CFG_TARGET_PLATFORM" in
			(Android)
				CFG_TARGET_ABI="armeabi-v7a";
				;;
			(iOS)
				CFG_TARGET_ABI="arm64";
				;;
			(*)
				CFG_TARGET_ABI="x86_64";
				;;
		esac
	fi

	getopt_print_input_log;
}

getopt_clean()
{
    local tarball_name=$(basename "$BUILD_TARBALL_DIR");

    echo "cleaning $BUILD_BASE_DIR";
    cd "$BUILD_BASE_DIR" && ls |grep -v "$tarball_name" |xargs rm -r;
}

getopt_print_usage()
{
	echo '
NAME
       getopt-script

SYNOPSIS
       getopt-script [options]

DESCRIPTION
       getopt script.

OPTIONS
       -p, --prefix=PREFIX
                 Optional. Install architecture-independent files in PREFIX

       -f, --platform=(Android | iOS)
                 Optional. target platform. If unspecified, use [`uname -m`] as default.

       -m, --arch=(ARCH)
                 Optional. target platform abi.
                 For native compile, valid value is (x86_64), use [x86_64] as default.
                 For Android, valid value is (armeabi-v7a, arm64-v8a, x86_64), use [armeabi-v7a] as default.
                 For iOS, valid value is (arm64, x86_64), use [arm64] as default.';

	type getopt_extfunc_usage &>/dev/null && getopt_extfunc_usage;
	echo '
       -c, --clean
                 Optional. clean build files.

       -h, --help
                 Optional. Print help infomation and exit successfully.';
}

getopt_print_input_log()
{
	logtrace "*********************************************************";
	logtrace " Input infomation";
	logtrace "    build root      : $CFG_TARGET_BUILDROOT";
	logtrace "    platform        : $CFG_TARGET_PLATFORM";
	logtrace "    abi             : $CFG_TARGET_ABI";
	logtrace "    debug verbose   : $DEBUG_VERBOSE";
	logtrace "*********************************************************";
}

CURRENT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);
SCRIPT_DIR=$(dirname "$CURRENT_DIR");
source "$SCRIPT_DIR/common/base.sh";

CFG_TARGET_BUILDROOT=;
CFG_TARGET_PLATFORM=$(uname -s);
CFG_TARGET_ABI=;

