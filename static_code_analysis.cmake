include_guard(GLOBAL)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

option(WITH_MSVC_RULESET "use ruleset for static analysis" OFF)
foreach(lang IN ITEMS C CXX)
  if(lang IN_LIST languages)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "MSVC")
      add_compile_options($<$<CONFIG:DEBUG>:/analyze>)
      add_compile_options($<$<CONFIG:DEBUG>:/wd26446>)
      add_compile_options($<$<CONFIG:DEBUG>:/wd26486>)
      add_compile_options($<$<CONFIG:DEBUG>:/wd26489>)
      add_compile_options($<$<CONFIG:DEBUG>:/wd26481>)
      if(WITH_MSVC_RULESET)
        add_compile_options("$<$<CONFIG:DEBUG>:/analyze:plugin EspXEngine.dll>")
      endif()
    endif()
  endif()
endforeach()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  add_custom_target(
    copy_compile_commands_json
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/compile_commands.json
            ${CMAKE_SOURCE_DIR}
    DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

option(CLANG_TIDY_CONFIG ".clang-tidy path" OFF)
if(NOT TARGET do_run_clang_tidy AND NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  find_package(ClangTools QUIET)
  find_package(Python3 QUIET COMPONENTS Interpreter)
  if(TARGET ClangTools::run-clang-tidy
     AND TARGET ClangTools::clang-tidy
     AND TARGET Python3::Interpreter)
    if(NOT CLANG_TIDY_CONFIG)
      if(EXISTS "${CMAKE_SOURCE_DIR}/.clang-tidy")
        set(CLANG_TIDY_CONFIG "${CMAKE_SOURCE_DIR}/.clang-tidy")
      elseif(CXX IN_LIST languages
             AND EXISTS "$ENV{HOME}/opt/cli_tool_configs/cpp-clang-tidy")
        set(CLANG_TIDY_CONFIG "$ENV{HOME}/opt/cli_tool_configs/cpp-clang-tidy")
      endif()
    endif()
    add_custom_target(
      do_run_clang_tidy
      COMMAND
        Python3::Interpreter "$<TARGET_FILE:ClangTools::run-clang-tidy>"
        -clang-tidy-binary "$<TARGET_FILE:ClangTools::clang-tidy>" -p
        ${CMAKE_BINARY_DIR} "-quiet" -excluded-file-patterns
        "'(.*/third_party/.*)|(.*[.]pb[.])|(.*/test/.*)|(.*/build/.*)'"
        -format-style=file -timeout=7200 -config-file "${CLANG_TIDY_CONFIG}"  > ./run-clang-tidy.txt
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
  endif()
endif()

find_package(cppcheck QUIET)
if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  if(cppcheck_FOUND AND NOT TARGET do_cppcheck)
    add_custom_target(
      do_cppcheck
      COMMAND
        cppcheck::cppcheck --project=${CMAKE_BINARY_DIR}/compile_commands.json
        --std=c++20 --enable=all --check-config
        --template='{file}:{line},{severity},{id},{message}' --inconclusive 2>
        ./do_cppcheck.txt
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
  endif()
endif()

if(NOT TARGET do_include_what_you_use AND NOT CMAKE_CXX_COMPILER_ID STREQUAL
                                          "MSVC")
  find_package(iwyu QUIET)
  if(iwyu_tool_FOUND)
    add_custom_target(
      do_include_what_you_use
      COMMAND iwyu::iwyu_tool -p ${CMAKE_BINARY_DIR} -- -Xiwyu
              --transitive_includes_only > ./do_include_what_you_use.txt
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
  endif()
endif()

find_package(PVS-Studio QUIET)
if(PVS-Studio_FOUND)
  if(NOT WIN32)
    add_custom_target(
      do_pvs_studio_analysis
      COMMAND PVS-Studio::analyzer analyze --intermodular -a 31 -o
              ./pvs-studio.log -j8 || true
      COMMAND
        PVS-Studio::plog-converter -t tasklist -a
        'GA:1,2,3;64:1,2,3;OP:1,2,3;CS:1,2,3' -o ./pvs-studio-report.txt
        ./pvs-studio.log
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
  else()
    find_package(powershell QUIET)
    if(powershell_FOUND)
      add_custom_target(
        do_pvs_studio_analysis
        COMMAND
          PVS-Studio::Cmd --incremental ScanAndAnalyze --target
          ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.sln --progress -o
          ./pvs-studio.log
        COMMAND PVS-Studio::plog-converter -t FullHtml,Tasks -o . -n
                pvs-studio-report ./pvs-studio.log
        COMMAND powershell::powershell rm ./pvs-studio.log
        DEPENDS ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.sln
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    endif()
  endif()
endif()
