INCLUDE(${CMAKE_CURRENT_LIST_DIR}/compiler.cmake)

IF(${CMAKE_HOST_SYSTEM_NAME} EQUAL "Linux")
  #apt-get install extra-cmake-modules
  FIND_PACKAGE(ECM REQUIRED)
  LIST(APPEND CMAKE_MODULE_PATH "${ECM_MODULE_DIR}")

  #給測試增加llvm sanitizer
  include(ECMEnableSanitizers)
  #set(ECM_ENABLE_SANITIZERS 'address;leak;undefined')
  set(ECM_ENABLE_SANITIZERS 'undefined;leak')
ENDIF()
