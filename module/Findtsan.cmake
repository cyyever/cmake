# - Try to find tsan
#
# The following are set after configuration is done:
#  tsan_FOUND

IF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(tsan_FOUND FALSE)
  return()
endif()

include(CheckCSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=thread")

check_c_source_runs("
#include <stdio.h>
int main() {
printf(\"hello world!\");
 return 0;
}
" tsan_res)

unset(CMAKE_REQUIRED_FLAGS)
unset(CMAKE_REQUIRED_LIBRARIES)
IF(tsan_res STREQUAL "1")
  set(tsan_FOUND TRUE)
else()
  set(tsan_FOUND FALSE)
endif()
