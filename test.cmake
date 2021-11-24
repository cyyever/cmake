include_guard()
include(CTest)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

include(${CMAKE_CURRENT_LIST_DIR}/code_coverage.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/util.cmake)

set(valgrind_suppression_dir $ENV{HOME}/opt/cli_tool_configs/valgrind_supp)
set(sanitizer_suppression_dir $ENV{HOME}/opt/cli_tool_configs/sanitizer_supp)

option(DISABLE_RUNTIME_ANALYSIS "Disable all runtime analysis" OFF)

function(add_test_with_runtime_analysis)
  set(cpu_analysis_tools MEMCHECK UBSAN HELGRIND ASAN TSAN)
  set(gpu_analysis_tools CUDA-MEMCHECK CUDA-SYNCCHECK CUDA-INITCHECK
                         CUDA-RACECHECK)
  set(oneValueArgs TARGET WITH_CPU_ANALYSIS WITH_GPU_ANALYSIS
                   ${cpu_analysis_tools} ${gpu_analysis_tools})
  cmake_parse_arguments(this "" "${oneValueArgs}" "ARGS" ${ARGN})
  separate_arguments(this_ARGS)

  if("${this_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no target specified")
    return()
  endif()

  if(NOT BUILD_TESTING)
    set_target_properties("${this_TARGET}" PROPERTIES EXCLUDE_FROM_ALL ON)
    return()
  endif()
  if(NOT TARGET "${this_TARGET}")
    message(FATAL_ERROR "${this_TARGET} is not a target")
    return()
  endif()

  if("${this_WITH_CPU_ANALYSIS}" STREQUAL "")
    set(this_WITH_CPU_ANALYSIS TRUE)
  endif()

  if("${this_WITH_GPU_ANALYSIS}" STREQUAL "")
    if(CUDA IN_LIST languages)
      set(this_WITH_GPU_ANALYSIS TRUE)
    else()
      set(this_WITH_GPU_ANALYSIS FALSE)
    endif()
  endif()

  if(DISABLE_RUNTIME_ANALYSIS)
    set(this_WITH_CPU_ANALYSIS FALSE)
    set(this_WITH_GPU_ANALYSIS FALSE)
  endif()

  if(NOT this_WITH_CPU_ANALYSIS)
    foreach(tool IN LISTS cpu_analysis_tools)
      set(this_${tool} FALSE)
    endforeach()
  endif()

  if(NOT this_WITH_GPU_ANALYSIS)
    foreach(tool IN LISTS gpu_analysis_tools)
      set(this_${tool} FALSE)
    endforeach()
  endif()

  find_package(valgrind)
  if(TARGET valgrind::valgrind)
    file(GLOB valgrind_suppression_files ${valgrind_suppression_dir}/*.supp)
    foreach(tool IN ITEMS MEMCHECK HELGRIND)
      if("${this_${tool}}" STREQUAL "")
        set(this_${tool} TRUE)
      endif()
    endforeach()
  else()
    foreach(tool IN ITEMS MEMCHECK HELGRIND)
      set(this_${tool} FALSE)
    endforeach()
  endif()

  find_package(GoogleSanitizer REQUIRED)
  foreach(sanitizer_name IN ITEMS ASAN TSAN UBSAN)
    if(sanitizer_name STREQUAL ASAN)
      set(sanitizer_target GoogleSanitizer::address)
    elseif(sanitizer_name STREQUAL UBSAN)
      set(sanitizer_target GoogleSanitizer::undefined)
    elseif(sanitizer_name STREQUAL TSAN)
      set(sanitizer_target GoogleSanitizer::thread)
    endif()
    if(TARGET ${sanitizer_target})
      if("${this_${sanitizer_name}}" STREQUAL "")
        set(this_${sanitizer_name} TRUE)
      endif()
    else()
      set(this_${sanitizer_name} FALSE)
      message(WARNING "no ${sanitizer_name}")
    endif()
  endforeach()

  if(this_WITH_GPU_ANALYSIS)
    find_package(CUDA-MEMCHECK REQUIRED)
    if(TARGET CUDA-MEMCHECK::cuda-memcheck)
      if("${this_CUDA-MEMCHECK}" STREQUAL "")
        set(this_CUDA-MEMCHECK TRUE)
      endif()
      if("${this_CUDA-SYNCCHECK}" STREQUAL "")
        set(this_CUDA-SYNCCHECK TRUE)
      endif()
      if("${this_CUDA-INITCHECK}" STREQUAL "")
        set(this_CUDA-INITCHECK TRUE)
      endif()
      if("${this_CUDA-RACECHECK}" STREQUAL "")
        set(this_CUDA-RACECHECK TRUE)
      endif()
    else()
      message(WARNING "no cuda-memcheck")
      set(this_CUDA-MEMCHECK FALSE)
      set(this_CUDA-SYNCCHECK FALSE)
      set(this_CUDA-INITCHECK FALSE)
      set(this_CUDA-RACECHECK FALSE)
    endif()
  endif()

  get_target_property(new_env ${this_TARGET} ENVIRONMENT)
  if(ENABLE_LLVM_CODE_COVERAGE)
    list(APPEND new_env
         "LLVM_PROFILE_FILE=${CMAKE_BINARY_DIR}/profraw_dir/%p.profraw")
  endif()
  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    list(
      APPEND
      new_env
      ASAN_OPTIONS=detect_leaks=1:protect_shadow_gap=0:check_initialization_order=true:detect_stack_use_after_return=true:strict_init_order=true:detect_container_overflow=0
    )
  endif()
  if(EXISTS "${sanitizer_suppression_dir}/lsan.supp")
    list(APPEND new_env
         "LSAN_OPTIONS=suppressions=${sanitizer_suppression_dir}/lsan.supp")
  endif()
  set(TSAN_OPTIONS "TSAN_OPTIONS=force_seq_cst_atomics=1:history_size=7")
  if(EXISTS "${sanitizer_suppression_dir}/lsan.supp")
    set(TSAN_OPTIONS "${TSAN_OPTIONS}:suppressions=${sanitizer_suppression_dir}/tsan.supp")
  endif()
  list(APPEND new_env "${TSAN_OPTIONS}")

  set(has_test FALSE)
  foreach(tool IN LISTS cpu_analysis_tools gpu_analysis_tools)
    if(NOT ${this_${tool}})
      continue()
    endif()

    set(has_test TRUE)
    set(new_target ${tool}_${this_TARGET})
    clone_executable(${this_TARGET} ${new_target})
    set(new_target_command $<TARGET_FILE:${new_target}>)

    if(tool STREQUAL ASAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::address)
    elseif(tool STREQUAL UBSAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::undefined)
    elseif(tool STREQUAL TSAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::thread)
    elseif(tool STREQUAL MEMCHECK)
      set(memcheck_command
          $<TARGET_FILE:valgrind::valgrind> --tool=memcheck --error-exitcode=1
          --trace-children=yes --gen-suppressions=all --track-fds=yes
          --leak-check=full)
      foreach(suppression_file ${valgrind_suppression_files})
        set(memcheck_command
            "${memcheck_command} --suppressions=${suppression_file}")
      endforeach()
      separate_arguments(memcheck_command)
      set(new_target_command "${memcheck_command};$<TARGET_FILE:${new_target}>")
    elseif(tool STREQUAL HELGRIND)
      set(helgrind_command
          $<TARGET_FILE:valgrind::valgrind> --tool=helgrind --error-exitcode=1
          --trace-children=yes --gen-suppressions=all)
      foreach(suppression_file ${valgrind_suppression_files})
        set(helgrind_command
            "${helgrind_command} --suppressions=${suppression_file}")
      endforeach()
      separate_arguments(helgrind_command)
      set(new_target_command "${helgrind_command};$<TARGET_FILE:${new_target}>")
    elseif(tool STREQUAL CUDA-MEMCHECK)
      set(memcheck_command
          $<TARGET_FILE:CUDA-MEMCHECK::cuda-memcheck> --tool memcheck
          --leak-check full --error-exitcode 1 --flush-to-disk yes)
      set(new_target_command "${memcheck_command};$<TARGET_FILE:${new_target}>")
    elseif(tool STREQUAL CUDA-SYNCCHECK)
      set(synccheck_command
          $<TARGET_FILE:CUDA-MEMCHECK::cuda-memcheck> --tool synccheck
          --leak-check full --error-exitcode 1 --flush-to-disk yes)
      set(new_target_command
          "${synccheck_command};$<TARGET_FILE:${new_target}>")
    elseif(tool STREQUAL CUDA-INITCHECK)
      set(initcheck_command
          $<TARGET_FILE:CUDA-MEMCHECK::cuda-memcheck> --tool initcheck
          --leak-check full --error-exitcode 1 --flush-to-disk yes)
      set(new_target_command
          "${initcheck_command};$<TARGET_FILE:${new_target}>")
    elseif(tool STREQUAL CUDA-RACECHECK)
      set(racecheck_command
          $<TARGET_FILE:CUDA-MEMCHECK::cuda-memcheck> --tool racecheck
          --leak-check full --error-exitcode 1 --flush-to-disk yes)
      set(new_target_command
          "${racecheck_command};$<TARGET_FILE:${new_target}>")
    endif()
    add_test(NAME ${new_target} COMMAND ${new_target_command} ${this_ARGS})
    set_tests_properties(${new_target} PROPERTIES ENVIRONMENT "${new_env}")
  endforeach()

  if(NOT has_test)
    set(name ${this_TARGET})
    add_test(
      NAME ${name}
      WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}>
      COMMAND $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
    set_tests_properties(${name} PROPERTIES ENVIRONMENT "${new_env}")
  endif()
endfunction()
