include_guard(GLOBAL)

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NOT C IN_LIST languages AND NOT CXX IN_LIST languages)
  return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/util.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/build_type.cmake)

add_custom_build_type_like(PROFILING RELEASE)

if(CXX IN_LIST languages)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_link_options($<$<CONFIG:PROFILING>:/PROFILE>)
  endif()
endif()

if(C IN_LIST languages)
  if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    add_link_options($<$<CONFIG:PROFILING>:/PROFILE>)
  endif()
endif()

function(add_profiling)
  set(cpu_profiling_tools GPROF LTRACE STRACE)
  set(gpu_profiling_tools NVPROF)
  set(oneValueArgs TARGET WITH_CPU_profiling WITH_GPU_profiling
                   ${cpu_profiling_tools} ${gpu_profiling_tools})
  cmake_parse_arguments(this "" "${oneValueArgs}" "ARGS" ${ARGN})
  separate_arguments(this_ARGS)

  if("${this_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no target specified")
    return()
  endif()

  if(NOT TARGET ${this_TARGET})
    message(FATAL_ERROR "${this_TARGET} is not a target")
    return()
  endif()

  if("${this_WITH_CPU_profiling}" STREQUAL "")
    set(this_WITH_CPU_profiling TRUE)
  endif()

  if("${this_WITH_GPU_profiling}" STREQUAL "")
    set(this_WITH_GPU_profiling TRUE)
  endif()

  # set default values for runtime profiling
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

  find_package(gprof)
  if("${this_GPROF}" STREQUAL "" AND gprof_FOUND)
    set(this_GPROF TRUE)
  elseif(${this_GPROF} AND NOT gprof_FOUND)
    message(WARNING "no gprof")
    set(this_GPROF FALSE)
  endif()

  find_package(ltrace)
  if("${this_LTRACE}" STREQUAL "" AND ltrace_FOUND)
    set(this_LTRACE TRUE)
  elseif(this_LTRACE AND NOT ltrace_FOUND)
    message(WARNING "no ltrace")
    set(this_LTRACE FALSE)
  endif()

  find_package(strace)
  if("${this_STRACE}" STREQUAL "" AND strace_FOUND)
    set(this_STRACE TRUE)
  elseif(this_STRACE AND NOT strace_FOUND)
    message(WARNING "no strace")
    set(this_STRACE FALSE)
  endif()

  find_package(nvprof)
  if("${this_NVPROF}" STREQUAL "")
    set(this_NVPROF FALSE)
  elseif(this_NVPROF AND NOT CUDA_nvprof_FOUND)
    message(WARNING "no CUDA")
    set(this_NVPROF FALSE)
  endif()

  set(has_profiling FALSE)
  foreach(tool IN LISTS cpu_profiling_tools gpu_profiling_tools)
    if(NOT ${this_${tool}})
      continue()
    endif()

    set(has_profiling TRUE)
    set(new_target "${tool}_${this_TARGET}")
    clone_executable(${this_TARGET} ${new_target})
    set(new_target_command $<TARGET_FILE:${new_target}>)
    set(profiling_output_file
        ${CMAKE_BINARY_DIR}/profiling_output/${new_target}.txt)

    if(tool STREQUAL GPROF)
      target_compile_options(${new_target} PRIVATE "-pg")
      target_link_options(${new_target} PRIVATE "-pg")
      set(gprof_command
          bash -c
          "$<TARGET_FILE:${new_target}> ${this_ARGS} && $<TARGET_FILE:gprof::gprof> -p --brief $<TARGET_FILE:${new_target}> `find ${CMAKE_BINARY_DIR} -name gmon.out` > ${profiling_output_file}"
      )
      set(new_target_command "${gprof_command}")
    elseif(tool STREQUAL LTRACE)
      set(ltrace_command ltrace::ltrace -c --demangle -o
                         ${profiling_output_file})
      set(new_target_command "${ltrace_command};$<TARGET_FILE:${new_target}>")
    elseif(tool STREQUAL STRACE)
      set(strace_command strace::strace -c -o ${profiling_output_file})
      set(new_target_command "${strace_command};$<TARGET_FILE:${new_target}>")
    elseif(tool STREQUAL NVPROF)
      set(nvprof_command CUDA::nvprof --profile-from-start off --log-file
                         ${profiling_output_file})
      set(new_target_command "${nvprof_command};$<TARGET_FILE:${new_target}>")
    endif()
    set(has_profiling TRUE)
    add_test(
      NAME ${new_target}
      COMMAND ${new_target_command} ${this_ARGS}
      CONFIGURATIONS PROFILING)
  endforeach()

  if(NOT has_profiling)
    message(FATAL_ERROR "no available profiling tool")
  endif()
endfunction()

add_custom_target(
  do_profiling
  COMMAND ${CMAKE_COMMAND} -E make_directory
          ${CMAKE_BINARY_DIR}/profiling_output
  COMMAND
    ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=profiling
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DDISABLE_RUNTIME_ANALYSIS=ON
    -DBUILD_TESTING=ON ${CMAKE_SOURCE_DIR}
  COMMAND ${CMAKE_COMMAND} --build .
  DEPENDS ${CMAKE_BINARY_DIR}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
