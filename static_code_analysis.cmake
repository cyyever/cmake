#static code analysis
SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

FIND_PACKAGE(clangtidy)
if(clangtidy_FOUND)
  SET(CMAKE_CXX_CLANG_TIDY "${clangtidy_BINARY}" "-extra-arg-before=-std=c++17" "-analyze-temporary-dtors" "-checks=*,-fuchsia-default-arguments")
ENDIF()

FIND_PACKAGE(cppcheck)
if(cppcheck_FOUND)
  add_custom_target(do_cppcheck ALL
    COMMAND ${cppcheck_BINARY} --project=${CMAKE_BINARY_DIR}/compile_commands.json --std=c++14 --enable=all
    DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json)
endif()

IF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  add_compile_options("/analyze")
ENDIF()

IF (NOT WIN32)
  FIND_PACKAGE(scanbuild)
  if(NOT TARGET scan_build AND scanbuild_FOUND)
    ADD_CUSTOM_TARGET(scan_build
      COMMAND cmake -DCMAKE_CXX_COMPILER=${cpp_analyzer_BINARY} -DCMAKE_C_COMPILER=${ccc_analyzer_BINARY} ${CMAKE_BINARY_DIR}
      COMMAND ${scanbuild_BINARY} ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR}
      )
  endif()
endif()
