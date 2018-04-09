SET(CMAKE_CXX_STANDARD 17)

if(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Debug CACHE STRING "Build Type" FORCE)
endif()

IF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  add_compile_options("-Weverything" "-Wno-c++98-compat" "-Wno-zero-as-null-pointer-constant" "-Wno-c++98-compat-pedantic" "-Wno-padded" "-Wno-double-promotion" "-Wno-weak-vtables" "-Wno-disabled-macro-expansion" "-Wno-reserved-id-macro" "-Wno-global-constructors" "-Wno-exit-time-destructors")
ELSEIF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  add_compile_options("-Wall" "-Wextra" "-Wshadow" "-Wnon-virtual-dtor" "-pedantic")
ELSEIF(MSVC)
  add_compile_options("/MP" "/utf-8" "/W4" "/Ox")
ENDIF()
