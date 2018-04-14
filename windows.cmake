IF (NOT WIN32)
  return()
endif()

#統一安裝目錄，免得不斷設置path環境變量
set(CMAKE_INSTALL_PREFIX "C:/deepir" CACHE PATH "default install path" FORCE )

#保证测试代码能找到dll
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

#默認構建動態庫
SET(BUILD_SHARED_LIBS TRUE)

SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
