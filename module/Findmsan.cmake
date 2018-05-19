# - Try to find asan
#
# The following are set after configuration is done:
#  asan_FOUND

include(FindPackageHandleStandardArgs)

IF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(msan_FOUND TRUE)
else()
  set(msan_FOUND FALSE)
endif()
