# - Try to find clangtidy
#
# The following are set after configuration is done:
#  clangtidy_FOUND
#  clangtidy_BINARY

include(FindPackageHandleStandardArgs)
find_path(clangtidy_DIR clang-tidy PATHS /usr/bin /usr/local/bin)
find_package_handle_standard_args(clangtidy DEFAULT_MSG clangtidy_DIR)

if(clangtidy_FOUND)
  set(clangtidy_BINARY "${clangtidy_DIR}/clang-tidy")
endif()
