#!/bin/bash

set -o errexit
set -o nounset

getopt_extfunc_usage()
{
	echo "
       -s, --enable-static
                 Optional. build static library. If unspecified, use [shared] as default.

       -d, --without-depends
                 Optional. build without dependencies. If unspecified, use [false] as default.

       -t, --with-test
                 Optional. build test case.

       -i, --ignore-build
                 Optional. only config project but don't build.

       -b  --force-build
                 Optional. force build project.

       -g  --debug
                 Optional. build  project as debug.";

    type custom_getopt_usage &>/dev/null && custom_getopt_usage;
}
getopt_extfunc_options()
{
    local ret=";";
	type custom_getopt_options &>/dev/null && ret=$(custom_getopt_options);
	custom_getopt=([0]="${ret%;*}" [1]=${ret##*;});

	echo "sdtibg${custom_getopt[0]};enable-static,without-depends,with-test,ignore-build,force-build,debug,${custom_getopt[1]}";
}
getopt_extfunc_processor()
{
	getopt_extfunc_processor_ret=-1;
	case "$1" in
		(-s | --enable-static)
			CFG_ENABLE_SHARED_LIB=OFF;
			getopt_extfunc_processor_ret=1;
			;;
		(-d | --without-depends)
			CFG_WITHOUT_DEPENDS=true;
			getopt_extfunc_processor_ret=1;
			;;
		(-t | --with-test)
			CFG_WITH_TEST=true;
			getopt_extfunc_processor_ret=1;
			;;
		(-i | --ignore-build)
			CFG_IGNORE_BUILD=true;
			getopt_extfunc_processor_ret=1;
			;;
		(-b | --force-build)
			CFG_FORCE_BUILD=true;
			getopt_extfunc_processor_ret=1;
			;;
		(-g | --debug)
			CFG_DEBUG=true;
			getopt_extfunc_processor_ret=1;
			;;
        (*)
            custom_getopt_processor_ret=-1;
            type custom_getopt_processor &>/dev/null && custom_getopt_processor "$1" "$2";
            getopt_extfunc_processor_ret=$custom_getopt_processor_ret;
            ;;
	esac
}

build_project()
{
	mkdir -p "$PROJECT_BUILDDIR" && cd "$PROJECT_BUILDDIR";
	loginfo "change directory to $PROJECT_BUILDDIR";
	cd "$PROJECT_BUILDDIR";

	local cmake_ext_args="$CFG_CMAKE_EXTARGS";
	if [[ $CFG_WITH_TEST == true ]]; then
		cmake_ext_args+=" -DCFG_WITH_TEST=ON";
	fi
	if [[ $CFG_TARGET_PLATFORM == "Android" ]]; then
		cmake_ext_args+=" -DCFG_ANDROID_TOOLCHAIN_PATH=$CFG_ANDROID_TOOLCHAIN_PATH";
        cmake_ext_args+=" -DCFG_ANDROID_SDK=$CFG_ANDROID_SDK";
	fi
	if [[ $CFG_DEBUG == true ]]; then
		cmake_ext_args+=" -DCMAKE_BUILD_TYPE=Debug";
	fi
	echo $cmake_ext_args;

	if [ ! -e ".configured" ]; then
        cmake "$CFG_CMAKELIST_DIR" \
            -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
            -DCMAKE_PREFIX_PATH="$OUTPUT_DIR" \
            -DBUILD_SHARED_LIBS=$CFG_ENABLE_SHARED_LIB \
            -DCFG_TARGET_PLATFORM=$CFG_TARGET_PLATFORM \
            -DCFG_TARGET_ABI=$CFG_TARGET_ABI \
            $cmake_ext_args;
        touch ".configured";
    fi
	loginfo "$PROJECT_NAME has been configured."

	if [[ $CFG_IGNORE_BUILD == false ]]; then
	    if [[ $CFG_FORCE_BUILD == true ]]; then
            rm -f ".installed";
        fi

        if [ ! -e ".installed" ]; then
            #make -j$MAX_JOBS VERBOSE=1 && make install;
            make -j$MAX_JOBS && make install;
            touch ".installed";
        fi
        loginfo "$PROJECT_NAME has been installed."
	fi
}

main_run()
{
	loginfo "parsing options";
	export GETOPT_IGNORE_UNRECOGNIZED=false;
	getopt_parse_options $@;

	# build dependencies first.
	if [[ $CFG_WITHOUT_DEPENDS == false ]]; then
		export GETOPT_IGNORE_UNRECOGNIZED=true;
		if [ "$(type -t build_extfunc_depends)" == "function" ]; then
            local params=${@//--force-build/}

			build_extfunc_depends $params;
		else
			loginfo "Function build_extfunc_depends() is not defined.";
		fi
		export GETOPT_IGNORE_UNRECOGNIZED=false;
	fi

	case "$CFG_TARGET_PLATFORM" in
		(Android)
			source "$SCRIPT_DIR/common/setenv-android.sh";
			;;
		(iOS)
			source "$SCRIPT_DIR/common/setenv-ios.sh";
			;;
		(*)
			source "$SCRIPT_DIR/common/setenv-unixlike.sh";
			;;
	esac

	PROJECT_BUILDDIR="$BUILD_DIR/$PROJECT_NAME";

	build_project $@;

	loginfo "DONE !!!";
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);
source "$SCRIPT_DIR/common/getopt.sh";

CFG_ENABLE_SHARED_LIB=ON;
CFG_WITHOUT_DEPENDS=false;
CFG_WITH_TEST=false;
CFG_IGNORE_BUILD=false;
CFG_FORCE_BUILD=false;
CFG_DEBUG=false;
${CFG_CMAKE_EXTARGS:=}
PROJECT_NAME=${CFG_PROJECT_NAME:="Unknown"}

main_run $@;
