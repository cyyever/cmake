include_guard(GLOBAL)

if(NOT DEFINED ENV{eink_screen})
  return()
endif()

if(NOT $ENV{eink_screen} STREQUAL "1")
  return()
endif()

set(CMAKE_COLOR_MAKEFILE OFF)
set(CMAKE_COLOR_DIAGNOSTICS OFF)
