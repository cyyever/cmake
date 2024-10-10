include_guard(GLOBAL)

if(TARGET generate_code_coverage_report)
  return()
endif()
include(${CMAKE_CURRENT_LIST_DIR}/build_type.cmake)

if(PROJECT_IS_TOP_LEVEL AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  add_custom_build_type(coverage)
  set(CMAKE_CXX_FLAGS_COVERAGE "-g -O0 --coverage")
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    string(APPEND CMAKE_CXX_FLAGS_COVERAGE " -fprofile-abs-path")
  endif()
  set(CMAKE_EXE_LINKER_FLAGS_COVERAGE "--coverage")
  set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE "--coverage")
  set(CMAKE_MODULE_LINKER_FLAGS_COVERAGE "--coverage")
endif()

add_custom_command(
  OUTPUT ${CMAKE_BINARY_DIR}/code_coverage
  COMMAND mkdir -p code_coverage
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

add_custom_target(
  do_test_for_code_coverage
  COMMAND
    ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=coverage
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DDISABLE_RUNTIME_ANALYSIS=ON
    -DCMAKE_BUILD_PARALLEL_LEVEL=${CMAKE_BUILD_PARALLEL_LEVEL}
    ${CMAKE_SOURCE_DIR}
  COMMAND ${CMAKE_COMMAND} --build .
  COMMAND ${CMAKE_CTEST_COMMAND} -C coverage
  DEPENDS ${CMAKE_BINARY_DIR}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

add_custom_target(
  generate_code_coverage_report
  COMMAND mkdir -p code_coverage_report
  COMMAND gcovr --root ${CMAKE_SOURCE_DIR} --html-details code_coverage_report/html -j
          10 ${CMAKE_BINARY_DIR}
  DEPENDS ${CMAKE_BINARY_DIR}/code_coverage
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  BYPRODUCTS code_coverage_report)
add_dependencies(generate_code_coverage_report do_test_for_code_coverage)
