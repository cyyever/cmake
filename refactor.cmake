include_guard(GLOBAL)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

find_package(ClangTools QUIET)
if(clang-tidy_FOUND AND run-clang-tidy_FOUND AND clang-apply-replacements_FOUND AND NOT TARGET do-clang-tidy-fix)
    set(CHECKES "-checks='modernize*'")
    add_custom_target(
      do-clang-tidy-fix
      COMMAND ClangTools::run-clang-tidy -fix -clang-tidy-binary "$<TARGET_FILE:ClangTools::clang-tidy>" -clang-apply-replacements-binary "$<TARGET_FILE:ClangTools::clang-apply-replacements>" -p ${CMAKE_BINARY_DIR} "-quiet" ${CHECKES}
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
endif()
