#if(${CMAKE_VERSION} VERSION_GREATER "3.9.0" AND NOT MSVC)
#  cmake_policy(SET CMP0069 NEW)
#  include(CheckIPOSupported)
#  check_ipo_supported(RESULT result OUTPUT output)
#  if(result)
#    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
#  else()
#    message(WARNING "IPO is not supported: ${output}")
#  endif()
#endif()

SET(CMAKE_LINK_WHAT_YOU_USE TRUE)
