INCLUDE(${CMAKE_CURRENT_LIST_DIR}/util.cmake)
LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

FIND_PACKAGE(gprof)
FIND_PACKAGE(ltrace)
FIND_PACKAGE(strace)
FIND_PACKAGE(CUDA)

function(add_profiling)
  set(cpu_profiling_tools GPROF LTRACE STRACE)
  set(gpu_profiling_tools NVPROF)
  set(oneValueArgs TARGET WITH_CPU_profiling WITH_GPU_profiling ${cpu_profiling_tools} ${gpu_profiling_tools})
  cmake_parse_arguments(this "" "${oneValueArgs}" "ARGS" ${ARGN})
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
  endif()
  if(${this_GPROF} AND NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    message(WARNING "no gcc")
    set(this_GPROF FALSE)
  endif()

  if("${this_LTRACE}" STREQUAL "")
    set(this_LTRACE TRUE)
  elseif(${this_LTRACE} AND NOT ltrace_FOUND)
    message(WARNING "no ltrace")
    set(this_LTRACE FALSE)
  endif()

  if("${this_STRACE}" STREQUAL "")
    set(this_STRACE TRUE)
  elseif(${this_STRACE} AND NOT strace_FOUND)
    message(WARNING "no strace")
    set(this_STRACE FALSE)
  endif()

  if("${this_NVPROF}" STREQUAL "")
    set(this_NVPROF FALSE)
  elseif(${this_NVPROF} AND NOT CUDA_FOUND)
    message(WARNING "no CUDA")
    set(this_NVPROF FALSE)
  endif()

  set(has_profiling FALSE)
  foreach(tool IN LISTS cpu_profiling_tools gpu_profiling_tools)
    if(NOT ${this_${tool}})
      continue()
    endif()

    set(new_target "${tool}_${this_TARGET}")
    clone_target(OLD_TARGET ${this_TARGET} NEW_TARGET ${new_target})
    set(new_target_command $<TARGET_FILE:${new_target}>)
    set(profiling_output_file ${CMAKE_BINARY_DIR}/profiling_output/${new_target}.txt)

    if(tool STREQUAL GPROF)
      target_compile_options(${new_target} PRIVATE "-pg")
      set_target_properties(${new_target} PROPERTIES LINK_FLAGS "-pg")

      add_custom_target("${tool}_${this_TARGET}_output" ALL
	COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/profiling_output
	COMMAND ${new_target_command} ${this_ARGS}
	COMMAND	${gprof_BINARY} -p --brief $<TARGET_FILE:${new_target}> `find ${CMAKE_BINARY_DIR} -name gmon.out` > ${profiling_output_file}
	DEPENDS ${new_target})
      set(has_profiling TRUE)
    elseif(tool STREQUAL LTRACE)
      add_custom_target("${tool}_${this_TARGET}_output" ALL
	COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/profiling_output
	COMMAND ${ltrace_BINARY} -c --demangle -o ${profiling_output_file} ${new_target_command} ${this_ARGS}
	DEPENDS ${new_target})
      set(has_profiling TRUE)
    elseif(tool STREQUAL STRACE)
      add_custom_target("${tool}_${this_TARGET}_output" ALL
	COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/profiling_output
	COMMAND ${strace_BINARY} -c -o ${profiling_output_file} ${new_target_command} ${this_ARGS}
	DEPENDS ${new_target})
      set(has_profiling TRUE)
    elseif(tool STREQUAL NVPROF)
      add_custom_target("${tool}_${this_TARGET}_output" ALL
	COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/profiling_output
	COMMAND ${CUDA_TOOLKIT_ROOT_DIR}/bin/nvprof --profile-from-start off --log-file ${profiling_output_file} ${new_target_command} ${this_ARGS}
	DEPENDS ${new_target})
      set(has_profiling TRUE)
    endif()
  endforeach()

  if(NOT has_profiling)
    message(FATAL_ERROR "no available profiling tool")
  endif()
endfunction()
