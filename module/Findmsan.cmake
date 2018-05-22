# - Try to find asan
#
# The following are set after configuration is done:
#  msan_FOUND

include(CheckCSourceRuns)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=memory")

check_c_source_runs("
#include <stdio.h>
int main() {
printf(\"hello world!\");
 return 0;
}
" msan_res)

unset(CMAKE_REQUIRED_FLAGS)
set(msan_FOUND (msan_res STREQUAL "1"))
