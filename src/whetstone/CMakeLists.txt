# -*- mode: cmake -*-

#
#  Amanzi
#   Discretization library
#

# Amanzi module, include files found in AMANZI_MODULE_PATH
include(PrintVariable)
include(TestManager)
include(LibraryManager)

#
# Define a project name
# After this command the following varaibles are defined
#   WHETSTONE_SOURCE_DIR
#   WHETSTONE_BINARY_DIR
# Other projects (subdirectories) can reference this directory
# through these variables.
project(WHETSTONE)

# Amanzi include directories
include_directories(${DBC_SOURCE_DIR})
include_directories(${ATK_SOURCE_DIR})
include_directories(${MESH_SOURCE_DIR})
include_directories(${MESH_FACTORY_SOURCE_DIR})
include_directories(${GEOMETRY_SOURCE_DIR})
include_directories(${WHETSTONE_SOURCE_DIR})
include_directories(${DBG_SOURCE_DIR})

# External (TPL) include directories
include_directories(${Teuchos_INCLUDE_DIRS})
include_directories(${Epetra_INCLUDE_DIRS})

#
# Library: whetstone
#
add_amanzi_library(whetstone
                   SOURCE DeRham_Node.cc DeRham_Edge.cc DeRham_Face.cc
                          MFD3D.cc
                          MFD3D_BernardiRaugel.cc MFD3D_BernardiRaugelGradDiv.cc
                          MFD3D_CrouzeixRaviart.cc MFD3D_CrouzeixRaviartAnyOrder.cc
                          MFD3D_CrouzeixRaviartSerendipity.cc
                          MFD3D_Diffusion.cc MFD3D_Diffusion_Surface.cc MFD3D_Diffusion_Other.cc 
                          MFD3D_Diffusion_CurvedFace.cc 
                          MFD3D_Elasticity.cc MFD3D_ElasticityGradDiv.cc 
                          MFD3D_ElasticityWeakSymmetry.cc 
                          MFD3D_Electromagnetics.cc MFD3D_Electromagnetics_Surface.cc
                          MFD3D_GeneralizedDiffusion.cc
                          MFD3D_Lagrange.cc MFD3D_LagrangeAnyOrder.cc
                          MFD3D_LagrangeSerendipity.cc
                          DG_Modal.cc
                          Basis_Regularized.cc
                          Basis_Normalized.cc Basis_Orthonormalized.cc
                          BilinearFormFactory.cc
                          nlfv.cc 
                          NumericalIntegration.cc
                          Tensor.cc DenseMatrix.cc DenseVector.cc
                          Polynomial.cc SpaceTimePolynomial.cc VectorObjects.cc
                          MeshMapsBase.cc
                          MeshMaps_FEM.cc MeshMaps_VEM.cc
                          SplinePolynomial.cc
                   HEADERS DenseMatrix.hh DenseVector.hh
                           DG_Modal.hh
                           Basis.hh BasisFactory.hh
                           Basis_Natural.hh Basis_Regularized.hh 
                           Basis_Normalized.hh Basis_Orthonormalized.hh
                           lapack.hh
                           BilinearForm.hh BilinearFormFactory.hh 
                           DeRham_Node.hh DeRham_Edge.hh DeRham_Face.hh
                           GrammMatrix.hh
                           FunctionUpwind.hh
                           FunctionComposite.hh
                           MFD3D.hh
                           MFD3D_BernardiRaugel.hh MFD3D_BernardiRaugelGradDiv.hh
                           MFD3D_CrouzeixRaviart.hh MFD3D_CrouzeixRaviartAnyOrder.hh
                           MFD3D_CrouzeixRaviartSerendipity.hh
                           MFD3D_Diffusion.hh MFD3D_Diffusion_CurvedFace.hh
                           MFD3D_Elasticity.hh MFD3D_ElasticityGradDiv.hh
                           MFD3D_ElasticityWeakSymmetry.hh
                           MFD3D_Electromagnetics.hh
                           MFD3D_GeneralizedDiffusion.hh
                           MFD3D_Lagrange.hh MFD3D_LagrangeAnyOrder.hh 
                                             MFD3D_LagrangeSerendipity.hh
                           nlfv.hh
                           NumericalIntegration.hh
                           Quadrature1D.hh Quadrature2D.hh Quadrature3D.hh
                           MeshMapsBase.hh MeshMapsFactory.hh
                           MeshMaps_FEM.hh MeshMaps_VEM.hh MeshMaps_VEM.hh
                           Monomial.hh Polynomial.hh PolynomialIterator.hh PolynomialBase.hh
                           SpaceTimePolynomial.hh
                           SplinePolynomial.hh
                           VectorObjects.hh MatrixObjects.hh PolynomialOnMesh.hh
                           Tensor.hh
                           WhetStoneDefs.hh
                           WhetStoneFunction.hh WhetStoneMeshUtils.hh
                           bilinear_form_reg.hh
                   LINK_LIBS geometry mesh error_handling ${Epetra_LIBRARIES})


if (BUILD_TESTS)
    # Add UnitTest includes
    include_directories(${UnitTest_INCLUDE_DIRS})
    include_directories(${MESH_SIMPLE_SOURCE_DIR})

    # Copy test directory files if an out of source build
    if (NOT (${WHETSTONE_SOURCE_DIR} EQUAL ${WHETSTONE_BINARY_DIR}))
        file(GLOB DataFiles "${WHETSTONE_SOURCE_DIR}/test/*.exo")
        file(COPY ${DataFiles} DESTINATION ${WHETSTONE_BINARY_DIR}/test/)
    endif()

    set(amanzi_libs geometry mesh mesh_factory whetstone)

    # Test: matrices for diffusion
    add_amanzi_test(whetstone_diffusion whetstone_diffusion
                    KIND unit
                    SOURCE test/Main.cc test/whetstone_diffusion.cc 
                           test/whetstone_diffusion_tangled.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

    # Test: matrices for elasticity
    add_amanzi_test(whetstone_elasticity whetstone_elasticity
                    KIND unit
                    SOURCE test/Main.cc test/whetstone_elasticity.cc
                           test/whetstone_elasticity_other.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

    # Test: matrices for electromagnetics
    add_amanzi_test(whetstone_electromagnetics whetstone_electromagnetics
                    KIND unit
                    SOURCE test/Main.cc test/whetstone_electromagnetics.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

    # Test: miscalleneous library tools
    add_amanzi_test(whetstone_misc whetstone_misc
                    KIND unit
                    SOURCE test/Main.cc test/whetstone_tensors.cc
                                        test/whetstone_geometry.cc
                                        test/whetstone_factory.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

    # Test: surface matrices for diffusion
    add_amanzi_test(whetstone_surface whetstone_surface
                    KIND unit
                    SOURCE test/Main.cc test/whetstone_surface.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

    # Test: various toolsets
    add_amanzi_test(whetstone_nlfv whetstone_nlfv
                    KIND unit
                    SOURCE test/Main.cc test/whetstone_nlfv.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

    # Test: matrices for DG methods
    add_amanzi_test(whetstone_dg whetstone_dg
                    KIND unit
                    SOURCE test/Main.cc 
                                        test/whetstone_polynomials.cc
                                        test/whetstone_dg.cc
                                        test/whetstone_numi.cc
                                        test/whetstone_maps.cc
                                        test/whetstone_projectors.cc
                                        test/whetstone_high_order.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

    # Test: matrices for Derham complex
    add_amanzi_test(whetstone_derham whetstone_derham
                    KIND unit
                    SOURCE test/Main.cc test/whetstone_derham.cc
                    LINK_LIBS ${amanzi_libs} ${UnitTest_LIBRARIES})

endif()


