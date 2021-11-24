include_guard(GLOBAL)
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

function (get_all_sources_and_headers)
  set(get_all_sources_and_headers [=[
#!/bin/sh
if command -v gsed >/dev/null
then
  sed_cmd=gsed
else
  sed_cmd=sed
fi
for source_file in $(grep '"file":' $1 | ${sed_cmd} -e 's/"file"://' | ${sed_cmd} -e 's/[^"]*"\([^"]*\)"/\1/')
do
  source_dir=$(dirname ${source_file})
  for head in $(${sed_cmd} -n -e 's/^\s*#include[^"]*"\([^"]*\)"/\1/p' ${source_file})
  do
    if test -f "${source_dir}/${head}"
    then
      realpath "${source_dir}/${head}"
    fi
  done
  if test -f "${source_file}"
  then
    realpath "${source_file}"
  fi
done
  ]=])
  file(WRITE ${CMAKE_BINARY_DIR}/get_all_sources_and_headers.sh ${get_all_sources_and_headers})
endfunction()
