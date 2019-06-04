include_guard(GLOBAL)
cmake_policy(VERSION 3.11)
get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT isMultiConfig)
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
  endif()
endif()

function(add_custom_build_type build_type)
  if(isMultiConfig)
    if(NOT ${build_type} IN_LIST CMAKE_CONFIGURATION_TYPES)
      list(APPEND CMAKE_CONFIGURATION_TYPES ${build_type})
      set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING "" FORCE)
    endif()
  else()
    get_property(build_type_strings CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
    if(NOT ${build_type} IN_LIST build_type_strings)
      list(APPEND build_type_strings ${build_type})
      set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${build_type_strings}")
    endif()
  endif()
endfunction()

function(add_custom_build_type_like build_type existed_build_type)
  add_custom_build_type(${build_type})
  set(CMAKE_C_FLAGS_${build_type} "${CMAKE_C_FLAGS_${existed_build_type}}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_${build_type} "${CMAKE_CXX_FLAGS_${existed_build_type}}" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_${build_type} "${CMAKE_EXE_LINKER_FLAGS_${existed_build_type}}" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_${build_type} "${CMAKE_SHARED_LINKER_FLAGS_${existed_build_type}}" CACHE STRING "")
  set(CMAKE_STATIC_LINKER_FLAGS_${build_type} "${CMAKE_STATIC_LINKER_FLAGS_${existed_build_type}}" CACHE STRING "")
  set(CMAKE_MODULE_LINKER_FLAGS_${build_type} "${CMAKE_MODULE_LINKER_FLAGS_${existed_build_type}}" CACHE STRING "")
endfunction()
