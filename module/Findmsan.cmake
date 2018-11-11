# - Try to find asan
#
# The following are set after configuration is done:
#  msan_FOUND

IF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(msan_FOUND FALSE)
  return()
endif()

include(CheckCSourceRuns)
include(CheckCXXSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=memory")

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
  set(msan_FOUND TRUE)
else()
  set(msan_FOUND FALSE)
endif()
