function(clone_executable old_target new_target) 
  if(NOT TARGET ${old_target})
    message(FATAL_ERROR "${old_target} is not a target")
    return()
  endif()

  get_target_property(property_var ${old_target} TYPE)
  if(NOT property_var STREQUAL EXECUTABLE)
    message(FATAL_ERROR "${old_target} is not an executable")
    return()
  endif()

  get_target_property(source_files ${old_target} SOURCES)
  add_executable(${new_target} ${source_files})
  
  # get all properties
  execute_process(COMMAND ${CMAKE_COMMAND} --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)
  # Convert command output into a CMake list
  string(REGEX REPLACE "[\n\r]" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")

  foreach(property IN LISTS CMAKE_PROPERTY_LIST) 
    if(
	property STREQUAL ""
	OR property STREQUAL "TYPE"
	OR property MATCHES ".*LOCATION.*"
	OR property STREQUAL "NAME"
	)
      continue()
    endif()

    get_target_property(property_value ${old_target} "${property}")

    if(NOT property_value)
      continue()
    endif()

    set_target_properties(${new_target} PROPERTIES "${property}" "${property_value}")
  ENDFOREACH()
endfunction()

function(target_add_address_sanitizer target_variable)
  cmake_parse_arguments("" "" "RESULT_VARIABLE" "" ${ARGN})
  find_package(GoogleSanitizer)

  if(address_sanitizer_FOUND)
    target_compile_options("${target_variable}" PRIVATE "-fsanitize=address")
    target_link_options("${target_variable}" PRIVATE "-fsanitize=address")
  endif()

  if(NOT "${RESULT_VARIABLE}" STREQUAL "")
    set("${RESULT_VARIABLE}" ${address_sanitizer_FOUND})
  endif()
endfunction()
