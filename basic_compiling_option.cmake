include_guard(GLOBAL)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

if(C IN_LIST languages AND NOT DEFINED CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 11)
  set(CMAKE_C_STANDARD_REQUIRED OFF)
endif()

if(NOT DEFINED CMAKE_C_EXTENSIONS)
  set(CMAKE_C_EXTENSIONS OFF)
endif()

if(CXX IN_LIST languages AND NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 20)
  if(CMAKE_CXX_STANDARD LESS 17)
    message(FATAL_ERROR "only C++17 or above is supported")
  endif()
endif()

if(NOT DEFINED CMAKE_CXX_EXTENSIONS)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()

if(CUDA IN_LIST languages AND NOT DEFINED CMAKE_CUDA_STANDARD)
  set(CMAKE_CUDA_STANDARD 14)
  set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()

if(NOT DEFINED CMAKE_CUDA_EXTENSIONS)
  set(CMAKE_CUDA_EXTENSIONS OFF)
endif()

# add common options
foreach(lang IN LISTS languages)
  if(CMAKE_${lang}_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_${lang}_FLAGS
        "${CMAKE_${lang}_FLAGS} -Weverything -ferror-limit=1")
  elseif(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_${lang}_FLAGS
        "${CMAKE_${lang}_FLAGS} -Wall -Wextra -fmax-errors=1")
    if(CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 10)
      option(ANALYSIS_ON_COMPILATION "analysis on compilation" ON)
      if(ANALYSIS_ON_COMPILATION)
        set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fanalyzer")
      endif()
    endif()
  elseif(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} /MP /utf-8 /W4")
  endif()
endforeach()

if(CXX IN_LIST languages)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -Wno-unknown-cuda-version -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-weak-vtables -Wno-disabled-macro-expansion -Wno-reserved-id-macro -Wno-global-constructors -Wno-exit-time-destructors -Wno-double-promotion -Wno-padded -Wno-gnu-zero-variadic-macro-arguments -Wno-ctad-maybe-unsupported -Wno-return-std-move-in-c++11"
    )
    add_compile_definitions($<$<CONFIG:Debug>:_LIBCPP_DEBUG=1>)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -Wshadow -Wnon-virtual-dtor -Wpedantic")
    option(USE_GLIBCXX_DEBUG "use glibcxx debug" ON)
    if(USE_GLIBCXX_DEBUG)
      add_compile_definitions($<$<CONFIG:Debug>:_GLIBCXX_DEBUG>)
    endif()
    add_compile_definitions($<$<CONFIG:Debug>:_GLIBCXX_SANITIZE_VECTOR>)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4514 /wd4571")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /sdl")
    option(WITH_MSVC_PERMISSIVE "use /permissive- option" ON)
    if(WITH_MSVC_PERMISSIVE)
      if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 19.24)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
      endif()
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 19.24)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus")
    endif()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 19.26)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:preprocessor")
    endif()
  endif()
endif()

# fix compiler bug
foreach(lang IN LISTS languages)
  if(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_${lang}_COMPILER_VERSION VERSION_EQUAL 8.1
       OR CMAKE_${lang}_COMPILER_VERSION VERSION_EQUAL 8.0)
      list(APPEND CMAKE_${lang}_FLAGS -fno-tree-vrp -fno-inline -fno-tree-fre)
    endif()
  endif()
endforeach()
