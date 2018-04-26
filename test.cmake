INCLUDE(${CMAKE_CURRENT_LIST_DIR}/code_coverage.cmake)

ENABLE_TESTING()

if(NOT TARGET check)
  ADD_CUSTOM_TARGET(check ALL COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIGURATION>)
endif()

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

FIND_PACKAGE(valgrind)
FIND_PACKAGE(ubsan)
FIND_PACKAGE(asan)
FIND_PACKAGE(cudamemcheck)

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
  set(oneValueArgs TARGET WITH_CPU_ANALYSIS WITH_GPU_ANALYSIS MEMCHECK UBSAN HELGRIND ASAN CUDA-MEMCHECK)
  cmake_parse_arguments(this "" "${oneValueArgs}" "ARGS" ${ARGN})
  if("${this_TARGET}" STREQUAL "")
    message(FATAL_ERROR "no target specified")
    return()
  endif()
  separate_arguments(this_ARGS)

  if("${this_WITH_CPU_ANALYSIS}" STREQUAL "")
    set(this_WITH_CPU_ANALYSIS TRUE)
  endif()

  if("${this_WITH_GPU_ANALYSIS}" STREQUAL "")
    set(this_WITH_GPU_ANALYSIS FALSE)
  endif()

  #set default values for runtime analysis
  if("${this_MEMCHECK}" STREQUAL "")
    if(valgrind_FOUND)
      set(this_MEMCHECK TRUE)
    else()
      set(this_MEMCHECK FALSE)
    endif()
  elseif(${this_MEMCHECK} AND NOT valgrind_FOUND)
    message(WARNING "no valgrind")
    set(this_MEMCHECK FALSE)
  endif()

  if("${this_HELGRIND}" STREQUAL "")
    set(this_HELGRIND FALSE)
  elseif(${this_HELGRIND} AND NOT valgrind_FOUND)
    message(WARNING "no valgrind")
    set(this_HELGRIND FALSE)
  endif()

  if("${this_UBSAN}" STREQUAL "")
    if(ubsan_FOUND)
      set(this_UBSAN TRUE)
    else()
      set(this_UBSAN FALSE)
    endif()
  elseif(${this_UBSAN} AND NOT ubsan_FOUND)
    message(WARNING "no ubsan")
    set(this_UBSAN FALSE)
  endif()

  if("${this_ASAN}" STREQUAL "")
    if(${this_MEMCHECK})
      set(this_ASAN FALSE)
    elseif(asan_FOUND AND NOT ${this_UBSAN})
      set(this_ASAN TRUE)
    endif()
  elseif(${this_ASAN} AND NOT asan_FOUND)
    message(WARNING "no asan")
    set(this_ASAN FALSE)
  endif()

  if("${this_CUDA-MEMCHECK}" STREQUAL "")
    set(this_CUDA-MEMCHECK FALSE)
  elseif(${this_CUDA-MEMCHECK} AND NOT cudamemcheck_FOUND)
    message(WARNING "no cuda-memcheck")
    set(this_CUDA-MEMCHECK FALSE)
  endif()

  if(${this_WITH_CPU_ANALYSIS})
    set(has_test FALSE)
    if(${this_MEMCHECK})
      set(memcheck_command "${valgrind_BINARY} --error-exitcode=1 --trace-children=yes --gen-suppressions=all --track-fds=yes --leak-check=full")
      foreach(suppression_file ${suppression_files})
	set(memcheck_command "${memcheck_command} --suppressions=${suppression_file}")
      endforeach()
      separate_arguments(memcheck_command)
      set(name "memcheck_${this_TARGET}")
      add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND ${memcheck_command} $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
      set(has_test TRUE)
    endif()

    if(${this_HELGRIND})
      set(helgrind_command "${valgrind_BINARY} --tool=helgrind --error-exitcode=1 --trace-children=yes --gen-suppressions=all")
      foreach(suppression_file ${suppression_files})
	set(helgrind_command "${helgrind_command} --suppressions=${suppression_file}")
      endforeach()
      separate_arguments(helgrind_command)
      set(name "helgrind_${this_TARGET}")
      add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND ${helgrind_command} $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
      set(has_test TRUE)
    endif()

    if(${this_UBSAN})
      target_compile_options(${this_TARGET} PRIVATE "-fsanitize=undefined")
      set_target_properties(${this_TARGET} PROPERTIES LINK_FLAGS "-fsanitize=undefined")
      set(name ${this_TARGET})
      add_test(NAME "ubsan_${name}" WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
      set(has_test TRUE)
    endif()

    if(${this_ASAN})
      target_compile_options(${this_TARGET} PRIVATE "-fsanitize=address")
      set_target_properties(${this_TARGET} PROPERTIES LINK_FLAGS "-fsanitize=address")
      set(name ${this_TARGET})
      add_test(NAME "asan_${name}" WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
      set(has_test TRUE)
    endif()

    if(${has_test})
      set(this_WITH_CPU_ANALYSIS TRUE)
    else()
      set(this_WITH_CPU_ANALYSIS FALSE)
    endif()
  endif()

  if(NOT ${this_WITH_GPU_ANALYSIS})
    set(has_test FALSE)
    if(${this_CUDA-MEMCHECK})
      set(memcheck_command "${cudamemcheck_BINARY} --tool memcheck --leak-check full --error-exitcode 1 --flush-to-disk yes")
      separate_arguments(memcheck_command)
      set(name "cuda-memcheck_${this_TARGET}")
      add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND ${memcheck_command} $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
      set(has_test TRUE)
    endif()

    if(${has_test})
      set(this_WITH_GPU_ANALYSIS TRUE)
    else()
      set(this_WITH_GPU_ANALYSIS FALSE)
    endif()
  endif()

  if(NOT ${this_WITH_CPU_ANALYSIS} AND NOT ${this_WITH_GPU_ANALYSIS})
    set(name ${this_TARGET})
    add_test(NAME ${name} WORKING_DIRECTORY $<TARGET_FILE_DIR:${this_TARGET}> COMMAND $<TARGET_FILE:${this_TARGET}> ${this_ARGS})
  endif()
  add_dependencies(check ${this_TARGET})
endfunction()

FIND_PACKAGE(gcovr)
FIND_PACKAGE(lcov)

if(ENABLE_GNU_CODE_COVERAGE AND NOT TARGET code_coverage)
  if(lcov_FOUND)
    ADD_CUSTOM_TARGET(code_coverage ALL
      COMMAND mkdir -p ${CMAKE_BINARY_DIR}/code_coverage
      COMMAND ${lcov_BINARY} --capture --directory ${CMAKE_BINARY_DIR} --output-file coverage.info
      COMMAND ${genhtml_BINARY} coverage.info --output-directory ${CMAKE_BINARY_DIR}/code_coverage
      DEPENDS check)
  elseif(gcovr_FOUND)
    ADD_CUSTOM_TARGET(code_coverage ALL 
      COMMAND mkdir -p ${CMAKE_BINARY_DIR}/code_coverage && ${gcovr_BINARY} -r ${CMAKE_SOURCE_DIR} --object-directory=`find ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY} -name '*.gcno' -print0 -quit | xargs -0 -n 1 dirname ` --html --html-details -o ${CMAKE_BINARY_DIR}/code_coverage/index.html
      DEPENDS check)
  endif()
endif()


if(ENABLE_LLVM_CODE_COVERAGE AND NOT TARGET code_coverage)
    ADD_CUSTOM_TARGET(code_coverage ALL
      COMMAND llvm-profdata merge -sparse `find -name default.profraw` -o default.profdata
      COMMAND llvm-cov show -instr-profile=`find -name default.profdata` -format=html -output-dir=${CMAKE_BINARY_DIR}/code_coverage `find ${CMAKE_BINARY_DIR} -name '*.so'` `find ${CMAKE_BINARY_DIR} -executable -type f
`
      DEPENDS check)
endif()
