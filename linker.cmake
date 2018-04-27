include(CheckIPOSupported)
check_ipo_supported(RESULT result OUTPUT output LANGUAGES C CXX)
if(result)
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
else()
  message(WARNING "IPO is not supported: ${output}")
endif()

SET(CMAKE_LINK_WHAT_YOU_USE TRUE)
