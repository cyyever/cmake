# Find libFuzzer
#
# This module sets the following variables:
#  libFuzzer::libFuzzer
include_guard(GLOBAL)
if(TARGET libFuzzer::libFuzzer)
  return()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

include(CMakePushCheckState)

set(_source_code
    [==[
  #include <stdint.h>
  #include <stddef.h>
  extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  return 0;  // Non-zero return values are reserved for future use.
  }
  ]==])

foreach(lang IN LISTS languages)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET ON)
  if(lang STREQUAL CXX OR lang STREQUAL C)
    include(CheckSourceCompiles)
    set(_fuzzer_${lang}_res 0)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
      set(CMAKE_TRY_COMPILE_CONFIGURATION "Release")
      set(CMAKE_REQUIRED_FLAGS "/fsanitize=fuzzer")
    else()
      set(CMAKE_REQUIRED_FLAGS "-fsanitize=fuzzer")
    endif()
    check_source_compiles(${lang} "${_source_code}" _fuzzer_${lang}_res)
    if(_fuzzer_${lang}_res)
      if(NOT TARGET libFuzzer::libFuzzer)
        add_library(libFuzzer::libFuzzer INTERFACE IMPORTED GLOBAL)
      endif()
      target_compile_options(
        libFuzzer::libFuzzer
        INTERFACE
          $<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<BOOL:${_fuzzer_${lang}_res}>>:${CMAKE_REQUIRED_FLAGS}>
      )
      if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
        target_link_options(
          libFuzzer::libFuzzer
          INTERFACE
          $<$<AND:$<COMPILE_LANGUAGE:${lang}>,$<BOOL:${_fuzzer_${lang}_res}>>:${CMAKE_REQUIRED_FLAGS}>
        )
      endif()
    endif()
  endif()
  cmake_pop_check_state()
endforeach()
