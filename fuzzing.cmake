include_guard()
include(${CMAKE_CURRENT_LIST_DIR}/test.cmake)

function(add_fuzzing)
  __test_impl("${ARGV};FUZZING;ON;MEMCHECK;OFF;HELGRIND;OFF")

endfunction()
