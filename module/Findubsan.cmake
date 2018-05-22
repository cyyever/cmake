# - Try to find ubsan
#
# The following are set after configuration is done:
#  ubsan_FOUND

include(CheckCSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
set(CMAKE_REQUIRED_LIBRARIES "ubsan")

check_c_source_runs("
#include <stdio.h>
int main() {
printf(\"hello world!\");
 return 0;
}
" ubsan_res)

unset(CMAKE_REQUIRED_FLAGS)
unset(CMAKE_REQUIRED_LIBRARIES)
set(ubsan_FOUND (ubsan_res STREQUAL "1"))
