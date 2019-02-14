include_guard(GLOBAL)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

find_package(ClangFormat QUIET)
if(ClangFormat_FOUND AND NOT TARGET do_clang_format)
    add_custom_target(
      do_clang_format
      COMMAND grep '"file":' ${CMAKE_BINARY_DIR}/compile_commands.json | sed -e 's/"file"://' | xargs -I source_file $<TARGET_FILE:ClangFormat::clang-format> -style=file -i source_file
      DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
endif()
