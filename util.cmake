function(clone_target)
  set(oneValueArgs TARGET OLD_TARGET NEW_TARGET)
  cmake_parse_arguments(this "" "${oneValueArgs}" "" ${ARGN})
  if("${this_OLD_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no OLD_TARGET specified")
    return()
  endif()
  if("${this_NEW_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no NEW_TARGET specified")
    return()
  endif()

  if(NOT TARGET ${this_OLD_TARGET})
    message(FATAL_ERROR "${this_OLD_TARGET} is not a target")
    return()
  endif()


  get_target_property(property_var ${this_OLD_TARGET} TYPE)

  if(property_var STREQUAL EXECUTABLE)
    add_executable(${this_NEW_TARGET} ${property_var})
  else()
    message(FATAL_ERROR "can't clone target type ${property_var}")
    return()
  endif()
  
  get_target_property(property_var ${this_OLD_TARGET} SOURCES)



  # get all targets
  execute_process(COMMAND ${CMAKE_COMMAND} --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)
  # Convert command output into a CMake list
  STRING(REGEX REPLACE "[\n\r]" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")

  foreach(property IN LISTS CMAKE_PROPERTY_LIST) 
    if(property MATCHES "^<CONFIG>_" 
	OR property MATCHES "^<LANG>_"
	OR property MATCHES "_<.*>"
	OR property MATCHES "^IMPORTED.*"
	OR property STREQUAL ""
	OR property STREQUAL "TYPE"
	OR property STREQUAL "LOCATION"
	OR property STREQUAL "VS_DEPLOYMENT_LOCATION"
	OR property STREQUAL "MANUALLY_ADDED_DEPENDENCIES"
	OR property STREQUAL "MACOSX_PACKAGE_LOCATION"
	OR property STREQUAL "NAME"
	)
      continue()
    endif()

    get_target_property(property_var ${this_OLD_TARGET} ${property})

    if(property_var STREQUAL "property_var-NOTFOUND"
	OR property_var STREQUAL "")
      continue()
    endif()

    set_target_properties(${this_NEW_TARGET} PROPERTIES ${property} "${property_var}")
  ENDFOREACH()
endfunction()
