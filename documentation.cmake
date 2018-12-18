find_package(Doxygen)

if(DOXYGEN_FOUND AND NOT TARGET generate_document)
  add_custom_target(generate_document 
    COMMAND Doxygen::doxygen -g
    COMMAND sed -i -e "s@My Project@${CMAKE_PROJECT_NAME}@" Doxyfile
    COMMAND sed -i -e "s@^[[:space:]]*INPUT[[:space:]]*=.*@INPUT = ${CMAKE_SOURCE_DIR}/src@" Doxyfile
    COMMAND sed -i -e "s@^[[:space:]]*OUTPUT_DIRECTORY[[:space:]]*=.*@OUTPUT_DIRECTORY = ${CMAKE_BINARY_DIR}/doc@" Doxyfile
    COMMAND sed -i -e "s@^[[:space:]]*GENERATE_LATEX[[:space:]]*=.*@GENERATE_LATEX = NO@" Doxyfile
    COMMAND Doxygen::doxygen)
endif()
