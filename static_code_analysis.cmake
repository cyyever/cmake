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
    copy_compile_commands_json ALL
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/compile_commands.json
            ${CMAKE_SOURCE_DIR}
    DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  find_package(ClangTools QUIET)
  if(clang-tidy_FOUND
     AND run-clang-tidy_FOUND
     AND NOT TARGET do_run_clang_tidy)
    set(EXTRA-ARGS -extra-arg='-std=c++2a' -extra-arg='-Qunused-arguments')
    set(CHECKES
        "-checks='*,-fuchsia-default-arguments,-clang-analyzer-cplusplus.NewDeleteLeaks,-clang-diagnostic-ignored-optimization-argument,-readability-implicit-bool-conversion,-llvm-namespace-comment,-google-readability-namespace-comments,-cppcoreguidelines-owning-memory,-cert-err58-cpp,-fuchsia-statically-constructed-objects,-clang-diagnostic-gnu-zero-variadic-macro-arguments,-cppcoreguidelines-pro-bounds-pointer-arithmetic,-cppcoreguidelines-pro-type-vararg,-cppcoreguidelines-avoid-magic-numbers,-hicpp-vararg,-readability-magic-numbers,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,-hicpp-no-array-decay,-modernize-use-trailing-return-type,-fuchsia-default-arguments-calls,-clang-diagnostic-ctad-maybe-unsupported,-google-build-using-namespace'"
    )
    if(C IN_LIST languages AND NOT CXX IN_LIST languages)
      set(EXTRA-ARGS)
      set(CHECKES
          "-checks='*,-modernize*,-*readability*,-hicpp-braces*,-cppcoreguidelines*,-misc-non-private-member-variables-in-classes,-hicpp-no-malloc,-*uppercase-literal-suffix*,-llvm-include-order,-bugprone-narrowing-conversions,-performance-type-promotion-in-math-fn,-hicpp-signed-bitwise'"
      )
    endif()
    add_custom_target(
      do_run_clang_tidy
      COMMAND
        ClangTools::run-clang-tidy -clang-tidy-binary
        "$<TARGET_FILE:ClangTools::clang-tidy>" -p ${CMAKE_BINARY_DIR} "-quiet"
        ${EXTRA-ARGS} ${CHECKES} | grep -v 'clang.*tidy.*checks' >
        ./run-clang-tidy.txt
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
        --std=c++20 --enable=all --inconclusive 2> ./do_cppcheck.txt
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
  endif()
endif()

find_package(iwyu QUIET)
if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  if(iwyu_tool_FOUND AND NOT TARGET do_include_what_you_use)
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
      COMMAND PVS-Studio::analyzer analyze --incremental -a 31 -o
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
