INCLUDE(${CMAKE_CURRENT_LIST_DIR}/util.cmake)

ENABLE_TESTING()

if(NOT TARGET profiling)
  ADD_CUSTOM_TARGET(profiling ALL COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIGURATION>)
endif()

FIND_PACKAGE(gprof)

function(add_profiling)
  set(cpu_profiling_tools GPROF)
  set(gpu_profiling_tools NVPROF)
  cmake_parse_arguments(this "" "TARGET;${cpu_profiling_tools} ${gpu_profiling_tools}" "ARGS" ${ARGN})
  if("${this_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no target specified")
    return()
  endif()

  if(NOT TARGET ${this_TARGET})
    message(FATAL_ERROR "${this_TARGET} is not a target")
    return()
  endif()

  separate_arguments(this_ARGS)

  if("${this_WITH_CPU_profiling}" STREQUAL "")
    set(this_WITH_CPU_profiling TRUE)
  endif()

  if("${this_WITH_GPU_profiling}" STREQUAL "")
    set(this_WITH_GPU_profiling TRUE)
  endif()

  #set default values for runtime profiling
  if(NOT this_WITH_CPU_profiling)
    foreach(tool IN LISTS cpu_profiling_tools)
      set(this_${tool} FALSE)
    endforeach()
  endif()

  if(NOT this_WITH_GPU_profiling)
    foreach(tool IN LISTS gpu_profiling_tools)
      set(this_${tool} FALSE)
    endforeach()
  endif()

  if("${this_GPROF}" STREQUAL "")
    set(this_GPROF TRUE)
  elseif(${this_GPROF} AND NOT gprof_FOUND)
    message(WARNING "no gprof")
    set(this_GPROF FALSE)
  elseif(${this_GPROF} AND NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    message(WARNING "no gcc")
    set(this_GPROF FALSE)
  endif()

  set(has_profiling FALSE)
  foreach(tool IN LISTS cpu_profiling_tools gpu_profiling_tools)
    if(NOT ${this_${tool}})
      continue()
    endif()

    set(new_target "${tool}_${this_TARGET}")
    clone_target(OLD_TARGET ${this_TARGET} NEW_TARGET ${new_target})
    set(new_target_command $<TARGET_FILE:${new_target}>)
    set(has_profiling TRUE)

    if(tool STREQUAL GPROF)
      target_compile_options(${new_target} PRIVATE "-pg")
      set_target_properties(${new_target} PROPERTIES LINK_FLAGS "-pg")
      add_test(NAME "${new_target}" WORKING_DIRECTORY $<TARGET_FILE_DIR:${new_target}> COMMAND ${new_target_command} ${this_ARGS} && ${gprof_BINARY} $<TARGET_FILE:${new_target}> gmon.out)
    endif()
    add_dependencies(profiling ${new_target})
  endforeach()

  if(NOT has_profiling)
    message(FATAL_ERROR "no available profiling tool")
  endif()
endfunction()
