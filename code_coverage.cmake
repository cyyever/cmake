include_guard(GLOBAL)

if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()
if(TARGET generate_code_coverage_report)
  return()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
include(${CMAKE_CURRENT_LIST_DIR}/build_type.cmake)

add_custom_build_type_like(coverage debug)
set(CMAKE_EXE_LINKER_FLAGS_COVERAGE
    "${CMAKE_EXE_LINKER_FLAGS_COVERAGE} --coverage")
set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE
    "${CMAKE_SHARED_LINKER_FLAGS_COVERAGE} --coverage")
set(CMAKE_MODULE_LINKER_FLAGS_COVERAGE
    "${CMAKE_MODULE_LINKER_FLAGS_COVERAGE} --coverage")
foreach(lang IN ITEMS C CXX)
  if(CMAKE_${lang}_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_${lang}_FLAGS_COVERAGE
        "${CMAKE_${lang}_FLAGS_COVERAGE} -g -O0 --coverage")
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
      string(APPEND CMAKE_${lang}_FLAGS_COVERAGE
             "${CMAKE_${lang}_FLAGS_COVERAGE} -fprofile-abs-path")
    endif()
  endif()
endforeach()

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
  COMMAND ${CMAKE_CTEST_COMMAND} -T Test
  DEPENDS ${CMAKE_BINARY_DIR}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

set(gcov-executable "")
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(gcov-executable "--gcov-executable  'llvm-cov gcov'")
endif()
add_custom_target(
  generate_code_coverage_report
  COMMAND gcovr --root ${CMAKE_SOURCE_DIR} "${gcov-executable}" --html-details
          code_coverage_report.html
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  BYPRODUCTS code_coverage_report)

add_dependencies(generate_code_coverage_report do_test_for_code_coverage)
