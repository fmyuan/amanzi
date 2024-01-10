#!/usr/bin/env bash

# Generic ATS build script that invokes Amanzi's bootstrap.sh 
# with options configured for an ATS build

# see INSTALL_ATS.md for more information

if [ ${ATS_BUILD_TYPE} == Debug ]
then
    dbg_option=--debug --debug-tpls
elif [ ${ATS_BUILD_TYPE} == RelWithDebInfo ]
then
    dbg_option=--relwithdebinfo
else
    dbg_option=--opt
fi

echo "Running Amanzi Boostrap with:"
echo "  AMANZI_SRC_DIR: ${AMANZI_SRC_DIR}"
echo "  AMANZI_BUILD_DIR: ${AMANZI_BUILD_DIR}"
echo "  AMANZI_INSTALL_DIR: ${AMANZI_DIR}"
echo "  AMANZI_TPLS_BUILD_DIR: ${AMANZI_TPLS_BUILD_DIR}"
echo "  AMANZI_TPLS_DIR: ${AMANZI_TPLS_DIR}"
echo " with build type: ${ATS_BUILD_TYPE}"
echo ""


echo "unset $PETSC_DIR: "
unset PETSC_DIR
unset PETSC_ARCH

${AMANZI_SRC_DIR}/bootstrap.sh \
   ${dbg_option} \
   --with-mpi=${OPENMPI_DIR} \
   --enable-shared \
   --enable-clm \
   --disable-structured  --enable-unstructured \
   --enable-mesh_mstk --disable-mesh_moab \
   --enable-hypre \
   --enable-silo \
   --enable-petsc \
   --disable-amanzi_physics \
   --enable-ats_physics \
   --enable-geochemistry --enable-alquimia --enable-pflotran --enable-crunchtope \
   --amanzi-install-prefix=${AMANZI_DIR} \
   --amanzi-build-dir=${AMANZI_BUILD_DIR} \
   --tpl-config-file=${AMANZI_TPLS_DIR}/share/cmake/amanzi-tpl-config.cmake \
   --tools-download-dir=${ATS_BASE}/Downloads/tools \
   --tools-build-dir=${AMANZI_TPLS_BUILD_DIR}/tools \
   --tools-install-prefix=${AMANZI_TPLS_DIR}/tools \
   --with-cmake=`which cmake` \
   --with-ctest=`which ctest` \
   --with-python=`which python3` \
   --branch_ats=${ATS_VERSION} \
   --parallel=6
   

# If TPLs have already been built, and you don't want to go 
# through that long process again, replace
#   --tpl-install-prefix=${AMANZI_TPLS_DIR} \
#   --tpl-build-dir=${AMANZI_TPLS_BUILD_DIR} \
#   --tpl-download-dir=${ATS_BASE}/Downloads/amanzi-tpls \
# with
#   --tpl-config-file=${AMANZI_TPLS_DIR}/share/cmake/amanzi-tpl-config.cmake \


