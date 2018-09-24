# - Try to find asan
#
# The following are set after configuration is done:
#  asan_FOUND

IF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(asan_FOUND FALSE)
  return()
endif()

include(CheckCSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")

check_c_source_runs("
#include <stdio.h>
int main() {
printf(\"hello world!\");
 return 0;
}
" asan_res)

unset(CMAKE_REQUIRED_FLAGS)
unset(CMAKE_REQUIRED_LIBRARIES)
IF(asan_res STREQUAL "1")
  set(asan_FOUND TRUE)
else()
  set(asan_FOUND FALSE)
endif()
