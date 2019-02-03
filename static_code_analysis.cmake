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

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

find_package(ClangTools QUIET)
if(clang-tidy_FOUND AND run-clang-tidy_FOUND AND NOT TARGET do-run-clang-tidy)
  set(EXTRA-ARGS -extra-arg='-std=c++2a' -extra-arg='-Qunused-arguments')
  set(CHECKES "-checks='*,-fuchsia-default-arguments,-clang-analyzer-cplusplus.NewDeleteLeaks,-clang-diagnostic-ignored-optimization-argument,-readability-implicit-bool-conversion,-llvm-namespace-comment,-google-readability-namespace-comments,-cppcoreguidelines-owning-memory,-cert-err58-cpp,-fuchsia-statically-constructed-objects,-clang-diagnostic-gnu-zero-variadic-macro-arguments,-cppcoreguidelines-pro-bounds-pointer-arithmetic,-cppcoreguidelines-pro-type-vararg,-cppcoreguidelines-avoid-magic-numbers,-hicpp-vararg,-readability-magic-numbers,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,-hicpp-no-array-decay'")
    add_custom_target(
      do-run-clang-tidy
      COMMAND ClangTools::run-clang-tidy -clang-tidy-binary "$<TARGET_FILE:ClangTools::clang-tidy>" -p ${CMAKE_BINARY_DIR} "-quiet" ${EXTRA-ARGS} ${CHECKES} > ./run-clang-tidy.txt
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
endif()

find_package(cppcheck QUIET)
if(cppcheck_FOUND AND NOT TARGET do-cppcheck) 
  add_custom_target(do-cppcheck
    COMMAND cppcheck::cppcheck --project=${CMAKE_BINARY_DIR}/compile_commands.json --std=c++14 --enable=all --inconclusive 2> ./do-cppcheck.txt
    DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endif()

find_package(iwyu QUIET)
if(iwyu_tool_FOUND AND NOT TARGET do-include-what-you-use)
  add_custom_target(do-include-what-you-use
    COMMAND iwyu::iwyu_tool -p ${CMAKE_BINARY_DIR} > ./do-include-what-you-use.txt
    DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endif()

option(WITH_PVSSTUDIO "use PVS-Studio for static analysis" OFF)
if(WITH_PVSSTUDIO)
  find_package(PVS-Studio QUIET)
  if(PVS-Studio_FOUND)
    if(NOT WIN32)
      add_custom_target(do-pvs-studio-analysis
        COMMAND grep '"file":' ${CMAKE_BINARY_DIR}/compile_commands.json | sed -e 's/"file"://' | xargs -I source_file sed -i -e '1i // This is an open source non-commercial project. Dear PVS-Studio, please check it.' -e '1i // PVS-Studio Static Code Analyzer for C, C++ and C\#: http://www.viva64.com' source_file
        COMMAND PVS-Studio::analyzer analyze -a 31 -o ./pvs-studio.log -j8 || true
        COMMAND PVS-Studio::plog-converter -t tasklist -a 'GA:1,2,3;64:1,2,3;OP:1,2,3;CS:1,2,3' -o ./pvs-studio-report.txt ./pvs-studio.log
        COMMAND rm ./pvs-studio.log
        DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )
    else()
      find_package(powershell QUIET)
      if(powershell_FOUND) 
        add_custom_target(do-pvs-studio-analysis
          COMMAND PVS-Studio::Cmd --incremental ScanAndAnalyze --target ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.sln --progress -o ./pvs-studio.log
          COMMAND PVS-Studio::plog-converter -t FullHtml,Tasks -o . -n pvs-studio-report ./pvs-studio.log 
          COMMAND powershell::powershell rm ./pvs-studio.log
          DEPENDS ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.sln
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          )
      endif()
    endif()
  endif()
endif()
