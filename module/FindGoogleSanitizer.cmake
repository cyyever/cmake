# Find google sanitizers
#
# This module sets the following variables:
#  address_sanitizer_FOUND
#  thread_sanitizer_FOUND
#  undefined_sanitizer_FOUND
#  leak_sanitizer_FOUND
#  GoogleSanitizer::address
#  GoogleSanitizer::thread
#  GoogleSanitizer::undefined
#  GoogleSanitizer::leak
include_guard()
include(FindPackageHandleStandardArgs)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

set(_source_code [==[
  #include <stdio.h>
  int main() {
  printf("hello world!");
  return 0;
  }
  ]==])

foreach(sanitizer_name IN ITEMS address thread undefined leak)
  if(TARGET GoogleSanitizer::${sanitizer_name})
    set(${sanitizer_name}_sanitizer_FOUND TRUE)
    continue()
  endif()

  set(CMAKE_REQUIRED_FLAGS "-fsanitize=${sanitizer_name}")

  set(_c_res)
  set(_cxx_res)
  set(CMAKE_REQUIRED_QUIET ON)
  if("CXX" IN_LIST languages AND NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    include(CheckCXXSourceRuns)
    check_cxx_source_runs("${_source_code}" _cxx_res)
  endif()
  if("C" IN_LIST languages AND NOT CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    include(CheckCSourceRuns)
    check_c_source_runs("${_source_code}" _c_res)
  endif()

  set(_run_res 0)
  if(_c_res OR _cxx_res)
    set(_run_res 1)
  endif()

  find_package_handle_standard_args(${sanitizer_name}_sanitizer DEFAULT_MSG _run_res)
  if(${sanitizer_name}_sanitizer_FOUND)
    add_library(GoogleSanitizer::${sanitizer_name} INTERFACE IMPORTED)
    target_compile_options(GoogleSanitizer::${sanitizer_name}
      INTERFACE
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$_cxx_res>>:${CMAKE_REQUIRED_FLAGS}>
      $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$_c_res>>:${CMAKE_REQUIRED_FLAGS}>
      -fno-omit-frame-pointer
      )
    target_link_options(GoogleSanitizer::${sanitizer_name}
      INTERFACE
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$_cxx_res>>:${CMAKE_REQUIRED_FLAGS}>
      $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$_c_res>>:${CMAKE_REQUIRED_FLAGS}>
      -fno-omit-frame-pointer
      )
  endif()
endforeach()

set(CMAKE_REQUIRED_FLAGS)
unset(_c_res CACHE)
unset(_cxx_res CACHE)
