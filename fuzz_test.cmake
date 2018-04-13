INCLUDE(${CMAKE_CURRENT_LIST_DIR}/compiler.cmake)

IF(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  message(WARNING "only clang can use libFuzzer")
  return()
endif()

FIND_PACKAGE(Threads REQUIRED)

function(add_fuzz_test target)
  target_compile_options(${target} PRIVATE "-fsanitize=fuzzer")
  set_target_properties(${target} PROPERTIES LINK_FLAGS "-fsanitize=address")
  TARGET_LINK_LIBRARIES(${target} PRIVATE Threads::Threads)
  TARGET_LINK_LIBRARIES(${target} PRIVATE /usr/lib/llvm-7/lib/libFuzzer.a)
endfunction(add_fuzz_test)
