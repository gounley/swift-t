#!/usr/bin/env bash
set -e
set -x
THISDIR=`dirname $0`
source ${THISDIR}/exm-settings.sh

rm -rf ${TURBINE_INSTALL}
if [ -f Makefile ]; then
    # Disabled due to Turbine configure check
    #make clean
    :
fi

if (( SVN_UPDATE )); then
  svn update
fi

if (( RUN_AUTOTOOLS )); then
  rm -rf ./config.status ./autom4te.cache
  ./setup.sh
fi

EXTRA_ARGS=
if (( EXM_OPT_BUILD )); then
    EXTRA_ARGS+=" --enable-fast"
fi

if (( ENABLE_MPE )); then
    EXTRA_ARGS+=" --with-mpe"
fi

if (( EXM_STATIC_BUILD )); then
  EXTRA_ARGS+=" --disable-shared"
  # Have to enable turbine static consequentially
  TURBINE_STATIC=1
fi

if (( EXM_CRAY )); then
  if (( EXM_STATIC_BUILD )); then
    export CC=cc
  else
    export CC=gcc
  fi
  EXTRA_ARGS+=" --enable-custom-mpi"
fi

if (( ENABLE_PYTHON )); then
  EXTRA_ARGS+=" --enable-python"
  if [ ! -z "$WITH_PYTHON" ]; then
    EXTRA_ARGS+=" --with-python=${WITH_PYTHON}"
  fi
fi

if [ ! -z "$TCL_VERSION" ]; then
  EXTRA_ARGS+=" --with-tcl-version=$TCL_VERSION"
fi

if (( DISABLE_XPT )); then
    EXTRA_ARGS+=" --enable-checkpoint=no"
fi

if (( EXM_DEV )); then
  EXTRA_ARGS+=" --enable-dev"
fi

if (( TURBINE_STATIC )); then
  EXTRA_ARGS+=" --enable-static"
fi

if [ ! -z "$MPI_INSTALL" ]; then
  EXTRA_ARGS+=" --with-mpi=${MPI_INSTALL}"
fi

if (( CONFIGURE )); then
  ./configure --with-adlb=${LB_INSTALL} \
              ${CRAY_ARGS} \
              --with-tcl=${TCL_INSTALL} \
              --with-c-utils=${C_UTILS_INSTALL} \
              --prefix=${TURBINE_INSTALL} \
              ${EXTRA_ARGS}
#             --disable-log
fi

if (( MAKE_CLEAN )); then
  make clean
fi
make -j ${MAKE_PARALLELISM}
make install
#make test_results
