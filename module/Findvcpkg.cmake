# - Try to find vcpkg
#
# The following are set after configuration is done:
#  vcpkg_FOUND

include_guard()
include(FindPackageHandleStandardArgs)
find_path(vcpkg_dir NAMES bootstrap-vcpkg.bat PATH_SUFFIXES vcpkg)
find_package_handle_standard_args(vcpkg DEFAULT_MSG vcpkg_dir)

if(NOT vcpkg_FOUND)
  return()
endif()

include("${vcpkg_dir}/scripts/buildsystems/vcpkg_toolchain_file")
#include_directories(${vcpkg_dir}/installed/${VCPKG_TARGET_TRIPLET}/include)
#link_directories(${vcpkg_dir}/installed/${VCPKG_TARGET_TRIPLET}/lib)
list(APPEND CMAKE_MODULE_PATH "${vcpkg_dir}/installed/${VCPKG_TARGET_TRIPLET}/share")
