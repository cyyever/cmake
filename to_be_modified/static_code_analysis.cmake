option(WITH_MSVC_RULESET "use ruleset for static analysis" ON)
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  if(WITH_MSVC_RULESET)
    add_compile_options("/analyze" "/analyze:plugin EspXEngine.dll")
  endif()
  add_compile_options("/wd26446" "/wd26486" "/wd26489" "/wd26481")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  add_compile_options("-Wthread-safety")
endif()

SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

FIND_PACKAGE(ClangTools)
if(clang-tidy_FOUND)
  set(EXTRA-ARGS -extra-arg='-std=c++2a' -extra-arg='-Qunused-arguments')
  set(CHECKES "-checks='*,-fuchsia-default-arguments,-clang-analyzer-cplusplus.NewDeleteLeaks,-clang-diagnostic-ignored-optimization-argument,-readability-implicit-bool-conversion,-llvm-namespace-comment,-google-readability-namespace-comments,-cppcoreguidelines-owning-memory,-cert-err58-cpp,-fuchsia-statically-constructed-objects,-clang-diagnostic-gnu-zero-variadic-macro-arguments,-cppcoreguidelines-pro-bounds-pointer-arithmetic,-cppcoreguidelines-pro-type-vararg,-cppcoreguidelines-avoid-magic-numbers,-hicpp-vararg,-readability-magic-numbers,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,-hicpp-no-array-decay'")
  if(run-clang-tidy_FOUND AND NOT WIN32)
    ADD_CUSTOM_TARGET(do-run-clang-tidy
      COMMAND sed -i 's/-fno-tree-fre//' ${CMAKE_BINARY_DIR}/compile_commands.json
      COMMAND ${run-clang-tidy_BINARY} -p ${CMAKE_BINARY_DIR} "-quiet" ${EXTRA-ARGS} ${CHECKES} > ${CMAKE_BINARY_DIR}/run-clang-tidy.txt
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
  else()
    SET(CMAKE_CXX_CLANG_TIDY "${clang-tidy_BINARY}" ${EXTRA-ARGS} ${CHECKES})
  endif()
endif()

FIND_PACKAGE(cppcheck QUIET)
if(cppcheck_FOUND)
  if(NOT WIN32 AND NOT TARGET do-cppcheck) 
    ADD_CUSTOM_TARGET(do-cppcheck
      COMMAND ${cppcheck_BINARY} --project=${CMAKE_BINARY_DIR}/compile_commands.json --std=c++14 --enable=all --inconclusive 2> ${CMAKE_BINARY_DIR}/do-cppcheck.txt
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
  else()
   SET(CMAKE_CXX_CPPCHECK "${cppcheck_BINARY}" "--std=c++14" "--enable=all" "--inconclusive")
  endif()
endif()

FIND_PACKAGE(PVS-Studio QUIET)

if(pvsstudio_FOUND)
  if(NOT WIN32)
    ADD_CUSTOM_TARGET(do-pvs-studio-analysis
      COMMAND grep '"file":' ${CMAKE_BINARY_DIR}/compile_commands.json | sed -e 's/"file"://' | xargs -I source_file sed -i -e '1i // This is an open source non-commercial project. Dear PVS-Studio, please check it.' -e '1i // PVS-Studio Static Code Analyzer for C, C++ and C\#: http://www.viva64.com' source_file
      COMMAND ${pvs-studio-analyzer_BINARY} analyze -a 31 -o ${CMAKE_BINARY_DIR}/pvs-studio.log -j8 || true
      COMMAND grep '"file":' ${CMAKE_BINARY_DIR}/compile_commands.json | sed -e 's/"file"://' | xargs -I source_file sed -i -e '/.* This is an open source non-commercial project. Dear PVS-Studio, please check it./d' -e '/.* PVS-Studio Static Code Analyzer for C, C++.*/d' source_file
      COMMAND ${plog-converter_BINARY} -t tasklist -a 'GA:1,2,3;64:1,2,3;OP:1,2,3;CS:1,2,3' -o ${CMAKE_BINARY_DIR}/pvs-studio-report.txt ${CMAKE_BINARY_DIR}/pvs-studio.log
      COMMAND rm ${CMAKE_BINARY_DIR}/pvs-studio.log
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
  else()
    FIND_PACKAGE(powershell QUIET)
    if(powershell_FOUND) 
      ADD_CUSTOM_TARGET(do-pvs-studio-analysis
	COMMAND ${powershell_BINARY} grep 'ClCompile Include' --include='*.vcxproj.filters' -r ${CMAKE_BINARY_DIR} | sed -e 's/.*ClCompile Include="/"/' | sed -e 's/">.*/"/' | xargs -I source_file sed -i -e '1i // This is an open source non-commercial project. Dear PVS-Studio, please check it.' -e '1i // PVS-Studio Static Code Analyzer for C, C++ and C\#: http://www.viva64.com' source_file
	COMMAND ${PVS-Studio_Cmd_BINARY} --incremental ScanAndAnalyze --target ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.sln --progress -o ${CMAKE_BINARY_DIR}/pvs-studio.log || true
	COMMAND ${PlogConverter_BINARY} -t FullHtml,Tasks -o ${CMAKE_BINARY_DIR} -n pvs-studio-report ${CMAKE_BINARY_DIR}/pvs-studio.log 
	COMMAND ${powershell_BINARY} grep 'ClCompile Include' --include='*.vcxproj.filters' -r ${CMAKE_BINARY_DIR} | sed -e 's/.*ClCompile Include="/"/' | sed -e 's/">.*/"/' | xargs -I source_file sed -i -e '/.* This is an open source non-commercial project. Dear PVS-Studio, please check it./d' -e '/.* PVS-Studio Static Code Analyzer for C, C++.*/d' source_file
	COMMAND ${powershell_BINARY} grep 'ClCompile Include' --include='*.vcxproj.filters' -r ${CMAKE_BINARY_DIR} | sed -e 's/.*ClCompile Include="/"/' | sed -e 's/">.*/"/' | xargs -I source_file unix2dos source_file
	COMMAND ${powershell_BINARY} rm ${CMAKE_BINARY_DIR}/pvs-studio.log
	DEPENDS ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.sln
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	)
    endif()
  endif()
endif()
