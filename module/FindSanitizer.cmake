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
option(MSAN_FLAGS "additional UBSAN flags" OFF)

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
foreach(lang IN LISTS languages)
  if(lang STREQUAL C)
    include(CheckCSourceCompiles)
    include(CheckCSourceRuns)
  elseif(lang STREQUAL CXX)
    include(CheckCXXSourceCompiles)
    include(CheckCXXSourceRuns)
  else()
    continue()
  endif()
  foreach(sanitizer_name IN ITEMS address thread undefined leak memory)
    if(TARGET Sanitizer::${sanitizer_name}_${lang})
      continue()
    endif()
    cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET ON)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
      if(sanitizer_name STREQUAL "address")
        set(SANITIZER_FLAGS "/fsanitize=${sanitizer_name}")
      else()
        cmake_pop_check_state()
        continue()
      endif()
    else()
      set(SANITIZER_FLAGS
          "-fsanitize=${sanitizer_name};-fno-omit-frame-pointer")
    endif()
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "Clang")
      unset(err_var)
      unset(out_var)
      execute_process(
        COMMAND ${CMAKE_${lang}_COMPILER} "--print-file-name"
                "libclang_rt.asan-x86_64.so"
        ERROR_VARIABLE err_var
        OUTPUT_VARIABLE out_var
        OUTPUT_STRIP_TRAILING_WHITESPACE)
      if(NOT err_var AND out_var)
        cmake_path(GET out_var PARENT_PATH asan_dir)
        list(APPEND SANITIZER_FLAGS "-L${asan_dir}")
      endif()
    endif()
    if(sanitizer_name STREQUAL "undefined" AND UBSAN_FLAGS)
      list(APPEND SANITIZER_FLAGS "${UBSAN_FLAGS}")
    endif()
    if(sanitizer_name STREQUAL "memory")
      list(APPEND SANITIZER_FLAGS "-fsanitize-memory-track-origins=2")
      if(MSAN_FLAGS)
        list(APPEND SANITIZER_FLAGS "${MSAN_FLAGS}")
      endif()
    endif()
    string(REPLACE ";" " " CMAKE_REQUIRED_FLAGS "${SANITIZER_FLAGS}")

    set(SANITIZER_LINK_FLAGS)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
      list(APPEND SANITIZER_LINK_FLAGS "/INCREMENTAL:NO")
    else()
      list(APPEND SANITIZER_LINK_FLAGS "-fsanitize=${sanitizer_name}")
    endif()
    set(CMAKE_REQUIRED_LINK_OPTIONS "${SANITIZER_LINK_FLAGS}")

    unset(__res)
    if(lang STREQUAL C)
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
        check_c_source_compiles("${_source_code}" __res)
      else()
        check_c_source_runs("${_source_code}" __res)
      endif()
    else()
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
        check_cxx_source_compiles("${_source_code}" __res)
      else()
        check_cxx_source_runs("${_source_code}" __res)
      endif()
    endif()
    if(NOT __res)
      cmake_pop_check_state()
      continue()
    endif()
    add_library(Sanitizer::${sanitizer_name}_${lang} INTERFACE IMPORTED GLOBAL)
    if(NOT TARGET Sanitizer::${sanitizer_name})
      add_library(Sanitizer::${sanitizer_name} INTERFACE IMPORTED GLOBAL)
    endif()
    target_link_libraries(Sanitizer::${sanitizer_name}
                          INTERFACE Sanitizer::${sanitizer_name}_${lang})
    foreach(SANITIZER_FLAG IN LISTS SANITIZER_FLAGS)
      target_compile_options(
        Sanitizer::${sanitizer_name}_${lang}
        INTERFACE $<$<COMPILE_LANGUAGE:${lang}>:${SANITIZER_FLAG}>)
    endforeach()
    foreach(SANITIZER_FLAG IN LISTS SANITIZER_LINK_FLAGS)
      target_link_options(Sanitizer::${sanitizer_name}_${lang} INTERFACE
                          $<$<COMPILE_LANGUAGE:${lang}>:${SANITIZER_FLAG}>)
    endforeach()

    if(sanitizer_name STREQUAL "address" AND lang STREQUAL CXX)
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
        target_compile_definitions(
          Sanitizer::${sanitizer_name}_${lang}
          INTERFACE $<$<COMPILE_LANGUAGE:${lang}>:_DISABLE_VECTOR_ANNOTATION>
                    $<$<COMPILE_LANGUAGE:${lang}>:_DISABLE_STRING_ANNOTATION>)
      else()
        target_compile_definitions(
          Sanitizer::${sanitizer_name}_${lang}
          INTERFACE
            $<$<COMPILE_LANGUAGE:${lang}>:_GLIBCXX_SANITIZE_VECTOR>
            $<$<COMPILE_LANGUAGE:${lang}>:_GLIBCXX_SANITIZE_STD_ALLOCATOR>)
      endif()
    endif()
    cmake_pop_check_state()
  endforeach()
endforeach()
