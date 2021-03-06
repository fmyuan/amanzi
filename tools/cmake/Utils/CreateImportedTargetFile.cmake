include(CMakeParseArguments)
include(PrintVariable)

function(Create_Imported_Target_File output)

  # --- Macros for this function 
  macro(WRITE_HEADER)
    file(WRITE ${output}  "# Imported Library Targets\n")
    file(APPEND ${output} "# Generated by CMake ${CMAKE_VERSION}\n")
  endmacro(WRITE_HEADER)

  macro(WRITE_TARGET target type)
    file(APPEND ${output} "\n# Import target \"${target}\"\n")
    file(APPEND ${output} "ADD_LIBRARY(${target} ${type} IMPORTED)\n")
  endmacro(WRITE_TARGET)

  macro(WRITE_TARGET_PROPERTIES target)

    set(_imported_target_properties 
         IMPORTED_LOCATION
	 IMPORTED_LINK_INTERFACE_LANGUAGES
	 INTERFACE_LINK_LIBRARIES)

    set(_write_string "SET_TARGET_PROPERTIES(${target} PROPERTIES\n")

    foreach(_prop_name ${_imported_target_properties})
      get_target_property(_prop ${target} ${_prop_name})
      if ( _prop )
	set(_write_string "${_write_string}  ${_prop_name} \"${_prop}\"\n")
      endif()
    endforeach()
    set(_write_string "${_write_string})\n")

    file(APPEND ${output} "${_write_string}")

  endmacro(WRITE_TARGET_PROPERTIES)

  # --- Begin function MAIN 
  write_header()

  # --- Loop through each library type
  set(_lib_types UNKNOWN SHARED STATIC)
  foreach( _type ${_lib_types} )
    get_property(_libs GLOBAL PROPERTY IMPORTED_${_type}_LIBRARIES)
    foreach ( _lib ${_libs} )
      write_target(${_lib} ${_type})
      write_target_properties(${_lib})
    endforeach()
  endforeach()  

endfunction(Create_Imported_Target_File )
