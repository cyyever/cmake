if(NOT DEFINED CMAKE_CXX_STANDARD)
  SET(CMAKE_CXX_STANDARD 17)
endif()

if(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Debug CACHE STRING "Build Type" FORCE)
endif()

IF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  add_compile_options("-Weverything" "-Wno-c++98-compat" "-Wno-c++98-compat-pedantic" "-Wno-weak-vtables" "-Wno-disabled-macro-expansion" "-Wno-reserved-id-macro" "-Wno-global-constructors" "-Wno-exit-time-destructors" -Wno-double-promotion -Wno-padded -ferror-limit=1)
ELSEIF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  add_compile_options("-Wall" "-Wextra" "-Wshadow" "-Wnon-virtual-dtor" "-Wpedantic" "-fmax-errors=1")
ELSEIF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  add_compile_options("/MP" "/utf-8" "/W4" "/wd4514" "/wd4571")
ENDIF()

#fix compiler bug
IF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if (CMAKE_CXX_COMPILER_VERSION MATCHES "^8.*" OR CMAKE_C_COMPILER_VERSION MATCHES "^8.*")
    add_compile_options("-fno-tree-vrp" "-fno-inline" "-fno-tree-fre")
  endif()
endif()
