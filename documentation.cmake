LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/module)

FIND_PACKAGE(doxygen)

ADD_CUSTOM_TARGET(doc COMMAND ${doxygen_BINARY} -g && sed -i -e "s@My Project@${CMAKE_PROJECT_NAME}@" Doxyfile && sed -i -e "s@^INPUT[[:space:]]*=.*@INPUT = ${CMAKE_CURRENT_LIST_DIR}/src@" Doxyfile && ${doxygen_BINARY})
