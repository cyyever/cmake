include_guard(GLOBAL)
include(${CMAKE_CURRENT_LIST_DIR}/build_type.cmake)

add_custom_build_type(CODE_COVERAGE)

set(ENABLE_GNU_CODE_COVERAGE FALSE)
set(ENABLE_LLVM_CODE_COVERAGE FALSE)

set(CMAKE_C_FLAGS_CODE_COVERAGE "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_CODE_COVERAGE "${CMAKE_CXX_FLAGS_DEBUG}" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS_CODE_COVERAGE "${CMAKE_EXE_LINKER_FLAGS_DEBUG}" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS_CODE_COVERAGE "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE STRING "")
set(CMAKE_STATIC_LINKER_FLAGS_CODE_COVERAGE "${CMAKE_STATIC_LINKER_FLAGS_DEBUG}" CACHE STRING "")
set(CMAKE_MODULE_LINKER_FLAGS_CODE_COVERAGE "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}" CACHE STRING "")

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

foreach(lang IN ITEMS C CXX)
  if(lang IN_LIST languages)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "Clang")
      set(CMAKE_${lang}_FLAGS_CODE_COVERAGE "${CMAKE_${lang}_FLAGS_CODE_COVERAGE} -fprofile-instr-generate -fcoverage-mapping" CACHE STRING "" FORCE)
      set(ENABLE_LLVM_CODE_COVERAGE TRUE)
    elseif(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
      set(CMAKE_${lang}_FLAGS_CODE_COVERAGE "${CMAKE_${lang}_FLAGS_CODE_COVERAGE} --coverage" CACHE STRING "" FORCE)
      add_link_options($<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<CONFIG:CODE_COVERAGE>>:--coverage>)
      set(ENABLE_GNU_CODE_COVERAGE TRUE)
    endif()
  endif()
endforeach()


if(NOT TARGET generate_code_coverage_report)
  if(ENABLE_GNU_CODE_COVERAGE)
    find_package(lcov QUIET)
    if(lcov_FOUND)
      add_custom_target(generate_code_coverage_report
	COMMAND mkdir -p code_coverage_report
	COMMAND lcov::lcov --capture --directory . --output-file coverage.info
	COMMAND lcov::genhtml coverage.info --output-directory ./code_coverage_report
	COMMAND rm ./coverage.info
	BYPRODUCTS code_coverage_report
	)
    endif()
  elseif(ENABLE_LLVM_CODE_COVERAGE)
    add_custom_target(generate_code_coverage_report
      COMMAND llvm-profdata merge -sparse `find -name '*.profraw'` -o default.profdata
      COMMAND llvm-cov show -instr-profile=`find -name default.profdata` -format=html -output-dir=./code_coverage `find . -name '*.so'` `find . -executable -type f`
      COMMAND rm `find -name '*.profraw'`
      COMMAND rm default.profdata
      BYPRODUCTS code_coverage_report
      )
  endif()
endif()
