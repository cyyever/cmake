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

function(add_test_with_runtime_analysis)
  #default options
  set(this_NO_MEMCHECK FALSE)
  set(this_NO_RUNTIME_ANALYSIS FALSE)
  set(options NO_MEMCHECK)
  cmake_parse_arguments(this "${options}" "TARGET" "ARGS" ${ARGN})
  if("${this_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no target specified")
    return()
  endif()
  separate_arguments(this_ARGS)

  if(NOT ${this_NO_RUNTIME_ANALYSIS})
    set(has_test FALSE)
    if(valgrind_FOUND AND NOT ${this_NO_MEMCHECK})
      set(memcheck_command "${valgrind_BINARY} --error-exitcode=1 --trace-children=yes --gen-suppressions=all --track-fds=yes --leak-check=full")
      foreach(suppression_file ${suppression_files})
	set(memcheck_command "${memcheck_command} --suppressions=${suppression_file}")
      endforeach()
      separate_arguments(memcheck_command)
      set(name "memcheck_${this_TARGET}")
      add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND ${memcheck_command} $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
      set(has_test TRUE)
    endif()

    if(NOT ${has_test})
      set(this_NO_RUNTIME_ANALYSIS TRUE)
    endif()
  endif()
  if(${this_NO_RUNTIME_ANALYSIS})
    set(name ${this_TARGET})
    add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
  endif()
  add_dependencies(check ${this_TARGET})
endfunction()

FIND_PACKAGE(gcovr)
if(ENABLE_CODE_COVERAGE AND NOT TARGET code_coverage AND gcovr_FOUND)
  ADD_CUSTOM_TARGET(code_coverage ALL 
    COMMAND mkdir -p ${CMAKE_BINARY_DIR}/code_coverage && ${gcovr_BINARY} -r ${CMAKE_SOURCE_DIR} --object-directory=`find ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY} -name '*.gcno' -print0 -quit | xargs -0 -n 1 dirname ` --html --html-details -o ${CMAKE_BINARY_DIR}/code_coverage/index.html
    DEPENDS check)
endif()
