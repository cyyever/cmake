# - Try to find asan
#
# The following are set after configuration is done:
#  asan_FOUND

IF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(asan_FOUND FALSE)
  return()
endif()

include(CheckCSourceRuns)
include(CheckCXXSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")

set(source_code "
#include <stdio.h>
int main() {
printf(\"hello world!\");
 return 0;
}
")

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if ("C" IN_LIST languages)
  check_c_source_runs("${source_code}" asan_res)
else()
  check_cxx_source_runs("${source_code}" asan_res)
endif()

unset(CMAKE_REQUIRED_FLAGS)
unset(CMAKE_REQUIRED_LIBRARIES)
IF(asan_res STREQUAL "1")
  set(asan_FOUND TRUE)
else()
  set(asan_FOUND FALSE)
endif()
