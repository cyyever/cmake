# Find google sanitizers
#
# This module sets the following variables:
#  address_sanitizer_FOUND
#  thread_sanitizer_FOUND
#  undefined_sanitizer_FOUND
#  leak_sanitizer_FOUND
include_guard()
include(FindPackageHandleStandardArgs)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if("C" IN_LIST languages)
  include(CheckCSourceRuns)
elseif("CXX" IN_LIST languages)
  include(CheckCXXSourceRuns)
else()
  message(FATAL_ERROR "FindGoogleSanitizer only works if either C or CXX language is enabled")
endif()

function (check_sanitizer sanitizer_name sanitizer_run_res)
  set(CMAKE_REQUIRED_FLAGS "-fsanitize=${sanitizer_name}")
  set(source_code [==[
    #include <stdio.h>
    int main() {
    printf("hello world!");
    return 0;
    }
    ]==])

  set(CMAKE_REQUIRED_QUIET ON)
  if("C" IN_LIST languages)
    check_c_source_runs("${source_code}" ${sanitizer_run_res})
  elseif("CXX" IN_LIST languages)
    check_cxx_source_runs("${source_code}" ${sanitizer_run_res})
  endif()
endfunction()

set(sanitizers address thread undefined leak)
foreach(sanitizer_name IN LISTS sanitizers)
  check_sanitizer(${sanitizer_name} run_res)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(${sanitizer_name}_sanitizer DEFAULT_MSG run_res)
  if(${sanitizer_name}_sanitizer)
    add_library(GoogleSanitizer::${sanitizer_name} INTERFACE IMPORTED)
    set_property(TARGET GoogleSanitizer::${sanitizer_name}
      PROPERTY INTERFACE_LINK_LIBRARIES 
      $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=${sanitizer_name}>
      $<$<COMPILE_LANGUAGE:C>:-fsanitize=${sanitizer_name}>
      )
  endif()
endforeach()
