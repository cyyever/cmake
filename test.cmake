INCLUDE(${CMAKE_CURRENT_LIST_DIR}/compiler.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/code_coverage.cmake)

ENABLE_TESTING()

if(NOT TARGET check)
  ADD_CUSTOM_TARGET(check ALL COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIGURATION>)
endif()

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

FIND_PACKAGE(valgrind)

if(valgrind_FOUND)
  FILE(GLOB suppression_files ${CMAKE_CURRENT_LIST_DIR}/valgrind_supp/*.supp)
endif()

macro(add_valgrind_suppression_dir dir)
  FILE(GLOB tmp_suppression_files ${dir}/*.supp)
  FOREACH(file ${tmp_suppression_files})
    LIST(APPEND suppression_files "${file}")
  endforeach()
endmacro()

function(add_test_with_runtime_analysis target)
  set(name ${target})
  if(valgrind_FOUND)
    set(memcheck_command "${valgrind_BINARY} --error-exitcode=1 --trace-children=yes --gen-suppressions=all --track-fds=yes --leak-check=full")
    foreach(suppression_file ${suppression_files})
      set(memcheck_command "${memcheck_command} --suppressions=${suppression_file}")
    endforeach()
    separate_arguments(memcheck_command)
    add_test(NAME memcheck_${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${target}> COMMAND ${memcheck_command} ${target} ${ARGN})
  else()
    add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${target}> COMMAND ${target} ${ARGN})
  endif()
  add_dependencies(check ${name})
endfunction(add_test_with_runtime_analysis)

FIND_PACKAGE(gcovr)
if(ENABLE_CODE_COVERAGE AND NOT TARGET code_coverage AND gcovr_FOUND)
  ADD_CUSTOM_TARGET(code_coverage ALL 
    COMMAND mkdir -p ${CMAKE_BINARY_DIR}/code_coverage && ${gcovr_BINARY} -r ${CMAKE_SOURCE_DIR} --object-directory=`find ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY} -name '*.gcno' -print0 -quit | xargs -0 -n 1 dirname ` --html --html-details -o ${CMAKE_BINARY_DIR}/code_coverage/index.html
    DEPENDS check)
endif()
