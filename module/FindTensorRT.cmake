# - Try to find TensorRT
#
# The following variables are optionally searched for defaults
#  TensorRT_DIR:            Base directory where all TensorRT components are found
#
# The following are set after configuration is done:
#  TENSORRT_FOUND
#  TensorRT_INCLUDE_DIRS
#  TensorRT_LIBRARIES

include(FindPackageHandleStandardArgs)

set(TensorRT_DIR "" CACHE PATH "Folder contains TensorRT")

if(TensorRT_DIR STREQUAL "")
  unset(TensorRT_DIR CACHE)
  find_path(TensorRT_DIR NAMES tensorRT PATHS /opt)
  find_package_handle_standard_args(TensorRT DEFAULT_MSG TensorRT_DIR)
  if(TENSORRT_FOUND)
    set(TensorRT_DIR "${TensorRT_DIR}/tensorRT")
    set(TensorRT_DIR "${TensorRT_DIR}" CACHE PATH "Folder contains TensorRT")
  endif()
endif()


find_library(nvcaffe_parser_LIBRARY NAMES nvcaffe_parser PATHS ${TensorRT_DIR}/lib)
find_library(nvinfer_LIBRARY NAMES nvinfer PATHS ${TensorRT_DIR}/lib)
find_library(nvinfer_plugin_LIBRARY NAMES nvinfer_plugin PATHS ${TensorRT_DIR}/lib)
find_path(TensorRT_INCLUDE_DIR NAMES NvInfer.h PATHS ${TensorRT_DIR}/include)

find_package_handle_standard_args(TensorRT DEFAULT_MSG TensorRT_INCLUDE_DIR nvcaffe_parser_LIBRARY nvinfer_LIBRARY nvinfer_plugin_LIBRARY)

if(TENSORRT_FOUND)
  set(TensorRT_INCLUDE_DIRS ${TensorRT_INCLUDE_DIR})
  set(TensorRT_LIBRARIES ${nvcaffe_parser_LIBRARY} ${nvinfer_LIBRARY} ${nvinfer_plugin_LIBRARY})
endif()
