SET(pack_cmake_dir ${CMAKE_CURRENT_LIST_DIR})

set(bundle_dir ${CMAKE_BINARY_DIR}/bundle)

add_custom_target(create_bundle
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${bundle_dir}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${bundle_dir}
)
function(pack_executable)
  set(oneValueArgs EXE_TARGET)
  cmake_parse_arguments(this "" "${oneValueArgs}" "" ${ARGN})
  if("${this_EXE_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no EXE_TARGET specified")
    return()
  endif()

  if(NOT TARGET ${this_EXE_TARGET})
    message(FATAL_ERROR "${this_EXE_TARGET} is not a target")
    return()
  endif()

  get_target_property(property_var ${this_EXE_TARGET} TYPE)

  if(NOT property_var STREQUAL EXECUTABLE)
    message(FATAL_ERROR "can't pack target type ${property_var}")
    return()
  endif()

  set(name "deploy_${this_EXE_TARGET}")
  add_custom_target(${name} ALL
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${this_EXE_TARGET}> ${bundle_dir}
    COMMAND env APP=${bundle_dir}/$<TARGET_FILE_NAME:${this_EXE_TARGET}> ${CMAKE_COMMAND} -P ${pack_cmake_dir}/pack.cmake.in
    WORKING_DIRECTORY ${bundle_dir}
    )
  add_dependencies(${name} ${this_EXE_TARGET})
  add_dependencies(${name} create_bundle)
endfunction()
