INCLUDE(${CMAKE_CURRENT_LIST_DIR}/compiler.cmake)

IF(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  message(WARNING "only clang can use libFuzzer")
  return()
endif()

ENABLE_TESTING()

if(NOT TARGET fuzz_test)
  ADD_CUSTOM_TARGET(fuzz_test ALL COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIGURATION>)
endif()

FIND_PACKAGE(Threads REQUIRED)

function(add_fuzzing)
  set(oneValueArgs TARGET)
  cmake_parse_arguments(this "" "${oneValueArgs}" "" ${ARGN})
  if("${this_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no target specified")
    return()
  endif()

  target_compile_options(${this_TARGET} PRIVATE "-fsanitize=fuzzer")
  target_compile_options(${this_TARGET} PRIVATE "-fsanitize=address")
  set_target_properties(${this_TARGET} PROPERTIES LINK_FLAGS "-fsanitize=address,fuzzer")
  TARGET_LINK_LIBRARIES(${this_TARGET} PRIVATE Threads::Threads)
  set_target_properties(${this_TARGET} PROPERTIES INTERPROCEDURAL_OPTIMIZATION FALSE)

  set(name "fuzzing_${this_TARGET}")
  add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND $<TARGET_FILE:${this_TARGET}> -jobs=4 -max_total_time=60)
endfunction()
