#static code analysis
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
