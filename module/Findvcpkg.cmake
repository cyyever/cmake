# - Try to find vcpkg
#
# The following are set after configuration is done:
#  vcpkg_FOUND
#  vcpkg_dir
#  vcpkg_toolchain_file

include(FindPackageHandleStandardArgs)
find_file(vcpkg_dir vcpkg PATHS c:/code)
find_package_handle_standard_args(vcpkg DEFAULT_MSG vcpkg_dir)
if(vcpkg_FOUND)
  find_file(vcpkg_toolchain_file vcpkg.cmake PATHS ${vcpkg_dir}//scripts/buildsystems)
  find_package_handle_standard_args(vcpkg DEFAULT_MSG vcpkg_dir vcpkg_toolchain_file)
endif()
