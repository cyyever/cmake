include_guard()
if(NOT WIN32)
  return()
endif()

option(WITH_VCPKG "use vcpkg" OFF)
if(WITH_VCPKG)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)
  find_package(vcpkg REQUIRED)
endif()

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
