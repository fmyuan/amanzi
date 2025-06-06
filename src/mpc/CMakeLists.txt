#
#  Amanzi
#    Mulitprocess Coordinator (MPC)
#

# Amanzi module, include files found in AMANZI_MODULE_PATH
include(PrintVariable)
include(TestManager)
include(LibraryManager)

#
# Define a project name
# After this command the following varaibles are defined
#   MPC_SOURCE_DIR
#   MPC_BINARY_DIR
# Other projects (subdirectories) can reference this directory
# through these variables.
project(MPC)

# Amanzi include directories
include_directories(${ATK_SOURCE_DIR})
include_directories(${CHEM_SOURCE_DIR})
include_directories(${CHEMPK_SOURCE_DIR})
include_directories(${DATA_STRUCTURES_SOURCE_DIR})
include_directories(${DBC_SOURCE_DIR})
include_directories(${DBG_SOURCE_DIR})
include_directories(${DUMMYPK_SOURCE_DIR})
include_directories(${ENERGY_SOURCE_DIR})
include_directories(${EOS_SOURCE_DIR})
include_directories(${EVALUATORS_SOURCE_DIR})
include_directories(${FLOW_SOURCE_DIR})
include_directories(${FUNCS_SOURCE_DIR})
include_directories(${GEOMETRY_SOURCE_DIR})
include_directories(${GEOCHEM_SOURCE_DIR})
include_directories(${MECHANICS_SOURCE_DIR})
include_directories(${MESH_DATA_SOURCE_DIR})
include_directories(${MESH_EXTRACTED_SOURCE_DIR})
include_directories(${MESH_MSTK_SOURCE_DIR})
include_directories(${MESH_SOURCE_DIR})
include_directories(${MFUNCS_SOURCE_DIR})
include_directories(${MPC_TREE_SOURCE_DIR})
include_directories(${MULTIPHASE_SOURCE_DIR})
include_directories(${OPERATORS_SOURCE_DIR})
include_directories(${OUTPUT_SOURCE_DIR})
include_directories(${PKS_SOURCE_DIR})
include_directories(${STATE_SOURCE_DIR})
include_directories(${STATE_SOURCE_DIR}/data)
include_directories(${STATE_SOURCE_DIR}/evaluators)
include_directories(${TIME_INTEGRATION_SOURCE_DIR})
include_directories(${TRANSPORT_SOURCE_DIR})
include_directories(${SHALLOW_WATER_SOURCE_DIR})
include_directories(${SOLVERS_SOURCE_DIR})
include_directories(${WHETSTONE_SOURCE_DIR})


# Chemistry includes directory
get_property(CHEM_INCLUDES_DIR GLOBAL PROPERTY CHEM_INCLUDES_DIR)
include_directories(${CHEM_INCLUDES_DIR})

# External (TPL) include directories
include_directories(${Teuchos_INCLUDE_DIRS})
include_directories(${Epetra_INCLUDE_DIRS})
include_directories(${HDF5_C_INCLUDE_DIR})
include_directories(${HDF5_INCLUDE_DIRS})
include_directories(${ASCEMIO_INCLUDE_DIR})

#
# Library: mpc
#
set(mpc_tpl_libs ${Teuchos_LIBRARIES} ${Epetra_LIBRARIES}) 
list(REVERSE mpc_tpl_libs)
list(REMOVE_DUPLICATES mpc_tpl_libs) # Concerned about command line length! --lpritch
list(REVERSE mpc_tpl_libs)

set(mpc_inc_files
  CycleDriver.hh
  FlexibleObservations.hh
  WalkaboutCheckpoint.hh
  ObservableAmanzi.hh
  ObservableFactory.hh
  ObservableAqueous.hh 
  ObservableLineSegment.hh
  ObservableSolute.hh
  ObservableLineSegmentAqueous.hh
  ObservableLineSegmentSolute.hh
)

add_amanzi_library(mpc 
                   SOURCE CycleDriver.cc 
                          FlexibleObservations.cc WalkaboutCheckpoint.cc 
                          ObservableFactory.cc
                          ObservableAqueous.cc ObservableSolute.cc
                   HEADERS ${mpc_inc_files}
                   LINK_LIBS time_integration solvers output mpc_tree state mesh dbg
                             flow mechanics ${mpc_tpl_libs})

if (BUILD_TESTS)
    include_directories(${MESH_FACTORY_SOURCE_DIR})

    # Add UnitTest includes
    include_directories(${UnitTest_INCLUDE_DIRS})
    # Add MPC include directory. Need to remove this required path. -- lpritch
    include_directories(${MPC_SOURCE_DIR})

    # Copy test subdirectory for out of source builds
    if (NOT (MPC_SOURCE_DIR STREQUAL MPC_BINARY_DIR))
      file(GLOB DataFiles "${MPC_SOURCE_DIR}/test/*.xml"
                          "${MPC_SOURCE_DIR}/test/*.in"
                          "${MPC_SOURCE_DIR}/test/*.dat"
                          "${MPC_SOURCE_DIR}/test/*.exo"
                          "${MPC_SOURCE_DIR}/test/*.h5")
      file(COPY ${DataFiles} DESTINATION ${MPC_BINARY_DIR}/test/)
    endif()

    set(amanzi_libs mpc pks mpc_tree flow transport chemistry_pk energy shallow_water 
                    dummy pks eos state operators mesh_extracted mesh_factory 
                    geometry whetstone mesh_functions functions)

    # Test: mpc driver for flow
    add_amanzi_test(mpc_flow mpc_flow
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_flow.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    # Test: mpc driver for transport
    add_amanzi_test(mpc_transport mpc_transport
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_transport.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    # Test: mpc driver for shallow water
    add_amanzi_test(mpc_shallow_water mpc_shallow_water
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_shallow_water.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    # Test: mpc driver for multiphase
    add_amanzi_test(mpc_multiphase_fracture mpc_multiphase_fractures
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_multiphase_fractures.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    add_amanzi_test(mpc_multiphase_thermal mpc_multiphase_thermal
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_multiphase_thermal.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    # Test: mpc driver for reactive transport
    add_amanzi_test(mpc_reactive_transport mpc_reactive_transport
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_reactive_transport.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    # Test: mpc driver for thermal richards
    add_amanzi_test(mpc_thermal_richards mpc_thermal_richards
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_thermal_richards.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(mpc_thermal_darcy_dfn mpc_thermal_darcy_dfn
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_thermal_darcy_dfn.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(mpc_thermal_richards_jacobian mpc_thermal_richards_jacobian
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_thermal_richards_jacobian.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    # Test: mpc driver for flow and reactive transport
    add_amanzi_test(mpc_flow_reactive_transport mpc_flow_reactive_transport
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_flow_reactive_transport.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    # Test: mpc driver for coupled matrix-fracture flow, energy, and transport
    add_amanzi_test(mpc_coupled_flow mpc_coupled_flow
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_coupled_flow.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(mpc_coupled_flow_richards mpc_coupled_flow_richards
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_coupled_flow_richards.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(mpc_coupled_flow_source mpc_coupled_flow_source
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_coupled_flow_source.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})
    
    add_amanzi_test(mpc_coupled_flow_aperture mpc_coupled_flow_aperture
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_coupled_flow_aperture.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(mpc_coupled_energy mpc_coupled_energy
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_coupled_energy.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    if(ENABLE_MESH_MSTK)
      add_amanzi_test(mpc_coupled_transport mpc_coupled_transport
                      KIND      int
                      SOURCE    test/Main.cc test/mpc_coupled_transport.cc
	              LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})                  

      add_amanzi_test(mpc_coupled_dispersive_transport mpc_coupled_dispersive_transport
                      KIND      int
                      NPROCS    2
                      SOURCE    test/Main.cc test/mpc_coupled_dispersive_transport.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})                  

      add_amanzi_test(mpc_coupled_flow_transport mpc_coupled_flow_transport
                      KIND      int
                      SOURCE    test/Main.cc test/mpc_coupled_flow_transport.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})                  

      add_amanzi_test(mpc_coupled_flow_transport_implicit mpc_coupled_flow_transport_implicit
                      KIND      int
                      SOURCE    test/Main.cc test/mpc_coupled_flow_transport_implicit.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

      add_amanzi_test(mpc_coupled_flow_transport_gas mpc_coupled_flow_transport_gas
                      KIND      int
                      NPROCS    3
                      SOURCE    test/Main.cc test/mpc_coupled_flow_transport_gas.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

      add_amanzi_test(mpc_coupled_reactive_transport mpc_coupled_reactive_transport
                      KIND      int
                      SOURCE    test/Main.cc test/mpc_coupled_reactive_transport.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})
    
      add_amanzi_test(mpc_coupled_flow_reactive_transport mpc_coupled_flow_reactive_transport
                      KIND      int
                      SOURCE    test/Main.cc test/mpc_coupled_flow_reactive_transport.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})
    
      # Test: mpc driver for coupled matrix-fracture flow and transport: benchmark
      add_amanzi_test(mpc_benchmark_single mpc_benchmark_single
                      KIND      int
                      NPROCS    3
                      SOURCE    test/Main.cc test/mpc_benchmark_single.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})                  

      add_amanzi_test(mpc_coupled_mechanics_flow mpc_coupled_mechanics_flow
                      KIND      int
                      SOURCE    test/Main.cc test/mpc_coupled_mechanics_flow.cc
                      LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    endif()

    add_amanzi_test(mpc_coupled_thermal_flow mpc_coupled_thermal_flow
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_coupled_thermal_flow.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(mpc_coupled_thermal_flow_richards mpc_coupled_thermal_flow_richards
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_coupled_thermal_flow_richards.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(mpc_coupled_thermal_flow_methalpy mpc_coupled_thermal_flow_methalpy
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_coupled_thermal_flow_methalpy.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    add_amanzi_test(mpc_recovery mpc_recovery
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_recovery.cc
		    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    # Test: mpc driver for integrated hydrology: 1D dam break over saturated subsurface
    add_amanzi_test(mpc_ihm_flow_shallow_water mpc_ihm_flow_shallow_water
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_ihm_flow_shallow_water.cc
        	    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})                

    # Test: mpc driver for integrated hydrology: solute transport in shallow water
    add_amanzi_test(mpc_ihm_shallow_water_transport mpc_ihm_shallow_water_transport
                    KIND      int
                    NPROCS    2
                    SOURCE    test/Main.cc test/mpc_ihm_shallow_water_transport.cc
        	    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})                

    # Test: mpc driver for integrated hydrology: solute transport in shallow water: convergence
    add_amanzi_test(mpc_ihm_shallow_water_transport_Thacker mpc_ihm_shallow_water_transport_Thacker
                    KIND      int
                    NPROCS    4
                    SOURCE    test/Main.cc test/mpc_ihm_shallow_water_transport_Thacker.cc
        	    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})                

    # Test: mpc-new driver dummy
    add_amanzi_test(mpc_dummy mpc_dummy
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_dummy_pk.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    # Test: observable_line_segment
    add_amanzi_test(observable_line_segment observable_line_segment
                    KIND      int
                    SOURCE    test/Main.cc test/observable_line_segment.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES})

    # Test: walkabout
    add_amanzi_test(mpc_walkabout mpc_walkabout 
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_walkabout.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    # Test: default MPCs
    add_amanzi_test(mpc_default mpc_default
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_default.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    # Test: mechanics
    add_amanzi_test(mpc_mechanics_flow_aperture mpc_mechanics_flow_aperture
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_mechanics_flow_aperture.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    add_amanzi_test(mpc_mechanics_mandel mpc_mechanics_mandel
                    KIND      int
                    NPROCS    3
                    SOURCE    test/Main.cc test/mpc_mechanics_mandel.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    add_amanzi_test(mpc_mechanics_stress_split mpc_mechanics_stress_split
                    KIND      int
                    NPROCS    3
                    SOURCE    test/Main.cc test/mpc_mechanics_stress_split.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    add_amanzi_test(mpc_mechanics_thermal_flow mpc_mechanics_thermal_flow
                    KIND      int
                    NPROCS    3
                    SOURCE    test/Main.cc test/mpc_mechanics_thermal_flow.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    add_amanzi_test(mpc_mechanics_thermal_flow_3D mpc_mechanics_thermal_flow_3D
                    KIND      int
                    NPROCS    3
                    SOURCE    test/Main.cc test/mpc_mechanics_thermal_flow_3D.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    add_amanzi_test(mpc_biot_consolidation mpc_biot_consolidation
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_biot_consolidation.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    add_amanzi_test(mpc_biot_schiffman mpc_biot_schiffman
                    KIND      int
                    SOURCE    test/Main.cc test/mpc_biot_schiffman.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})

    add_amanzi_test(mpc_biot_mcnamee_gibson mpc_biot_mcnamee_gibson
                    KIND      int
                    NPROCS    3
                    SOURCE    test/Main.cc test/mpc_biot_mcnamee_gibson.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES} ${HDF5_LIBRARIES}
                                             ${HYPRE_LIBRARY})
endif()
