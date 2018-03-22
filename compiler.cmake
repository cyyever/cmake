IF (WIN32)
  set(CMAKE_INSTALL_PREFIX "C:/deepir" CACHE PATH "default install path" FORCE )
  #保证测试代码能找到dll
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
  if(NOT CMAKE_TOOLCHAIN_FILE AND EXISTS "$ENV{CMAKE_TOOLCHAIN_FILE}")
    set(CMAKE_TOOLCHAIN_FILE "$ENV{CMAKE_TOOLCHAIN_FILE}")
  endif()
endif()

SET(CMAKE_CXX_STANDARD 17)

IF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  add_compile_options("-O3" "-Weverything" "-Wno-c++98-compat" "-Wno-zero-as-null-pointer-constant" "-Wno-c++98-compat-pedantic" "-Wno-padded" "-Wno-double-promotion" "-Wno-weak-vtables" "-Wno-disabled-macro-expansion" "-Wno-reserved-id-macro" "-Wno-global-constructors" "-Wno-exit-time-destructors")
ELSEIF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  add_compile_options("-O3" "-Wall" "-Wextra" "-Wshadow" "-Wnon-virtual-dtor" "-pedantic")
ELSEIF(MSVC)
  add_compile_options("/MP" "/utf-8" "/W4" "/Ox")
  #list(APPEND CMAKE_EXE_LINKER_FLAGS "/incremental")
ENDIF()

if(${CMAKE_VERSION} VERSION_GREATER "3.9.0" AND NOT MSVC)
  cmake_policy(SET CMP0069 NEW)
  include(CheckIPOSupported)
  check_ipo_supported(RESULT result OUTPUT output)
  if(result)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
  else()
    message(WARNING "IPO is not supported: ${output}")
  endif()
endif()

IF (WIN32) 
  SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
  SET(BUILD_SHARED_LIBS TRUE)
ENDIF()

#static code analysis
SET(CMAKE_LINK_WHAT_YOU_USE TRUE)
SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

IF (NOT WIN32)
  SET(CLANG-TIDY-PATH "/usr/bin/clang-tidy-6.0")
ENDIF()

IF (EXISTS "${CLANG-TIDY-PATH}")
  SET(CMAKE_CXX_CLANG_TIDY "${CLANG-TIDY-PATH}" "-extra-arg-before=-std=c++17" "-analyze-temporary-dtors" "-checks=*,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,-cppcoreguidelines-pro-type-reinterpret-cast,-cppcoreguidelines-pro-type-vararg,-readability-implicit-bool-cast,-google-readability-braces-around-statements,-cppcoreguidelines-pro-type-union-access,-readability-braces-around-statements,-cppcoreguidelines-pro-bounds-pointer-arithmetic,-google-readability-namespace-comments,-fuchsia-default-arguments,-hicpp-no-array-decay,-llvm-namespace-comment,-readability-implicit-bool-conversion,-modernize-pass-by-value,-fuchsia-overloaded-operator,-cert-err58-cpp,-hicpp-vararg")
ENDIF()

IF (WIN32)
  SET(CPPCHECK_PATH "C:/Program Files/Cppcheck/cppcheck.exe")
ELSE()
  SET(CPPCHECK_PATH "/usr/bin/cppcheck")
ENDIF()

IF(EXISTS "${CPPCHECK_PATH}")
  SET(CMAKE_CXX_CPPCHECK "${CPPCHECK_PATH}" "--std=c++14" "--enable=warning,performance")
ENDIF()

IF(EXISTS /usr/bin/include-what-you-use)
  SET(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "include-what-you-use")
ENDIF()

IF(MSVC)
  add_compile_options("/analyze")
ENDIF()

SET(TEST_IMAGE_DIR ${CMAKE_CURRENT_LIST_DIR}/../test_images)
