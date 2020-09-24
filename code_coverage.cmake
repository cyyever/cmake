include_guard(GLOBAL)

if(TARGET generate_code_coverage_report)
  return()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NOT C IN_LIST languages AND NOT CXX IN_LIST languages)
  return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/build_type.cmake)

add_custom_build_type(CODE_COVERAGE)

set(ENABLE_GNU_CODE_COVERAGE FALSE)
set(ENABLE_LLVM_CODE_COVERAGE FALSE)
foreach(lang IN ITEMS C CXX)
  if(lang IN_LIST languages)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "Clang")
      find_package(LLVM QUIET)
      if(NOT LLVM_FOUND)
        return()
      endif()
      set(CMAKE_${lang}_FLAGS_CODE_COVERAGE
          "${CMAKE_${lang}_FLAGS_CODE_COVERAGE} -fprofile-instr-generate -fcoverage-mapping"
          CACHE STRING "" FORCE)
      set(ENABLE_LLVM_CODE_COVERAGE TRUE)
    elseif(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
      find_package(lcov QUIET)
      if(NOT lcov_FOUND)
        return()
      endif()
      set(CMAKE_${lang}_FLAGS_CODE_COVERAGE
          "${CMAKE_${lang}_FLAGS_CODE_COVERAGE} --coverage"
          CACHE STRING "" FORCE)
      add_link_options(
        $<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<CONFIG:CODE_COVERAGE>>:--coverage>
      )
      set(ENABLE_GNU_CODE_COVERAGE TRUE)
    endif()
  endif()
endforeach()

if(NOT ENABLE_GNU_CODE_COVERAGE AND NOT ENABLE_LLVM_CODE_COVERAGE)
  return()
endif()

add_custom_command(
  OUTPUT ${CMAKE_BINARY_DIR}/code_coverage
  COMMAND mkdir -p code_coverage
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

add_custom_target(
  do_test_for_code_coverage
  COMMAND
    ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=code_coverage
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DDISABLE_RUNTIME_ANALYSIS=ON
    ${CMAKE_SOURCE_DIR}
  COMMAND ${CMAKE_COMMAND} --build .
  COMMAND ${CMAKE_CTEST_COMMAND}
  DEPENDS ${CMAKE_BINARY_DIR}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

if(ENABLE_GNU_CODE_COVERAGE)
  add_custom_target(
    generate_code_coverage_report
    COMMAND mkdir -p code_coverage_report
    COMMAND lcov::lcov --capture --include '${CMAKE_SOURCE_DIR}/*' --directory
            .. --output-file coverage.info
    COMMAND lcov::genhtml coverage.info --output-directory
            ./code_coverage_report
    COMMAND rm ./coverage.info
    DEPENDS ${CMAKE_BINARY_DIR}/code_coverage
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/code_coverage
    BYPRODUCTS code_coverage_report)
elseif(ENABLE_LLVM_CODE_COVERAGE)
  add_custom_target(
    generate_code_coverage_report
    COMMAND mkdir -p code_coverage_report
    COMMAND llvm-profdata merge -sparse `find ${CMAKE_BINARY_DIR} -name
            '*.profraw'` -o default.profdata
    COMMAND
      llvm-cov show -instr-profile=default.profdata -format=html
      -output-dir=./code_coverage_report -object `find ${CMAKE_BINARY_DIR} -wholename '*/test/*'
      -executable -type f`
    DEPENDS ${CMAKE_BINARY_DIR}/code_coverage
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/code_coverage
    BYPRODUCTS code_coverage_report)
endif()
add_dependencies(generate_code_coverage_report do_test_for_code_coverage)
