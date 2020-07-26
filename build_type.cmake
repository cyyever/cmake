include_guard(GLOBAL)

get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT isMultiConfig)
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE
        Debug
        CACHE STRING "" FORCE)
  endif()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
function(add_custom_build_type build_type)
  if(isMultiConfig)
    if(${build_type} IN_LIST CMAKE_CONFIGURATION_TYPES)
      return()
    endif()
    list(APPEND CMAKE_CONFIGURATION_TYPES ${build_type})
    set(CMAKE_CONFIGURATION_TYPES
        "${CMAKE_CONFIGURATION_TYPES}"
        CACHE STRING "" FORCE)
  else()
    get_property(
      build_type_strings
      CACHE CMAKE_BUILD_TYPE
      PROPERTY STRINGS)
    if(${build_type} IN_LIST build_type_strings)
      return()
    endif()
    list(APPEND build_type_strings ${build_type})
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
                                                 "${build_type_strings}")
  endif()

  foreach(lang IN LISTS languages)
    set(CMAKE_${lang}_FLAGS_${build_type}
        ""
        CACHE STRING "")
  endforeach()
  foreach(targettype IN ITEMS EXE SHARED STATIC MODULE)
    set(CMAKE_${targettype}_LINKER_FLAGS_${build_type}
        ""
        CACHE STRING "")
  endforeach()
endfunction()

function(add_custom_build_type_like build_type existed_build_type)
  add_custom_build_type(${build_type})
  foreach(lang IN LISTS languages)
    set(CMAKE_${lang}_FLAGS_${build_type}
        "${CMAKE_${lang}_FLAGS_${existed_build_type}}"
        CACHE STRING "" FORCE)
  endforeach()
  foreach(targettype IN ITEMS EXE SHARED STATIC MODULE)
    set(CMAKE_${targettype}_LINKER_FLAGS_${build_type}
        "${CMAKE_${targettype}_LINKER_FLAGS_${existed_build_type}}"
        CACHE STRING "" FORCE)
  endforeach()
endfunction()
