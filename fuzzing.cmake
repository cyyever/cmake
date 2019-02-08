include_guard()

enable_testing()
include(${CMAKE_CURRENT_LIST_DIR}/util.cmake)

find_package(libFuzzer)
find_package(GoogleSanitizer)

file(GLOB lsan_suppression_file ${CMAKE_CURRENT_LIST_DIR}/sanitizer_supp/lsan.supp)
file(GLOB tsan_suppression_file ${CMAKE_CURRENT_LIST_DIR}/sanitizer_supp/tsan.supp)

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

  if(NOT libFuzzer_FOUND)
    message(WARNING "no libFuzzer found,skip fuzzing")
    return()
  endif()

  if("${this_ASAN}" STREQUAL "")
    set(this_ASAN ${address_sanitizer_FOUND})
  elseif(this_ASAN AND NOT address_sanitizer_FOUND)
    message(WARNING "no asan")
    set(this_ASAN FALSE)
  endif()

  if("${this_TSAN}" STREQUAL "")
    set(this_TSAN FALSE)
  elseif(this_TSAN AND NOT thread_sanitizer_FOUND)
    message(WARNING "no tsan")
    set(this_TSAN FALSE)
  endif()

  if("${this_UBSAN}" STREQUAL "")
    set(this_UBSAN ${undefined_sanitizer_FOUND})
  elseif(this_UBSAN AND NOT undefined_sanitizer_FOUND)
    message(WARNING "no ubsan")
    set(this_UBSAN FALSE)
  endif()

  get_target_property(new_env ${this_TARGET} ENVIRONMENT)
  list(APPEND new_env ASAN_OPTIONS=protect_shadow_gap=0:check_initialization_order=true:detect_stack_use_after_return=true:strict_init_order=true)
  list(APPEND new_env "LSAN_OPTIONS=suppressions=${lsan_suppression_file}")
  list(APPEND new_env "TSAN_OPTIONS=suppressions=${tsan_suppression_file}:force_seq_cst_atomics=1")

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

    set_target_properties(${new_target} PROPERTIES INTERPROCEDURAL_OPTIMIZATION FALSE)

    if(NOT DEFINED $ENV{MAX_FUZZING_TIME})
      set(ENV{MAX_FUZZING_TIME} 60)
    endif()

    if(NOT DEFINED $ENV{FUZZING_JOBS})
      set(ENV{FUZZING_JOBS} 1)
    endif()

    add_test(NAME ${new_target} WORKING_DIRECTORY $<TARGET_FILE_DIR:${new_target}> COMMAND $<TARGET_FILE:${new_target}> -jobs=$ENV{FUZZING_JOBS} -max_total_time=$ENV{MAX_FUZZING_TIME})
    set_tests_properties(${name} PROPERTIES ENVIRONMENT "${new_env}")
  endforeach()
endfunction()
