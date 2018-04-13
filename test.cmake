INCLUDE(${CMAKE_CURRENT_LIST_DIR}/compiler.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/code_coverage.cmake)

ENABLE_TESTING()

if(NOT TARGET check)
  ADD_CUSTOM_TARGET(check ALL COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIGURATION>)
endif()

#IF(${CMAKE_HOST_SYSTEM_NAME} EQUAL "Linux")
#  #apt-get install extra-cmake-modules
#  FIND_PACKAGE(ECM REQUIRED)
#  LIST(APPEND CMAKE_MODULE_PATH "${ECM_MODULE_DIR}")
#
#  #給測試增加llvm sanitizer
#  include(ECMEnableSanitizers)
#  #set(ECM_ENABLE_SANITIZERS 'address;leak;undefined')
#  set(ECM_ENABLE_SANITIZERS 'undefined;leak')
#ENDIF()

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

FIND_PACKAGE(valgrind)

if(valgrind_FOUND)
  FILE(GLOB suppression_files ${CMAKE_CURRENT_LIST_DIR}/valgrind_supp/*.supp)

  set(memcheck_command "${valgrind_BINARY} --error-exitcode=1 --trace-children=yes --gen-suppressions=all --track-fds=yes --leak-check=full")
  foreach(suppression_file ${suppression_files})
    set(memcheck_command "${memcheck_command} --suppressions=${suppression_file}")
  endforeach()
endif()

function(add_test_with_runtime_analysis name binary)
  if(valgrind_FOUND)
    separate_arguments(memcheck_command)
    add_test(NAME memcheck_${name} COMMAND ${memcheck_command} ./${binary} ${ARGN})
  else()
    add_test(NAME ${name} COMMAND ./${binary} ${ARGN})
  endif()
  add_dependencies(check ${name})
endfunction(add_test_with_runtime_analysis)

FIND_PACKAGE(gcovr)
if(ENABLE_CODE_COVERAGE AND NOT TARGET code_coverage AND gcovr_FOUND)
  ADD_CUSTOM_TARGET(code_coverage ALL 
    COMMAND mkdir -p ${CMAKE_BINARY_DIR}/code_coverage && ${gcovr_BINARY} -r ${CMAKE_SOURCE_DIR} --object-directory=`find ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}  -name '*.gcno' -printf '%h\\n'  -quit` --html --html-details -o ${CMAKE_BINARY_DIR}/code_coverage/index.html
    DEPENDS check)
endif()
