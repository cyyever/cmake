# - Try to find TensorFlow
#
# The following variables are optionally searched for defaults
#  TensorFlow_DIR:            Base directory where all TensorFlow components are found
#
# The following are set after configuration is done:
#  TENSORFLOW_FOUND
#  TensorFlow_INCLUDE_DIRS
#  TensorFlow_LIBRARIES

include(FindPackageHandleStandardArgs)

set(TensorFlow_DIR "" CACHE PATH "Folder contains TensorFlow")

if(TensorFlow_DIR STREQUAL "")
  unset(TensorFlow_DIR CACHE)
  find_path(TensorFlow_DIR NAMES tensorflow PATHS /opt/tensorflow)
endif()

find_path(TensorFlow_PB_INCLUDE_DIR NAMES tensorflow PATHS ${TensorFlow_DIR}/bazel-genfiles)

find_library(TensorFlow_LIBRARY NAMES tensorflow_cc PATHS ${TensorFlow_DIR}/bazel-bin/tensorflow)

EXECUTE_PROCESS(COMMAND bazel info output_base WORKING_DIRECTORY ${TensorFlow_DIR} OUTPUT_VARIABLE OUTPUT_BASE OUTPUT_STRIP_TRAILING_WHITESPACE)

set(TensorFlow_INCLUDE_DIR ${TensorFlow_PB_INCLUDE_DIR} ${TensorFlow_DIR} ${OUTPUT_BASE}/external/eigen_archive)

find_package_handle_standard_args(TensorFlow DEFAULT_MSG TensorFlow_INCLUDE_DIR TensorFlow_LIBRARY)

if(TENSORFLOW_FOUND)
    set(TensorFlow_INCLUDE_DIRS ${TensorFlow_INCLUDE_DIR})
    set(TensorFlow_LIBRARIES ${TensorFlow_LIBRARY} )
endif()
