# - Try to find tsan
#
# The following are set after configuration is done:
#  tsan_FOUND

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
set(tsan_FOUND (tsan_res STREQUAL "1"))
