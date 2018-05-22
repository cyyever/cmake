# - Try to find asan
#
# The following are set after configuration is done:
#  asan_FOUND

include(FindPackageHandleStandardArgs)
include(CheckCSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
set(CMAKE_REQUIRED_LIBRARIES "asan")

check_c_source_runs("
#include <stdio.h>
int main() {
printf(\"hello world!\");
 return 0;
}
" resultVar)

set(asan_FOUND (resultVar STREQUAL "1"))
