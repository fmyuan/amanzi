#
#  Amanzi
#   Multiphase process kernel
#

# Amanzi module, include files found in AMANZI_MODULE_PATH
include(PrintVariable)
include(TestManager)

#
# Define a project name
# After this command the following varaibles are defined
#   MULTIPHASE_SOURCE_DIR
#   MULTIPHASE_BINARY_DIR
# Other projects (subdirectories) can reference this directory
# through these variables.
project(MULTIPHASE)

# External (TPL) include directories
include_directories(${Teuchos_INCLUDE_DIRS})
include_directories(${Epetra_INCLUDE_DIRS})
include_directories(${HDF5_C_INCLUDE_DIR})
include_directories(${ASCEMIO_INCLUDE_DIR})

# Amanzi include directories
include_directories(${ATK_SOURCE_DIR})
include_directories(${DBG_SOURCE_DIR})
include_directories(${DATA_STRUCTURES_SOURCE_DIR})
include_directories(${DBC_SOURCE_DIR})
include_directories(${EOS_SOURCE_DIR})
include_directories(${ENERGY_SOURCE_DIR})
include_directories(${GEOMETRY_SOURCE_DIR})
include_directories(${FUNCS_SOURCE_DIR})
include_directories(${MESH_SOURCE_DIR})
include_directories(${MESH_DATA_SOURCE_DIR})
include_directories(${MESH_EXTRACTED_SOURCE_DIR})
include_directories(${MFUNCS_SOURCE_DIR})
include_directories(${MPC_SOURCE_DIR})
include_directories(${MULTIPHASE_SOURCE_DIR})
include_directories(${PKS_SOURCE_DIR})
include_directories(${OPERATORS_SOURCE_DIR})
include_directories(${OUTPUT_SOURCE_DIR})
include_directories(${SOLVERS_SOURCE_DIR})
include_directories(${STATE_SOURCE_DIR})
include_directories(${TIME_INTEGRATION_SOURCE_DIR})
include_directories(${WHETSTONE_SOURCE_DIR})

#
# Library: multiphase 
#
set(multiphase_src_files Multiphase_PK.cc Multiphase_TI.cc
                         MultiphaseBoundaryFunction.cc
                         Multiphase_Utils.cc Multiphase_BCs.cc
                         NCP_F.cc NCP_HenryLaw.cc NCP_MoleFractions.cc NCP_MolarDensities.cc
                         SaturationEvaluator.cc
                         TotalWaterStorage.cc 
                         TotalComponentStorage.cc TotalComponentStorage_Tcc.cc
                         TotalComponentStorage_Jaffre.cc
                         VaporPressureEvaluator.cc
                         WRMmp_Simple.cc WRMmp_vanGenuchten.cc WRMmp_BrooksCorey.cc WRMmp_Corey.cc
                         MoleFractionLiquid.cc TccLiquid.cc TccGas.cc PressureGasEvaluator.cc
                         RelPermEvaluator.cc ProductEvaluator.cc
                         MassDensityGas.cc
                         FlattenedTreeOperator.cc)

add_amanzi_library(multiphase 
                   SOURCE ${multiphase_src_files}
                   LINK_LIBS pks operators state functions 
                             mesh_functions time_integration data_structures
                             eos energy)

#
# Install Targets
#
set(multiphase_inc_files 
  MassDensityGas.hh
  Multiphase_PK.hh
  Multiphase_Utils.hh
  MultiphaseBoundaryFunction.hh
  MultiphaseEvaluator.hh
  ModelMeshPartition.hh
  MoleFractionLiquid.hh TccLiquid.hh TccGas.hh
  NCP_F.hh NCP_HenryLaw.hh NCP_MoleFractions.hh NCP_MolarDensities.hh
  PressureGasEvaluator.hh
  RelPermEvaluator.hh ProductEvaluator.hh
  SaturationEvaluator.hh
  VaporPressureEvaluator.hh
  TotalWaterStorage.hh
  TotalComponentStorage.hh TotalComponentStorage_Tcc.hh
  WRMmp.hh
  WRMmp_Corey.hh
  WRMmp_Simple.hh
  WRMmp_vanGenuchten.hh
  WRMmp_BrooksCorey.hh)

add_install_include_file(${multiphase_inc_files})

if (BUILD_TESTS) 
  include_directories(${MESH_FACTORY_SOURCE_DIR})

  # Add UnitTest includes
  include_directories(${UnitTest_INCLUDE_DIRS})

  # Add MPC include directory. Need to remove this required path. -- lpritch
  include_directories(${MULTIPHASE_SOURCE_DIR})

  # Copy test subdirectory for out of source builds
  if (NOT (MULTIPHASE_SOURCE_DIR STREQUAL MULTIPHASE_BINARY_DIR))
    file(GLOB DataFiles "${MULTIPHASE_SOURCE_DIR}/test/*.xml"
                        "${MULTIPHASE_SOURCE_DIR}/test/*.exo")
    file(COPY ${DataFiles} DESTINATION ${MULTIPHASE_BINARY_DIR}/test/)
  endif()

  set(amanzi_libs multiphase state mesh_factory whetstone operators 
                  geometry mesh_functions functions eos pks)

  # Unit tests: Jaffre 
  add_amanzi_test(multiphase_jaffre multiphase_jaffre
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_jaffre.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

  add_amanzi_test(multiphase_jaffre_nlfv multiphase_jaffre_nlfv
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_jaffre_nlfv.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

  # Jaffre model with fractures
  add_amanzi_test(multiphase_jaffre_fractures multiphase_jaffre_fractures
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_jaffre_fractures.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

  # Unit tests: Pl-Sl-Xg
  add_amanzi_test(multiphase_model1a multiphase_model1a
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_model1a.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

  add_amanzi_test(multiphase_model1b multiphase_model1b
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_model1b.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

  add_amanzi_test(multiphase_model1c multiphase_model1c
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_model1c.cc
                  LINK_LIBS ${amanzi_libs} energy ${UnitTest_LIBRARIES})

  add_amanzi_test(multiphase_jacobian1a multiphase_jacobian1a
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_jacobian1a.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

  # Unit tests: Pl-Sl-Cg
  add_amanzi_test(multiphase_model2a multiphase_model2a
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_model2a.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

  # Smiles
  add_amanzi_test(multiphase_smiles multiphase_smiles
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_smiles.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

  # Misc. (external source term implementation)  
  add_amanzi_test(multiphase_source multiphase_source
                  KIND      int
                  SOURCE    test/Main.cc test/multiphase_source.cc
                  LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})  
  

endif()

