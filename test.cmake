include_guard()
include(CTest)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

include(${CMAKE_CURRENT_LIST_DIR}/code_coverage.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/util.cmake)

set(valgrind_suppression_dir $ENV{HOME}/opt/cli_tool_configs/valgrind_supp)
set(sanitizer_suppression_dir $ENV{HOME}/opt/cli_tool_configs/sanitizer_supp)

option(DISABLE_RUNTIME_ANALYSIS "Disable all runtime analysis" OFF)

function(__add_fuzzing_test target target_command)
  set_target_properties(${target} PROPERTIES INTERPROCEDURAL_OPTIMIZATION FALSE)
  if(NOT DEFINED ENV{MAX_FUZZING_TIME})
    set(ENV{MAX_FUZZING_TIME} 60)
  endif()

  if(NOT DEFINED ENV{FUZZING_TIMEOUT})
    set(ENV{FUZZING_TIMEOUT} 60)
  endif()

  if(NOT DEFINED ENV{FUZZING_JOBS})
    set(ENV{FUZZING_JOBS} 1)
  endif()

  if(NOT DEFINED ENV{FUZZING_RSS_LIMIT})
    set(ENV{FUZZING_RSS_LIMIT} 4096)
  endif()

  if(NOT DEFINED ENV{FUZZING_MAX_LEN})
    set(ENV{FUZZING_MAX_LEN} 4096)
  endif()

  add_custom_target(
    __working_dir_for_${target}
    COMMAND ${CMAKE_COMMAND} -E make_directory fuzz_test/__${target}
    COMMAND
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

  add_test(
    NAME ${target}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/fuzz_test/__${target}
    COMMAND
      ${target_command} -jobs=$ENV{FUZZING_JOBS}
      -max_total_time=$ENV{MAX_FUZZING_TIME} -timeout=$ENV{FUZZING_TIMEOUT}
      -rss_limit_mb=$ENV{FUZZING_RSS_LIMIT} -max_len=$ENV{FUZZING_MAX_LEN})
  add_dependencies(${target} __working_dir_for_${target})
endfunction()
function(__test_impl)
  set(cpu_analysis_tools MEMCHECK UBSAN HELGRIND ASAN TSAN)
  set(gpu_analysis_tools CUDA-MEMCHECK CUDA-SYNCCHECK CUDA-INITCHECK
                         CUDA-RACECHECK)
  set(oneValueArgs TARGET WITH_CPU_ANALYSIS WITH_GPU_ANALYSIS FUZZING
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
  foreach(sanitizer_name IN ITEMS ASAN TSAN UBSAN MSAN)
    if(sanitizer_name STREQUAL ASAN)
      set(sanitizer_target GoogleSanitizer::address)
    elseif(sanitizer_name STREQUAL MSAN)
      set(sanitizer_target GoogleSanitizer::memory)
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
  set(ASAN_OPTIONS
      "ASAN_OPTIONS=check_initialization_order=true:detect_stack_use_after_return=true:strict_init_order=true:detect_container_overflow=0"
  )
  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(ASAN_OPTIONS "${ASAN_OPTIONS}:protect_shadow_gap=0")
  endif()
  list(APPEND new_env "${ASAN_OPTIONS}")
  set(LSAN_OPTIONS "LSAN_OPTIONS=fast_unwind_on_malloc=0")
  if(EXISTS "${sanitizer_suppression_dir}/lsan.supp")
    set(LSAN_OPTIONS
        "${LSAN_OPTIONS}:suppressions=${sanitizer_suppression_dir}/lsan.supp")
  endif()
  set(TSAN_OPTIONS "TSAN_OPTIONS=force_seq_cst_atomics=1:history_size=7:second_deadlock_stack=1")
  if(EXISTS "${sanitizer_suppression_dir}/tsan.supp")
    set(TSAN_OPTIONS
        "${TSAN_OPTIONS}:suppressions=${sanitizer_suppression_dir}/tsan.supp")
  endif()
  list(APPEND new_env "${TSAN_OPTIONS}")

  set(has_test FALSE)
  if(this_FUZZING)
    find_package(libFuzzer REQUIRED)
    target_link_libraries(${this_TARGET} PRIVATE libFuzzer::libFuzzer)
  endif()
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
    elseif(tool STREQUAL MSAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::memory)
      if(EXISTS "${sanitizer_suppression_dir}/msan.supp")
        target_compile_options(
          ${new_target} PRIVATE
          -fsanitize-ignorelist=${sanitizer_suppression_dir}/msan.supp)
        target_link_options(
          ${new_target} PRIVATE
          -fsanitize-ignorelist=${sanitizer_suppression_dir}/msan.supp)
      endif()
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
          --trace-children=yes --gen-suppressions=all --max-threads=5000)
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
    if(this_FUZZING)
      __add_fuzzing_test(${new_target} ${new_target_command})
    else()
      add_test(NAME ${new_target} COMMAND ${new_target_command} ${this_ARGS})
    endif()
    set_tests_properties(${new_target} PROPERTIES ENVIRONMENT "${new_env}")
  endforeach()

  if(NOT has_test)
    if(this_FUZZING)
      __add_fuzzing_test(${this_TARGET} ${this_TARGET})
    else()
      add_test(NAME ${this_TARGET} COMMAND ${this_TARGET} ${this_ARGS})
    endif()
  endif()
endfunction()

function(add_test_with_runtime_analysis)
  __test_impl("${ARGV};FUZZING;OFF")
endfunction()
