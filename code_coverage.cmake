include_guard(GLOBAL)

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
      set(CMAKE_${lang}_FLAGS_CODE_COVERAGE
          "${CMAKE_${lang}_FLAGS_CODE_COVERAGE} -fprofile-instr-generate -fcoverage-mapping"
          CACHE STRING "" FORCE)
      set(ENABLE_LLVM_CODE_COVERAGE TRUE)
    elseif(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
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

if(NOT TARGET generate_code_coverage_report)
  if(ENABLE_GNU_CODE_COVERAGE)
    find_package(lcov QUIET)
    if(lcov_FOUND)
      add_custom_target(
        generate_code_coverage_report
        COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=code_coverage
                ${CMAKE_SOURCE_DIR}
        COMMAND ${CMAKE_COMMAND} --build .
        COMMAND ${CMAKE_CTEST_COMMAND}
        COMMAND mkdir -p code_coverage_report
        COMMAND lcov::lcov --capture --directory . --output-file coverage.info
        COMMAND lcov::genhtml coverage.info --output-directory
                ./code_coverage_report
        COMMAND rm ./coverage.info
        WORKING_DIRECTORY
          ${CMAKE_BINARY_DIR}
          BYPRODUCTS
          code_coverage_report)
    endif()
  elseif(ENABLE_LLVM_CODE_COVERAGE)
    find_package(LLVM QUIET)
    if(LLVM_FOUND)
      add_custom_target(
        generate_code_coverage_report
        COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=code_coverage
                ${CMAKE_SOURCE_DIR}
        COMMAND ${CMAKE_COMMAND} --build .
        COMMAND ${CMAKE_CTEST_COMMAND}
        COMMAND
          llvm-profdata merge -sparse `find -name '*.profraw'` -o
          default.profdata
        COMMAND
          llvm-cov show -instr-profile=default.profdata -format=html
          -output-dir=./code_coverage_report -object `find ./test -executable
          -type f`
        WORKING_DIRECTORY
          ${CMAKE_BINARY_DIR}
          BYPRODUCTS
          code_coverage_report)
    endif()
  endif()
endif()
