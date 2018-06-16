IF(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  message(WARNING "only clang can use libFuzzer")
  return()
endif()

ENABLE_TESTING()

if(NOT TARGET fuzzing)
  ADD_CUSTOM_TARGET(fuzzing ALL COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIGURATION>)
endif()

FIND_PACKAGE(Threads REQUIRED)
FIND_PACKAGE(asan REQUIRED)

function(add_fuzzing)
  set(oneValueArgs TARGET)
  cmake_parse_arguments(this "" "${oneValueArgs}" "" ${ARGN})
  if("${this_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no target specified")
    return()
  endif()

  if(NOT TARGET ${this_TARGET})
    message(FATAL_ERROR "${this_TARGET} is not a target")
    return()
  endif()

  target_compile_options(${this_TARGET} PRIVATE "-fno-omit-frame-pointer")
  target_compile_options(${this_TARGET} PRIVATE "-fsanitize=fuzzer")
  target_compile_options(${this_TARGET} PRIVATE "-fsanitize=address")
  set_target_properties(${this_TARGET} PROPERTIES LINK_FLAGS "-fsanitize=address,fuzzer")
  TARGET_LINK_LIBRARIES(${this_TARGET} PRIVATE Threads::Threads)
  set_target_properties(${this_TARGET} PROPERTIES INTERPROCEDURAL_OPTIMIZATION FALSE)

  if(NOT DEFINED $ENV{MAX_FUZZING_TIME})
    set(ENV{MAX_FUZZING_TIME} 60)
  endif()

  set(name "fuzzing_${this_TARGET}")
  add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND $<TARGET_FILE:${this_TARGET}> -jobs=4 -max_total_time=$ENV{MAX_FUZZING_TIME})
  add_dependencies(fuzzing ${this_TARGET})
endfunction()
