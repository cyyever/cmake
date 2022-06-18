include_guard(GLOBAL)
option(WITH_IPO "enable IPO" OFF)
if(NOT WITH_IPO)
  return()
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
include(CheckIPOSupported)
set(c_family)
if("C" IN_LIST languages)
  list(APPEND c_family "C")
endif()
if("CXX" IN_LIST languages)
  list(APPEND c_family "CXX")
endif()
check_ipo_supported(
  RESULT result
  OUTPUT output
  LANGUAGES ${c_family})
if(result)
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
else()
  message(ERROR "IPO is not supported: ${output}")
endif()
