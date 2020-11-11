include_guard()
include(CTest)

include(${CMAKE_CURRENT_LIST_DIR}/code_coverage.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/util.cmake)

set(valgrind_suppression_dir ${CMAKE_CURRENT_LIST_DIR}/valgrind_supp)
set(sanitizer_suppression_dir ${CMAKE_CURRENT_LIST_DIR}/sanitizer_supp)

option(DISABLE_RUNTIME_ANALYSIS "Disable all runtime analysis" OFF)

function(add_test_with_runtime_analysis)
  set(cpu_analysis_tools MEMCHECK UBSAN HELGRIND ASAN TSAN MSAN)
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
    set(this_WITH_GPU_ANALYSIS TRUE)
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
  if(valgrind_FOUND)
    file(GLOB valgrind_suppression_files ${valgrind_suppression_dir}/*.supp)
  endif()

  if("${this_MEMCHECK}" STREQUAL "")
    set(this_MEMCHECK ${valgrind_FOUND})
  elseif(this_MEMCHECK AND NOT valgrind_FOUND)
    message(WARNING "no valgrind")
    set(this_MEMCHECK FALSE)
  endif()

  if("${this_HELGRIND}" STREQUAL "")
    set(this_HELGRIND FALSE)
  elseif(this_HELGRIND AND NOT valgrind_FOUND)
    message(WARNING "no valgrind")
    set(this_HELGRIND FALSE)
  endif()

  find_package(GoogleSanitizer)
  if("${this_ASAN}" STREQUAL "")
    set(this_ASAN ${address_sanitizer_FOUND})
  elseif(this_ASAN AND NOT address_sanitizer_FOUND)
    message(WARNING "no asan")
    set(this_ASAN FALSE)
  endif()

  if("${this_TSAN}" STREQUAL "")
    set(this_TSAN ${thread_sanitizer_FOUND})
  elseif(this_TSAN AND NOT thread_sanitizer_FOUND)
    message(WARNING "no tsan")
    set(this_TSAN FALSE)
  endif()

  if("${this_MSAN}" STREQUAL "")
    # set(this_MSAN ${memory_sanitizer_FOUND})
    set(this_MSAN FALSE)
  elseif(this_MSAN AND NOT memory_sanitizer_FOUND)
    message(WARNING "no msan")
    set(this_MSAN FALSE)
  endif()

  if("${this_UBSAN}" STREQUAL "")
    set(this_UBSAN ${undefined_sanitizer_FOUND})
  elseif(this_UBSAN AND NOT undefined_sanitizer_FOUND)
    message(WARNING "no ubsan")
    set(this_UBSAN FALSE)
  endif()

  find_package(CUDA-MEMCHECK)
  if("${this_CUDA-MEMCHECK}" STREQUAL "")
    set(this_CUDA-MEMCHECK FALSE)
  elseif(this_CUDA-MEMCHECK AND NOT CUDA-MEMCHECK_FOUND)
    message(WARNING "no cuda-memcheck")
    set(this_CUDA-MEMCHECK FALSE)
  endif()

  if("${this_CUDA-SYNCCHECK}" STREQUAL "")
    set(this_CUDA-SYNCCHECK FALSE)
  elseif(this_CUDA-SYNCCHECK AND NOT CUDA-MEMCHECK_FOUND)
    message(WARNING "no cuda-memcheck")
    set(this_CUDA-SYNCCHECK FALSE)
  endif()

  if("${this_CUDA-INITCHECK}" STREQUAL "")
    set(this_CUDA-INITCHECK FALSE)
  elseif(this_CUDA-INITCHECK AND NOT CUDA-MEMCHECK_FOUND)
    message(WARNING "no cuda-memcheck")
    set(this_CUDA-INITCHECK FALSE)
  endif()

  if("${this_CUDA-RACECHECK}" STREQUAL "")
    set(this_CUDA-RACECHECK FALSE)
  elseif(this_CUDA-RACECHECK AND NOT CUDA-MEMCHECK_FOUND)
    message(WARNING "no cuda-memcheck")
    set(this_CUDA-RACECHECK FALSE)
  endif()

  get_target_property(new_env ${this_TARGET} ENVIRONMENT)
  if(ENABLE_LLVM_CODE_COVERAGE)
    list(APPEND new_env
         "LLVM_PROFILE_FILE=${CMAKE_BINARY_DIR}/profraw_dir/%p.profraw")
  endif()
  list(
    APPEND
    new_env
    ASAN_OPTIONS=protect_shadow_gap=0:check_initialization_order=true:detect_stack_use_after_return=true:strict_init_order=true
  )
  list(APPEND new_env
       "LSAN_OPTIONS=suppressions=${sanitizer_suppression_dir}/lsan.supp")
  list(
    APPEND
    new_env
    "TSAN_OPTIONS=suppressions=${sanitizer_suppression_dir}/tsan.supp:force_seq_cst_atomics=1:history_size=7"
  )

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
    elseif(tool STREQUAL MSAN)
      target_link_libraries(${new_target} PRIVATE GoogleSanitizer::memory)
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
