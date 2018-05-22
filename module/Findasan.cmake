# - Try to find asan
#
# The following are set after configuration is done:
#  asan_FOUND

include(CheckCSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
set(CMAKE_REQUIRED_LIBRARIES "asan")

check_c_source_runs("
#include <stdio.h>
int main() {
printf(\"hello world!\");
 return 0;
}
" asan_res)

unset(CMAKE_REQUIRED_FLAGS)
unset(CMAKE_REQUIRED_LIBRARIES)
set(asan_FOUND (asan_res STREQUAL "1"))
