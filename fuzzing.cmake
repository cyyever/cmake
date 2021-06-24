include_guard()
include(CTest)

include(${CMAKE_CURRENT_LIST_DIR}/util.cmake)
set(sanitizer_suppression_dir ${CMAKE_CURRENT_LIST_DIR}/sanitizer_supp)

function(add_fuzzing)
  set(cpu_analysis_tools UBSAN ASAN TSAN)
  set(oneValueArgs TARGET ${cpu_analysis_tools})
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

  get_target_property(new_env ${this_TARGET} ENVIRONMENT)
  list(
    APPEND
    new_env
    ASAN_OPTIONS=protect_shadow_gap=0:check_initialization_order=true:detect_stack_use_after_return=true:strict_init_order=true:replace_intrin=0:fast_unwind_on_malloc=0:detect_container_overflow=0
  )
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
  foreach(tool IN LISTS cpu_analysis_tools)
    if(NOT ${this_${tool}})
      continue()
    endif()

    set(new_target "fuzzing_${tool}_${this_TARGET}")
    clone_executable(${this_TARGET} ${new_target})

    if(tool STREQUAL ASAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::address)
    elseif(tool STREQUAL UBSAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::undefined)
    elseif(tool STREQUAL TSAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::thread)
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

    add_test(
      NAME ${new_target}
      WORKING_DIRECTORY $<TARGET_FILE_DIR:${new_target}>
      COMMAND
        $<TARGET_FILE:${new_target}> -jobs=$ENV{FUZZING_JOBS}
        -max_total_time=$ENV{MAX_FUZZING_TIME} -timeout=$ENV{FUZZING_TIMEOUT}
        -rss_limit_mb=$ENV{FUZZING_RSS_LIMIT})
    set_tests_properties(${name} PROPERTIES ENVIRONMENT "${new_env}")
  endforeach()
endfunction()
