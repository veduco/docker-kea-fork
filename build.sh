#!/bin/bash
set -e
# This is a helper script used for simplifying the building of all the different
# images locally. This is called from the Makefile, but it should not be any
# issues calling this directly either.
# Example:
#   ./build.sh -b "dhcp4" -v "2.1.7" -a
#
# Input arguments:
# -b|--binary     : Kea executable (valid strings: "dhcp4", "dhcp6")
# -v|--version    : Kea version (e.g. "2.1.7")
# -a|--alpine     : Alpine build (omit for Debian build or provide for Alpine build)

VALID_ARGS=$(getopt -o b:v:a --long binary:,version:,alpine -- "$@")
[ $? -ne 0 ] && exit 1

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "${1}" in
    -b|--binary)
      KEA_BINARY="${2}"
      shift 2
      ;;
    -v|--version)
      KEA_VERSION="${2}"
      shift 2
      ;;
    -a|--alpine)
      APPEND="-alpine"
      shift;
      ;;
    --) shift;
      break
      ;;
  esac
done

# We must have at least the binary we're building and the version to build
[ -z "${KEA_BINARY}" ] && exit 1 || true
[ -z "${KEA_VERSION}" ] && exit 1 || true

# Feed all the relevant information to the `docker build` command, and tag it
# with something appropriate.
docker build -f "Dockerfile${APPEND}" \
    -t "kea-${KEA_BINARY}:local${APPEND}" \
    --build-arg KEA_VERSION=${KEA_VERSION} \
    --target "${KEA_BINARY}" \
    --pull \
    ./
