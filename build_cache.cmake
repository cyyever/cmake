include_guard(GLOBAL)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)
find_package(ccache QUIET)
if(NOT ccache_FOUND)
  return()
endif()

set(ccacheEnv CCACHE_CPP2=true CCACHE_BASEDIR=${CMAKE_BINARY_DIR})

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
foreach(lang IN ITEMS C CXX CUDA)
  if(lang IN_LIST languages)
    set(CMAKE_${lang}_COMPILER_LAUNCHER ${CMAKE_COMMAND} -E env ${ccacheEnv}
                                        ${ccache_BINARY})
  endif()
endforeach()
