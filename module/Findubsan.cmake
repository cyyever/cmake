# - Try to find ubsan
#
# The following are set after configuration is done:
#  ubsan_FOUND

IF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(ubsan_FOUND FALSE)
  return()
endif()

include(CheckCSourceRuns)
include(CheckCXXSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
set(CMAKE_REQUIRED_LIBRARIES "ubsan")

set(source_code "
#include <stdio.h>
int main() {
printf(\"hello world!\");
 return 0;
}
")

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
if ("C" IN_LIST languages)
  check_c_source_runs("${source_code}" run_res)
else()
  check_cxx_source_runs("${source_code}" run_res)
endif()

unset(CMAKE_REQUIRED_FLAGS)
unset(CMAKE_REQUIRED_LIBRARIES)
IF(run_res STREQUAL "1")
  set(ubsan_FOUND TRUE)
else()
  set(ubsan_FOUND FALSE)
endif()
