INCLUDE(${CMAKE_CURRENT_LIST_DIR}/compiler.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/code_coverage.cmake)

ENABLE_TESTING()

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


include(FindPackageHandleStandardArgs)
find_path(VALGRIND_PATH valgrind PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(valgrind DEFAULT_MSG VALGRIND_PATH)

FILE(GLOB suppression_files ${CMAKE_CURRENT_LIST_DIR}/valgrind_supp/*.supp)

set(memcheck_command "${VALGRIND_PATH}/valgrind --error-exitcode=1 --trace-children=yes --gen-suppressions=all --track-fds=yes --leak-check=full")
foreach(suppression_file ${suppression_files})
  set(memcheck_command "${memcheck_command} --suppressions=${suppression_file}")
endforeach()

if(NOT TARGET check)
  ADD_CUSTOM_TARGET(check ALL COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIGURATION>)
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

message(STATUS ${CMAKE_FILES_DIRECTORY})
if(ENABLE_CODE_COVERAGE AND NOT TARGET code_coverage) 
  ADD_CUSTOM_TARGET(code_coverage ALL 
    COMMAND mkdir ${CMAKE_CURRENT_BINARY_DIR}/code_coverage && gcovr -r ${CMAKE_SOURCE_DIR} --object-directory=`find ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}  -name '*.gcno' -printf '%h\\n'  -quit` --html --html-details -o ${CMAKE_CURRENT_BINARY_DIR}/code_coverage/index.html
    DEPENDS check)
endif()
