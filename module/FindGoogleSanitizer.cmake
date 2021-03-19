# Find google sanitizers
#
# This module sets the following targets:
#  GoogleSanitizer::address
#  GoogleSanitizer::thread
#  GoogleSanitizer::undefined
#  GoogleSanitizer::leak
#  GoogleSanitizer::memory
include_guard(GLOBAL)
include(FindPackageHandleStandardArgs)

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
cmake_push_check_state(RESET)
foreach(sanitizer_name IN ITEMS address thread undefined leak memory)
  if(TARGET GoogleSanitizer::${sanitizer_name})
    continue()
  endif()

  set(CMAKE_REQUIRED_FLAGS
      "-fsanitize=${sanitizer_name} -fno-omit-frame-pointer")
  if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_C_COMPILER_ID STREQUAL
                                              "MSVC")
    if(sanitizer_name STREQUAL "address")
      set(CMAKE_REQUIRED_FLAGS "/fsanitize=${sanitizer_name}")
    else()
      continue()
    endif()
  endif()

  set(CMAKE_REQUIRED_QUIET ON)
  set(_run_res 0)
  if("CXX" IN_LIST languages)
    include(CheckCXXSourceRuns)
    check_cxx_source_runs("${_source_code}" __cxx_${sanitizer_name}_res)
    if(__cxx_${sanitizer_name}_res)
      set(_run_res 1)
    endif()
  endif()
  if("C" IN_LIST languages)
    include(CheckCSourceRuns)
    check_c_source_runs("${_source_code}" __c_${sanitizer_name}_res)
    if(__c_${sanitizer_name}_res)
      set(_run_res 1)
    endif()
  endif()

  set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS ON)
  find_package_handle_standard_args(${sanitizer_name}_sanitizer DEFAULT_MSG
                                    _run_res)
  if(${sanitizer_name}_sanitizer_FOUND)
    add_library(GoogleSanitizer::${sanitizer_name} INTERFACE IMPORTED GLOBAL)
    target_compile_options(
      GoogleSanitizer::${sanitizer_name}
      INTERFACE
        $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$__cxx_${sanitizer_name}_res>>:${CMAKE_REQUIRED_FLAGS}>
        $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$__c_${sanitizer_name}_res>>:${CMAKE_REQUIRED_FLAGS}>
    )
    target_link_options(
      GoogleSanitizer::${sanitizer_name}
      INTERFACE
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$__cxx_${sanitizer_name}_res>>:${CMAKE_REQUIRED_FLAGS}>
      $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$__c_${sanitizer_name}_res>>:${CMAKE_REQUIRED_FLAGS}>
    )

    if(sanitizer_name STREQUAL "address")
      target_compile_definitions(
        GoogleSanitizer::${sanitizer_name}
        INTERFACE
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$__cxx_${sanitizer_name}_res>>:_GLIBCXX_SANITIZE_VECTOR>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$__cxx_${sanitizer_name}_res>>:_GLIBCXX_SANITIZE_STD_ALLOCATOR>
      )
      target_link_options(
        GoogleSanitizer::${sanitizer_name}
        INTERFACE
        $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$__cxx_${sanitizer_name}_res>,$<CXX_COMPILER_ID:GNU>>:-lasan>
        $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$__c_${sanitizer_name}_res>,$<C_COMPILER_ID:GNU>>:-lasan>
      )
    endif()
    if(sanitizer_name STREQUAL "undefined")
      target_link_options(
        GoogleSanitizer::${sanitizer_name}
        INTERFACE
        $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:$__cxx_${sanitizer_name}_res>,$<CXX_COMPILER_ID:GNU>>:-lubsan>
        $<$<AND:$<COMPILE_LANGUAGE:C>,$<BOOL:$__c_${sanitizer_name}_res>,$<C_COMPILER_ID:GNU>>:-lubsan>
      )
    endif()
  endif()
endforeach()

cmake_pop_check_state()
