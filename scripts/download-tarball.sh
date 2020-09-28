#!/bin/bash

set -o errexit
set -o nounset

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);
source "$SCRIPT_DIR/common/base.sh";

clone_from_github()
{
    local tarball_url="$1";
    local tarball_path="$2";
    local tarball_version="$3";
    local tarball_dir="$(basename $tarball_path)";
    local tarball_name="$(basename $tarball_path)";
    local tarball_downloaded="$(dirname $tarball_path)/.$tarball_name";

    if [ ! -e "$tarball_downloaded" ]; then
        rm -rf "$tarball_path";
        local cmd="git clone --depth=1 --branch=$tarball_version '$tarball_url' '$tarball_path'";
        echo "$cmd";
        eval $cmd;

        echo "git submodule update";
        cd "$tarball_path";
        git submodule update --init --recursive

        echo "$tarball_url" > "$tarball_downloaded";
        echo "$cmd" >> "$tarball_downloaded";
    fi

    loginfo "$tarball_name has been downloaded on commit $tarball_version."
}

download_tarball()
{
    local tarball_url="$1";
    local tarball_path="$2";
    local tarball_dir="$(basename $tarball_path)";
    local tarball_name="$(basename $tarball_path)";
    local tarball_downloaded="$(dirname $tarball_path)/.$tarball_name";

    if [ ! -e "$tarball_downloaded" ]; then
        rm -rf "$tarball_path";
        local cmd="curl --fail --location '$tarball_url' --output '$tarball_path'";
        echo "$cmd";
        eval $cmd;

        echo "$tarball_url" > "$tarball_downloaded";
        echo "$cmd" >> "$tarball_downloaded";
    fi

    loginfo "$tarball_name has been downloaded."
}
