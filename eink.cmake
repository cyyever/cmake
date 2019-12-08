include_guard(GLOBAL)

if(NOT DEFINED ENV{eink_screen})
  return()
endif()

if(NOT $ENV{eink_screen} STREQUAL "1")
  return()
endif()

set(CMAKE_COLOR_MAKEFILE OFF)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

if(CXX IN_LIST languages)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-color-diagnostics")
  endif()
endif()

if(C IN_LIST languages)
  if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-color-diagnostics")
  endif()
endif()
