# Find google sanitizers
#
# This module sets the following variables:
#  address_sanitizer_<LANG>_FOUND
#  thread_sanitizer_<LANG>_FOUND
#  undefined_sanitizer_<LANG>_FOUND
#  leak_sanitizer_<LANG>_FOUND

include_guard()

include(CheckCSourceRuns)
include(CheckCXXSourceRuns)

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
set(sanitizers address thread undefined leak)
foreach(sanitizer_name IN LISTS sanitizers)
  foreach(lang IN LISTS languages)
    set(${sanitizer_name}_sanitizer_${lang}_FOUND FALSE)
  endforeach()
endforeach()

function (check_sanitizer sanitizer_name)
  set(CMAKE_REQUIRED_FLAGS "-fsanitize=${sanitizer_name}")
  set(source_code [==[
  #include <stdio.h>
  int main() {
    printf("hello world!");
    return 0;
  }
  ]==])

  set(CMAKE_REQUIRED_QUIET ON)
  foreach(lang IN LISTS languages)
    if(lang STREQUAL "C")
      check_c_source_runs("${source_code}" run_res)
    elseif(lang STREQUAL "CXX")
      check_cxx_source_runs("${source_code}" run_res)
    else()
      continue()
    endif()
    if(run_res)
      set(${sanitizer_name}_sanitizer_${lang}_FOUND TRUE PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

foreach(sanitizer_name IN LISTS sanitizers)
  check_sanitizer(${sanitizer_name})
endforeach()
