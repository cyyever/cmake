#static code analysis
SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

FIND_PACKAGE(clangtidy)
if(clangtidy_FOUND)
  SET(CMAKE_CXX_CLANG_TIDY "${clangtidy_BINARY}" "-extra-arg-before=-std=c++17" "-analyze-temporary-dtors" "-checks=*,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,-cppcoreguidelines-pro-type-reinterpret-cast,-cppcoreguidelines-pro-type-vararg,-readability-implicit-bool-cast,-google-readability-braces-around-statements,-cppcoreguidelines-pro-type-union-access,-readability-braces-around-statements,-cppcoreguidelines-pro-bounds-pointer-arithmetic,-google-readability-namespace-comments,-fuchsia-default-arguments,-hicpp-no-array-decay,-llvm-namespace-comment,-readability-implicit-bool-conversion,-modernize-pass-by-value,-fuchsia-overloaded-operator,-cert-err58-cpp,-hicpp-vararg")
ENDIF()

FIND_PACKAGE(cppcheck)
if(cppcheck_FOUND)
  SET(CMAKE_CXX_CPPCHECK "${cppcheck_BINARY}" "--std=c++14" "--enable=warning,performance,portability,style")
endif()

IF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  add_compile_options("/analyze")
ENDIF()
