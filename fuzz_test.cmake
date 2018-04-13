INCLUDE(${CMAKE_CURRENT_LIST_DIR}/compiler.cmake)

IF(CMAKE_CXX_COMPILER_ID NOT STREQUAL "Clang")
  message(WARNING "only clang can use libFuzzer")
  return
endif()

function(add_fuzz_test target)
  target_compile_options(target "-fsanitize=fuzzer")
endfunction(add_fuzz_test)
