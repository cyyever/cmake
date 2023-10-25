include_guard(GLOBAL)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

find_package(ClangTools QUIET)
if(clang-tidy_FOUND
   AND run-clang-tidy_FOUND
   AND clang-apply-replacements_FOUND
   AND NOT TARGET do_clang_tidy_fix)
  add_custom_target(
    do_clang_tidy_fix
    COMMAND
      ClangTools::run-clang-tidy -fix -clang-tidy-binary
      "$<TARGET_FILE:ClangTools::clang-tidy>" -p ${CMAKE_BINARY_DIR} "-quiet"
    DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
endif()
