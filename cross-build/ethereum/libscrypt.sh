#!/bin/bash
# configures, cross-compiles and installs libscrypt (as part of webthree-helpers)
# @author: Anthony Cros

# ===========================================================================
set -e
SCRIPT_DIR=$(dirname $0) && ([ -n "$SETUP" ] && ${SETUP?}) || source ${SCRIPT_DIR?}/setup.sh $*
export_cross_compiler && sanity_check_cross_compiler
cd_clone ${INITIAL_DIR?}/../../webthree-helpers/utils/libscrypt ${WORK_DIR?}/libscrypt


# ===========================================================================
# configuration:
# Two hacks here.   One to add the "scaffolding" and another to add -fPIC
generic_hack \
  ${WORK_DIR?}/libscrypt/CMakeLists.txt \
  'BEGIN{printf("cmake_minimum_required(VERSION 3.0.0)\nset(ETH_CMAKE_DIR \"'${INITIAL_DIR?}/../../webthree-helpers/cmake'\" CACHE PATH \"The path to the cmake directory\")\nlist(APPEND CMAKE_MODULE_PATH ${ETH_CMAKE_DIR})\nset(CMAKE_C_FLAGS \"${CMAKE_C_FLAGS} -fPIC\")\n")}1'
cat ${WORK_DIR?}/libscrypt/CMakeLists.txt

# TODO - Only including boost here because of EthDependencies bug, not because we need it.
section_configuring libscrypt
set_cmake_paths "boost"
cmake \
   . \
  -G "Unix Makefiles" \
  -DCMAKE_VERBOSE_MAKEFILE=true \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE?}
return_code $?


# ===========================================================================
# cross-compile:

section_cross_compiling libscrypt
make -j 8
return_code $?


# ===========================================================================
# install:

section_installing libscrypt
make DESTDIR="${INSTALLS_DIR?}/libscrypt" install
return_code $?

# homogenization
ln -s ${INSTALLS_DIR?}/libscrypt/usr/local/lib     ${INSTALLS_DIR?}/libscrypt/lib
ln -s ${INSTALLS_DIR?}/libscrypt/usr/local/include ${INSTALLS_DIR?}/libscrypt/include

# ===========================================================================

section "done" libscrypt
tree ${INSTALLS_DIR?}/libscrypt


# ===========================================================================
