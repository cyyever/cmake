include_guard(GLOBAL)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

if(C IN_LIST languages AND NOT DEFINED CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 11)
  set(CMAKE_C_EXTENSIONS OFF)
  set(CMAKE_C_STANDARD_REQUIRED OFF)
endif()

if(CXX IN_LIST languages AND NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_EXTENSIONS OFF)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

if(CUDA IN_LIST languages AND NOT DEFINED CMAKE_CUDA_STANDARD)
  set(CMAKE_CUDA_STANDARD 14)
  set(CMAKE_CUDA_EXTENSIONS OFF)
  set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()

if(CXX IN_LIST languages)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Weverything -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-weak-vtables -Wno-disabled-macro-expansion -Wno-reserved-id-macro -Wno-global-constructors -Wno-exit-time-destructors -Wno-double-promotion -Wno-padded -Wno-gnu-zero-variadic-macro-arguments -ferror-limit=1")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wshadow -Wnon-virtual-dtor -Wpedantic -fmax-errors=1")
    add_compile_definitions($<$<CONFIG:Debug>:_GLIBCXX_DEBUG>)
    add_compile_definitions($<$<CONFIG:Debug>:_GLIBCXX_SANITIZE_VECTOR>)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /utf-8 /W4 /wd4514 /wd4571")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /sdl")
    option(WITH_MSVC_PERMISSIVE "use /permissive- option" ON)
    include(CheckCXXCompilerFlag)
    if(WITH_MSVC_PERMISSIVE)
      check_cxx_compiler_flag(/permissive- have_permissive)
      if(have_permissive)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
      endif()
    endif()
    check_cxx_compiler_flag(/Zc:__cplusplus have_zc__cplusplus)
    if(have_zc__cplusplus)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus")
    endif()
  endif()
endif()

if(C IN_LIST languages)
  if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Weverything -ferror-limit=1")
  elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -fmax-errors=1")
  elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MP /utf-8 /W4")
  endif()
endif()

#fix compiler bug
foreach(lang IN LISTS languages)
  if(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_${lang}_COMPILER_VERSION VERSION_EQUAL 8.1 OR CMAKE_${lang}_COMPILER_VERSION VERSION_EQUAL 8.0)
      list(APPEND CMAKE_${lang}_FLAGS -fno-tree-vrp -fno-inline -fno-tree-fre)
    endif()
  endif()
endforeach()
