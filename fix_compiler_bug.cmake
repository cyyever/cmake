include_guard(GLOBAL)
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

# fix compiler bug
foreach(lang IN LISTS languages)
  if(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_${lang}_COMPILER_VERSION VERSION_EQUAL 8.1
       OR CMAKE_${lang}_COMPILER_VERSION VERSION_EQUAL 8.0)
      list(APPEND CMAKE_${lang}_FLAGS -fno-tree-vrp -fno-inline -fno-tree-fre)
    endif()
  endif()
endforeach()
