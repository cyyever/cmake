# Find sanitizers
#
# This module sets the following targets:
#  Sanitizer::address
#  Sanitizer::thread
#  Sanitizer::undefined
#  Sanitizer::leak
#  Sanitizer::memory
include_guard(GLOBAL)

option(UBSAN_FLAGS "additional UBSAN flags" OFF)

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

set(_source_code
    [==[
  #include <stdio.h>
  int main() {
  printf("hello world!");
  return 0;
  }
  ]==])

include(CMakePushCheckState)
foreach(sanitizer_name IN ITEMS address thread undefined leak memory)
  if(TARGET Sanitizer::${sanitizer_name})
    continue()
  endif()
  cmake_push_check_state(RESET)

  set(CMAKE_REQUIRED_QUIET ON)
  foreach(lang IN LISTS languages)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
      if(sanitizer_name STREQUAL "address")
        set(SANITIZER_FLAGS "/fsanitize=${sanitizer_name}")
      else()
        continue()
      endif()
    else()
      set(SANITIZER_FLAGS
          "-fsanitize=${sanitizer_name};-fno-omit-frame-pointer")
    endif()
    if(sanitizer_name STREQUAL "undefined" AND UBSAN_FLAGS)
      list(APPEND SANITIZER_FLAGS "${UBSAN_FLAGS}")
    endif()
    if(sanitizer_name STREQUAL "memory")
      list(APPEND SANITIZER_FLAGS "-fsanitize-memory-track-origins=2")
    endif()
    string(REPLACE ";" " " CMAKE_REQUIRED_FLAGS "${SANITIZER_FLAGS}")

    set(SANITIZER_LINK_FLAGS)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
      list(APPEND SANITIZER_LINK_FLAGS "/INCREMENTAL:NO")
    else()
      list(APPEND SANITIZER_LINK_FLAGS "-fsanitize=${sanitizer_name}")
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "Clang")
        list(APPEND SANITIZER_LINK_FLAGS "-shared-libasan")
      endif()
    endif()
    set(CMAKE_REQUIRED_LINK_OPTIONS "${SANITIZER_LINK_FLAGS}")

    if(lang STREQUAL C)
      # ASAN is supported only on Release builds
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
        include(CheckCSourceCompiles)
        check_c_source_compiles("${_source_code}" __res)
      else()
        include(CheckCSourceRuns)
        check_c_source_runs("${_source_code}" __res)
      endif()
    elseif(lang STREQUAL CXX)
      # ASAN is supported only on Release builds
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
        include(CheckCXXSourceCompiles)
        check_cxx_source_compiles("${_source_code}" __res)
      else()
        include(CheckCXXSourceRuns)
        check_cxx_source_runs("${_source_code}" __res)
      endif()
    else()
      continue()
    endif()
    if(NOT __res)
      continue()
    endif()
    if(NOT TARGET Sanitizer::${sanitizer_name})
      add_library(Sanitizer::${sanitizer_name} INTERFACE IMPORTED GLOBAL)
    endif()
    foreach(SANITIZER_FLAG IN LISTS SANITIZER_FLAGS)
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
        target_compile_options(
          Sanitizer::${sanitizer_name}
          INTERFACE
            $<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<CONFIG:Release,RelWithDebInfo,MinSizeRel>>:${SANITIZER_FLAG}>
        )
      else()
        target_compile_options(
          Sanitizer::${sanitizer_name}
          INTERFACE $<$<COMPILE_LANGUAGE:${lang}>:${SANITIZER_FLAG}>)
      endif()
    endforeach()
    foreach(SANITIZER_FLAG IN LISTS SANITIZER_LINK_FLAGS)
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
        target_link_options(
          Sanitizer::${sanitizer_name}
          INTERFACE
          $<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<CONFIG:Release,RelWithDebInfo,MinSizeRel>>:${SANITIZER_FLAG}>
        )
      else()
        target_link_options(Sanitizer::${sanitizer_name} INTERFACE
                            $<$<COMPILE_LANGUAGE:${lang}>:${SANITIZER_FLAG}>)
      endif()
    endforeach()

    if(sanitizer_name STREQUAL "address")
      if(lang STREQUAL CXX)
        target_compile_definitions(
          Sanitizer::${sanitizer_name}
          INTERFACE
            $<$<COMPILE_LANGUAGE:${lang}>:_GLIBCXX_SANITIZE_VECTOR>
            $<$<COMPILE_LANGUAGE:${lang}>:_GLIBCXX_SANITIZE_STD_ALLOCATOR>)
      endif()
    endif()
  endforeach()
  cmake_pop_check_state()
endforeach()
