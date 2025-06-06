# -*- mode: cmake -*-

#
#  Amanzi
#   Transport process kernel
#

# Amanzi module, include files found in AMANZI_MODULE_PATH
include(PrintVariable)
include(TestManager)

# Define a project name
# After this command the following varaibles are defined
#   TRANSPORT_SOURCE_DIR
#   TRANSPORT_BINARY_DIR
# Other projects (subdirectories) can reference this directory
# through these variables.
project(TRANSPORT)

# Get the includes directory for chemistry (needed for BCs).
get_property(CHEM_INCLUDES_DIR GLOBAL PROPERTY CHEM_INCLUDES_DIR)

# External (TPL) include directories
include_directories(${Epetra_INCLUDE_DIRS})
include_directories(${ASCEMIO_INCLUDE_DIR})
# Amanzi include directories
include_directories(${ATK_SOURCE_DIR})
include_directories(${CHEM_INCLUDES_DIR})
include_directories(${CHEMPK_SOURCE_DIR})
include_directories(${DATA_STRUCTURES_SOURCE_DIR})
include_directories(${FUNCS_SOURCE_DIR})
include_directories(${GEOMETRY_SOURCE_DIR})
include_directories(${MESH_FACTORY_SOURCE_DIR})
include_directories(${MESH_SOURCE_DIR})
include_directories(${MFUNCS_SOURCE_DIR})
include_directories(${MESH_MSTK_SOURCE_DIR})
include_directories(${OUTPUT_SOURCE_DIR})
include_directories(${OPERATORS_SOURCE_DIR})
include_directories(${PKS_SOURCE_DIR})
include_directories(${SOLVERS_SOURCE_DIR})
include_directories(${STATE_SOURCE_DIR})
include_directories(${TIME_INTEGRATION_SOURCE_DIR})
include_directories(${WHETSTONE_SOURCE_DIR})

#
# Library: transport
#
set(transport_inc_files
  DiffusionPhase.hh
  MaterialProperties.hh
  MDM.hh
  MDMFactory.hh
  MDMPartition.hh
  MDM_Isotropic.hh
  MDM_Bear.hh
  EvaluatorMDM.hh
  MultiscaleTransportPorosity.hh
  MultiscaleTransportPorosityFactory.hh
  MultiscaleTransportPorosityPartition.hh
  MultiscaleTransportPorosity_DPM.hh
  MultiscaleTransportPorosity_GDPM.hh
  TransportDomainFunction.hh
  TransportBoundaryFunction_Alquimia.hh
  TransportBoundaryFunction_Chemistry.hh
  TransportSourceFunction_Alquimia.hh
  TransportDefs.hh
  Transport_PK.hh
  TransportImplicit_PK.hh
  TransportExplicit_PK.hh
  models_transport_reg.hh)

set(transport_src_files Transport_PK.cc Transport_TI.cc
                        TransportImplicit_PK.cc TransportImplicit_TI.cc 
                        TransportExplicit_PK.cc TransportExplicit_TI.cc 
                        Transport_VandV.cc Transport_Initialize.cc 
                        Transport_Dispersion.cc Transport_Diffusion_Effective.cc
                        Transport_HenryLaw.cc
                        MDM_Isotropic.cc MDM_Bear.cc MDM_BurnettFrind.cc MDM_LichtnerKelkarRobinson.cc
                        MDMPartition.cc MDMFactory.cc
                        EvaluatorMDM.cc
                        MultiscaleTransportPorosityFactory.cc
                        MultiscaleTransportPorosity_DPM.cc MultiscaleTransportPorosity_GDPM.cc
                        MultiscaleTransportPorosityPartition.cc
                        TransportBoundaryFunction_Alquimia.cc
                        TransportSourceFunction_Alquimia.cc)

if (ENABLE_ALQUIMIA)
  set(geochem_lib geochemistry)
endif()
add_amanzi_library(transport 
                   SOURCE ${transport_src_files} HEADERS ${transport_inc_files}
                   LINK_LIBS geometry operators mesh error_handling state data_structures 
                             ${geochem_lib} chemistry_pk time_integration ${Epetra_LIBRARIES})

# note that these tests test the Amanzi transport PK                           
if (BUILD_TESTS AND ENABLE_AmanziPhysicsModule)
    # Add UnitTest includes
    include_directories(${UnitTest_INCLUDE_DIRS})

    # Copy test directory files if any out of source build
    if (NOT (${TRANSPORT_SOURCE_DIR} EQUAL ${TRANSPORT_BINARY_DIR}) )
        # execute_process(COMMAND ${CMAKE_COMMAND} -E 
        #   copy_directory ${TRANSPORT_SOURCE_DIR}/test ${TRANSPORT_BINARY_DIR}/test) 
        file(GLOB DataFiles "${TRANSPORT_SOURCE_DIR}/test/*.xml"
                            "${TRANSPORT_SOURCE_DIR}/test/*.exo"
                            "${TRANSPORT_SOURCE_DIR}/test/*.par.*")
        file(COPY ${DataFiles} DESTINATION ${TRANSPORT_BINARY_DIR}/test/)
    endif()

    include_directories(${TRANSPORT_SOURCE_DIR})

    set(amanzi_libs transport pks state operators mesh_functions data_structures functions 
                    whetstone mesh_factory mesh geometry)

    # Test: miscaleneous transport routines
    add_amanzi_test(transport_mics transport_mics
                    KIND unit
                    SOURCE test/Main.cc test/transport_mics.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_advance transport_advance
                    KIND unit
                    SOURCE test/Main.cc test/transport_advance.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_convergence transport_convergence
                    KIND unit
		    NPROCS 3
                    SOURCE test/Main.cc test/transport_convergence.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    # diffusion and dispersion
    add_amanzi_test(transport_dispersion transport_dispersion
                    KIND unit
                    SOURCE test/Main.cc test/transport_dispersion.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_diffusion_smiles transport_diffusion_smiles
                    KIND unit
                    SOURCE test/Main.cc test/transport_diffusion_smiles.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_2D transport_2D
                    KIND unit
                    SOURCE test/Main.cc test/transport_2D.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_2D_long transport_2D_long 
                    KIND unit
                    SOURCE test/Main.cc test/transport_2D_long.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_2D_source transport_2D_source
                    KIND unit
                    SOURCE test/Main.cc test/transport_2D_source.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_3D_long transport_3D_long
                    KIND unit
                    SOURCE test/Main.cc test/transport_3D_long.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_multiscale transport_multiscale
                    KIND unit
                    SOURCE test/Main.cc test/transport_multiscale.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_implicit_2D transport_implicit_2D
                    KIND unit
                    SOURCE test/Main.cc test/transport_implicit_2D.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_implicit_3D transport_implicit_3D
                    KIND unit
                    SOURCE test/Main.cc test/transport_implicit_3D.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(transport_subcycling transport_subcycling
                    KIND unit
                    SOURCE test/Main.cc test/transport_subcycling.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    if (ENABLE_MESH_MSTK)
       add_amanzi_test(transport_parallel_mstk transport_parallel_mstk
                       KIND int
                       NPROCS 4 
                       SOURCE test/Main.cc test/transport_parallel_mstk.cc
                       LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

       add_amanzi_test(transport_parallel_read_mstk transport_parallel_read_mstk
                       KIND int
                       NPROCS 4 
                       SOURCE test/Main.cc test/transport_parallel_read_mstk.cc
                       LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})
    
       # fractures
       add_amanzi_test(transport_fractures transport_fractures
                      KIND unit
                      NPROCS 2
                      SOURCE test/Main.cc test/transport_fractures.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})
    endif()

    add_amanzi_test(transport_fractures_implicit transport_fractures_implicit
                    KIND unit
                    SOURCE test/Main.cc test/transport_fractures_implicit.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    # fct
    add_amanzi_test(transport_fct transport_fct
                    KIND unit
                    NPROCS 2
                    SOURCE test/Main.cc test/transport_fct.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})
    # wet/dry
    add_amanzi_test(transport_wet_dry transport_wet_dry
                    KIND unit
                    SOURCE test/Main.cc test/transport_wet_dry.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

endif()

