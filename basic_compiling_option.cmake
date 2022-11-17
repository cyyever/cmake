include_guard(GLOBAL)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

if(NOT DEFINED CMAKE_COLOR_DIAGNOSTICS)
  set(CMAKE_COLOR_DIAGNOSTICS ON)
endif()

if(C IN_LIST languages AND NOT DEFINED CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 11)
  set(CMAKE_C_STANDARD_REQUIRED OFF)
endif()

if(NOT DEFINED CMAKE_C_EXTENSIONS)
  set(CMAKE_C_EXTENSIONS OFF)
endif()

if(CXX IN_LIST languages AND NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 23)
  if(CMAKE_CXX_STANDARD LESS 17)
    message(FATAL_ERROR "only C++17 or above is supported")
  endif()
endif()

if(NOT DEFINED CMAKE_CXX_EXTENSIONS)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()

if(CUDA IN_LIST languages AND NOT DEFINED CMAKE_CUDA_STANDARD)
  set(CMAKE_CUDA_STANDARD 17)
  set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()

if(NOT DEFINED CMAKE_CUDA_EXTENSIONS)
  set(CMAKE_CUDA_EXTENSIONS OFF)
endif()

option(DEBUG_VECTORIZATION "debug vectorization failures" OFF)
# add common options
foreach(lang IN LISTS languages)
  set(c_family "C;CXX")
  if(NOT lang IN_LIST c_family)
    continue()
  endif()
  if(CMAKE_${lang}_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_${lang}_FLAGS
        "${CMAKE_${lang}_FLAGS} -Weverything -ferror-limit=1")

    if(DEBUG_VECTORIZATION)
      set(CMAKE_${lang}_FLAGS
          "${CMAKE_${lang}_FLAGS} -Rpass-analysis=loop-vectorize -Rpass-missed=loop-vectorize -Rpass=loop-vectorize"
      )
    endif()

  elseif(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_${lang}_FLAGS
        "${CMAKE_${lang}_FLAGS} -Wall -Wextra -fmax-errors=1")
    if(CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 10)
      option(ANALYSIS_ON_COMPILATION "analysis on compilation" OFF)
      if(ANALYSIS_ON_COMPILATION)
        set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fanalyzer")
      endif()
    endif()
    if(DEBUG_VECTORIZATION)
      set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fopt-info-vec-missed")
    endif()
  elseif(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_${lang}_FLAGS
        "${CMAKE_${lang}_FLAGS} /MP /utf-8 /W4 /nologo /wd5072")
  endif()
endforeach()

if(CXX IN_LIST languages)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -Wno-unknown-cuda-version -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-weak-vtables -Wno-disabled-macro-expansion -Wno-reserved-id-macro -Wno-global-constructors -Wno-exit-time-destructors -Wno-double-promotion -Wno-padded -Wno-gnu-zero-variadic-macro-arguments -Wno-ctad-maybe-unsupported -Wno-reserved-identifier -Wno-c++20-compat"
    )
    # add_compile_definitions($<$<CONFIG:Debug>:_LIBCPP_DEBUG=1>)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -Wshadow -Wnon-virtual-dtor -Wpedantic")
    option(USE_GLIBCXX_DEBUG "use glibcxx debug" OFF)
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
    add_compile_definitions($<$<CONFIG:Debug>:_CRT_SECURE_NO_WARNINGS>)
  endif()
endif()

if(CUDA IN_LIST languages)
  set(CMAKE_CUDA_FLAGS
      "${CMAKE_CUDA_FLAGS} --expt-relaxed-constexpr --extended-lambda")
endif()
