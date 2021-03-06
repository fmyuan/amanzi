# -*- mode: cmake -*-

#
# Amanzi MSTK Find Module
#
# Usage:
#    Control the search through MSTK_DIR or setting environment variable
#    MSTK_ROOT to the MSTK installation prefix.
#
#    This module does not search default paths! 
#
#    Following variables are set:
#    MSTK_FOUND            (BOOL)       Flag indicating if MSTK was found
#    MSTK_INCLUDE_DIR      (PATH)       Path to the MSTK include file
#    MSTK_INCLUDE_DIRS     (LIST)       List of all required include files
#    MSTK_LIBRARY_DIR      (PATH)       Path to the MSTK library
#    MSTK_LIBRARY          (FILE)       MSTK library
#    MSTK_LIBRARIES        (LIST)       List of all required MSTK libraries
#
# #############################################################################

# Standard CMake modules see CMAKE_ROOT/Modules
#include(FindPackageHandleStandardArgs)

# Amanzi CMake functions see <root>/tools/cmake for source
include(PrintVariable)
include(AddPackageDependency)

if (MSTK_LIBRARIES AND MSTK_INCLUDE_DIRS)

  # Do nothing. Variables are set. No need to search again

else(MSTK_LIBRARIES AND MSTK_INCLUDE_DIRS)

  # Cache variables
  if (MSTK_DIR)
    set(MSTK_DIR "${MSTK_DIR}" CACHE PATH "Path to search for MSTK include and library files")
  endif()

  if (MSTK_INCLUDE_DIR)
    set(MSTK_INCLUDE_DIR "${MSTK_INCLUDE_DIR}" CACHE PATH "Path to search for MSTK include files")
  endif()

  if (MSTK_LIBRARY_DIR)
    set(MSTK_LIBRARY_DIR "${MSTK_LIBRARY_DIR}" CACHE PATH "Path to search for MSTK library files")
  endif()

  # Search for include files
  # Search order preference:
  #  (1) MSTK_INCLUDE_DIR - check existence of path AND if the include files exist
  #  (2) MSTK_DIR/<include>
  #  (3) Default CMake paths See cmake --html-help=out.html file for more information.
  #
  set(mstk_inc_names "MSTK.h")
  if (MSTK_INCLUDE_DIR)
    if (EXISTS "${MSTK_INCLUDE_DIR}")

      find_path(test_mstk_include_path
                NAMES ${mstk_inc_names}
                HINTS ${MSTK_INCLUDE_DIR}
                NO_DEFAULT_PATH)
      if (NOT test_mstk_include_path)
        message(SEND_ERROR "Can not locate ${mstk_inc_names} in ${MSTK_INCLUDE_DIR}")
      endif()
      set(MSTK_INCLUDE_DIR "${test_mstk_include_path}")

    else()
      message(SEND_ERROR "MSTK_INCLUDE_DIR=${MSTK_INCLUDE_DIR} does not exist")
      set(MSTK_INCLUDE_DIR "MSTK_INCLUDE_DIR-NOTFOUND")
    endif()

  else() 

    set(mstk_inc_suffixes "include")
    if (MSTK_DIR)
      if (EXISTS "${MSTK_DIR}" )

        find_path(MSTK_INCLUDE_DIR
                  NAMES ${mstk_inc_names}
                  HINTS ${MSTK_DIR}
                  PATH_SUFFIXES ${mstk_inc_suffixes}
                  NO_DEFAULT_PATH)

      else()
        message(SEND_ERROR "MSTK_DIR=${MSTK_DIR} does not exist")
        set(MSTK_INCLUDE_DIR "MSTK_INCLUDE_DIR-NOTFOUND")
      endif()    

    else()

      find_path(MSTK_INCLUDE_DIR
                NAMES ${mstk_inc_names}
                PATH_SUFFIXES ${mstk_inc_suffixes})

    endif()
  endif()

  if (NOT MSTK_INCLUDE_DIR)
     message(SEND_ERROR "Can not locate MSTK include directory")
  endif()

  # Search for libraries 
  # Search order preference:
  #  (1) MSTK_LIBRARY_DIR - check existence of path AND if the library file exists
  #  (2) MSTK_DIR/<lib,Lib>
  #  (3) Default CMake paths See cmake --html-help=out.html file for more information.
  #
  set(mstk_lib_names "mstk")
  if (MSTK_LIBRARY_DIR)
    if (EXISTS "${MSTK_LIBRARY_DIR}")

      find_library(_MSTK_LIBRARY
                   NAMES ${mstk_lib_names}
                   HINTS ${MSTK_LIBRARY_DIR}
                   NO_DEFAULT_PATH)
    else()
       message(SEND_ERROR "MSTK_LIBRARY_DIR=${MSTK_LIBRARY_DIR} does not exist")
       set(MSTK_LIBRARY "MSTK_LIBRARY-NOTFOUND")
    endif()

  else() 

    list(APPEND mstk_lib_suffixes "lib" "Lib")
    if (MSTK_DIR)
      if (EXISTS "${MSTK_DIR}" )

         find_library(_MSTK_LIBRARY
                      NAMES ${mstk_lib_names}
                      HINTS ${MSTK_DIR}
                      PATH_SUFFIXES ${mstk_lib_suffixes}
                      NO_DEFAULT_PATH)

      else()
        message(SEND_ERROR "MSTK_DIR=${MSTK_DIR} does not exist")
        set(_MSTK_LIBRARY _MSTK_LIBRARY-NOTFOUND)
      endif()    

    else()

      find_library(_MSTK_LIBRARY
                   NAMES ${mstk_lib_names}
                   PATH_SUFFIXES ${mstk_lib_suffixes})

    endif()
  endif()

  # Create the target
  if ( _MSTK_LIBRARY )
    set(MSTK_LIBRARY mstk)
    add_imported_library(${MSTK_LIBRARY}
                         LOCATION ${_MSTK_LIBRARY}
	                 LINK_LANGUAGES "C")
  else()			   
    message(SEND_ERROR "Can not locate MSTK library")
  endif()    

  # Update the INCLUDE_DIRS and LIBRARIES variables
  set(MSTK_INCLUDE_DIRS ${MSTK_INCLUDE_DIR})
  set(MSTK_LIBRARIES    ${MSTK_LIBRARY})

  # Define the dependent libs
  set(_MSTK_DEP_LIBS)

  # MSTK depends on ExodusII provided by SEACAS
  find_package(SEACAS QUIET REQUIRED)
  list(APPEND MSTK_INCLUDE_DIRS ${SEACAS_INCLUDE_DIRS})
  list(APPEND MSTK_LIBRARIES ${SEACAS_LIBRARY})
  list(APPEND _MSTK_DEP_LIBS ${SEACAS_LIBRARY})

  # And METIS
  find_package(METIS QUIET REQUIRED)
  list(APPEND MSTK_INCLUDE_DIRS ${METIS_INCLUDE_DIRS})
  list(APPEND MSTK_LIBRARIES ${METIS_LIBRARY})
  list(APPEND _MSTK_DEP_LIBS ${METIS_LIBRARIES})

  # And Zoltan
  find_package(Zoltan QUIET REQUIRED)
  list(APPEND MSTK_INCLUDE_DIRS ${Zoltan_INCLUDE_DIRS})
  list(APPEND MSTK_LIBRARIES ${Zoltan_LIBRARY})
  list(APPEND _MSTK_DEP_LIBS ${Zoltan_LIBRARIES})

  set_target_properties(${MSTK_LIBRARY} PROPERTIES
                        INTERFACE_LINK_LIBRARIES "${_MSTK_DEP_LIBS}")

endif(MSTK_LIBRARIES AND MSTK_INCLUDE_DIRS )    

# Check MSTK Version to set interface compatibility
if (MSTK_VERSION)
  # Test if MSTK is older than 2.21rc1
  if (MSTK_VERSION_MAJOR EQUAL 2 AND MSTK_VERSION_MINOR LESS 21)
    set(WITH_MSTK_2_21rc1_OR_NEWER FALSE)
  else() 
    set(WITH_MSTK_2_21rc1_OR_NEWER TRUE )
  endif()
  # Test if MSTK is newer than 3.0.0
  if (MSTK_VERSION_MAJOR EQUAL 3)
    set(WITH_MSTK_3_00_OR_NEWER TRUE)
  else() 
    set(WITH_MSTK_3_00_OR_NEWER FALSE)
  endif()    
else()
  message(STATUS "JDM >>> MSTK_VERSION unknown, assuming older than 2.21rc1.")
  set(WITH_MSTK_2_21rc1_OR_NEWER FALSE)
  set(WITH_MSTK_3_00_OR_NEWER FALSE)
endif()

# Look for installed utilities
if (MSTK_LIBRARIES AND MSTK_INCLUDE_DIRS AND WITH_MSTK_2_21rc1_OR_NEWER)
  message(STATUS "JDM >>> searching for utilities in ${MSTK_INCLUDE_DIR}/../bin/")
  set(mstk_utility_names "chkmesh;exoatt;meshconvert")
  foreach (utility ${mstk_utility_names})
    if (EXISTS "${MSTK_INCLUDE_DIR}/../bin/${utility}")
      LIST(APPEND MSTK_UTILITIES ${MSTK_INCLUDE_DIR}/../bin/${utility})
      LIST(APPEND MSTK_UTILITIES_shortnames ${utility})
    endif()
  endforeach()
  message(STATUS "JDM >>> found utilities ${MSTK_UTILITIES_shortnames}")
endif()

# Send useful message if everything is found
find_package_handle_standard_args(MSTK DEFAULT_MSG
                                  MSTK_LIBRARIES
                                  MSTK_INCLUDE_DIRS)

# find_package_handle_standard_args should set MSTK_FOUND but it does not!
if (MSTK_LIBRARIES AND MSTK_INCLUDE_DIRS)
  set(MSTK_FOUND TRUE)
else()
  set(MSTK_FOUND FALSE)
endif()

# Define the version
mark_as_advanced(
  MSTK_INCLUDE_DIR
  MSTK_INCLUDE_DIRS
  MSTK_LIBRARY
  MSTK_LIBRARIES
  MSTK_LIBRARY_DIR
  MSTK_UTILITIES
)
