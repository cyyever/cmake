include_guard()
include(CTest)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

include(${CMAKE_CURRENT_LIST_DIR}/util.cmake)
set(sanitizer_suppression_dir $ENV{HOME}/opt/cli_tool_configs/sanitizer_supp)

function(add_fuzzing)
  set(cpu_analysis_tools UBSAN ASAN TSAN LSAN)
  set(gpu_analysis_tools CUDA-MEMCHECK CUDA-SYNCCHECK CUDA-INITCHECK
                         CUDA-RACECHECK)
  set(oneValueArgs TARGET WITH_GPU_ANALYSIS ${cpu_analysis_tools}
                   ${gpu_analysis_tools})
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
  if(NOT BUILD_TESTING)
    set_target_properties("${this_TARGET}" PROPERTIES EXCLUDE_FROM_ALL ON)
    return()
  endif()
  if("${this_WITH_GPU_ANALYSIS}" STREQUAL "")
    if(CUDA IN_LIST languages)
      set(this_WITH_GPU_ANALYSIS TRUE)
    else()
      set(this_WITH_GPU_ANALYSIS FALSE)
    endif()
  endif()
  if(NOT this_WITH_GPU_ANALYSIS)
    foreach(tool IN LISTS gpu_analysis_tools)
      set(this_${tool} FALSE)
    endforeach()
  endif()

  find_package(libFuzzer REQUIRED)
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
  if(NOT CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
    list(
      APPEND
      new_env
      ASAN_OPTIONS=protect_shadow_gap=0:check_initialization_order=true:detect_stack_use_after_return=true:strict_init_order=true:replace_intrin=0:fast_unwind_on_malloc=0:detect_container_overflow=0
    )
  endif()
  list(
    APPEND
    new_env
    "LSAN_OPTIONS=suppressions=${sanitizer_suppression_dir}/lsan.supp:fast_unwind_on_malloc=0"
  )
  list(
    APPEND
    new_env
    "TSAN_OPTIONS=suppressions=${sanitizer_suppression_dir}/tsan.supp:force_seq_cst_atomics=1"
  )

  target_link_libraries(${this_TARGET} PRIVATE libFuzzer::libFuzzer)
  foreach(tool IN LISTS cpu_analysis_tools gpu_analysis_tools)
    if(NOT ${this_${tool}})
      continue()
    endif()

    set(new_target "fuzzing_${tool}_${this_TARGET}")
    clone_executable(${this_TARGET} ${new_target})
    set(new_target_command $<TARGET_FILE:${new_target}>)

    if(tool STREQUAL ASAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::address)
    elseif(tool STREQUAL UBSAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::undefined)
    elseif(tool STREQUAL TSAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::thread)
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

    set_target_properties(${new_target} PROPERTIES INTERPROCEDURAL_OPTIMIZATION
                                                   FALSE)

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

    add_test(
      NAME ${new_target}
      WORKING_DIRECTORY $<TARGET_FILE_DIR:${new_target}>
      COMMAND
        ${new_target_command} -jobs=$ENV{FUZZING_JOBS}
        -max_total_time=$ENV{MAX_FUZZING_TIME} -timeout=$ENV{FUZZING_TIMEOUT}
        -rss_limit_mb=$ENV{FUZZING_RSS_LIMIT} -max_len=$ENV{FUZZING_MAX_LEN})
    set_tests_properties(${name} PROPERTIES ENVIRONMENT "${new_env}")
  endforeach()
endfunction()
