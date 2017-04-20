PROJECT(Test CXX)
cmake_minimum_required(VERSION 2.8)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
CONAN_BASIC_SETUP()

find_package(LibreSSL)

IF(LIBRESSL_FOUND)
    include_directories(${LIBRESSL_INCLUDE_DIRS})
    ADD_EXECUTABLE(md5 md5.cpp)
    TARGET_LINK_LIBRARIES(md5 ${LIBRESSL_LIBRARIES})
ELSE()
    MESSAGE(FATAL_ERROR "ERROR! LIBRESSL NOT FOUND!")
ENDIF()