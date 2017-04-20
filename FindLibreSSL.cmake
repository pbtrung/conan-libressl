#=============================================================================
# Copyright 2006-2009 Kitware, Inc.
# Copyright 2006 Alexander Neundorf <neundorf@kde.org>
# Copyright 2009-2011 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)


MESSAGE(STATUS "********* Conan FindLibreSSL wrapper! **********")

SET(LIBRESSL_ROOT_DIR ${CONAN_LIBRESSL_ROOT})
SET(LIBRESSL_INCLUDE_DIR ${CONAN_INCLUDE_DIRS_LIBRESSL})

include(FindPackageHandleStandardArgs)
FOREACH(THELIB ${CONAN_LIBS_LIBRESSL})
    IF(NOT ${THELIB} MATCHES "ssl" AND NOT ${THELIB} MATCHES "crypto")
        find_library(LIB_${THELIB} NAMES ${THELIB} PATHS ${CONAN_LIB_DIRS_LIBRESSL})
    ELSE()
        find_library(LIB_${THELIB} NAMES ${THELIB} PATHS ${CONAN_LIB_DIRS_LIBRESSL} NO_DEFAULT_PATH)
    ENDIF()

    IF(${THELIB} MATCHES "ssl")
        set(LIBRESSL_SSL_LIBRARY ${LIB_${THELIB}})
    ENDIF()
    IF(${THELIB} MATCHES "crypto")
        set(LIBRESSL_CRYPTO_LIBRARY ${LIB_${THELIB}})
    ENDIF()
    IF(NOT ${LIB_${THELIB}} MATCHES "NOTFOUND")
        set(LIBRESSL_LIBRARIES ${LIBRESSL_LIBRARIES} ${LIB_${THELIB}})
    ENDIF()
ENDFOREACH()
MESSAGE(${LIBRESSL_LIBRARIES})

function(from_hex HEX DEC)
  string(TOUPPER "${HEX}" HEX)
  set(_res 0)
  string(LENGTH "${HEX}" _strlen)

  while (_strlen GREATER 0)
    math(EXPR _res "${_res} * 16")
    string(SUBSTRING "${HEX}" 0 1 NIBBLE)
    string(SUBSTRING "${HEX}" 1 -1 HEX)
    if (NIBBLE STREQUAL "A")
      math(EXPR _res "${_res} + 10")
    elseif (NIBBLE STREQUAL "B")
      math(EXPR _res "${_res} + 11")
    elseif (NIBBLE STREQUAL "C")
      math(EXPR _res "${_res} + 12")
    elseif (NIBBLE STREQUAL "D")
      math(EXPR _res "${_res} + 13")
    elseif (NIBBLE STREQUAL "E")
      math(EXPR _res "${_res} + 14")
    elseif (NIBBLE STREQUAL "F")
      math(EXPR _res "${_res} + 15")
    else()
      math(EXPR _res "${_res} + ${NIBBLE}")
    endif()

    string(LENGTH "${HEX}" _strlen)
  endwhile()

  set(${DEC} ${_res} PARENT_SCOPE)
endfunction()


if (LIBRESSL_INCLUDE_DIR)
  if(LIBRESSL_INCLUDE_DIR AND EXISTS "${LIBRESSL_INCLUDE_DIR}/openssl/opensslv.h")
    file(STRINGS "${LIBRESSL_INCLUDE_DIR}/openssl/opensslv.h" libressl_version_str
         REGEX "^#[\t ]*define[\t ]+LIBRESSL_VERSION_NUMBER[\t ]+0x([0-9a-zA-Z])+.*")

    string(REGEX REPLACE "^.*LIBRESSL_VERSION_NUMBER[\t ]+0x([0-9a-zA-Z])([0-9a-zA-Z][0-9a-zA-Z])([0-9a-zA-Z][0-9a-zA-Z])([0-9a-zA-Z][0-9a-zA-Z])([0-9a-zA-Z]).*$"
           "\\1;\\2;\\3;\\4;\\5" LIBRESSL_VERSION_LIST "${libressl_version_str}")
    list(GET LIBRESSL_VERSION_LIST 0 LIBRESSL_VERSION_MAJOR)
    list(GET LIBRESSL_VERSION_LIST 1 LIBRESSL_VERSION_MINOR)
    from_hex("${LIBRESSL_VERSION_MINOR}" LIBRESSL_VERSION_MINOR)
    list(GET LIBRESSL_VERSION_LIST 2 LIBRESSL_VERSION_FIX)
    from_hex("${LIBRESSL_VERSION_FIX}" LIBRESSL_VERSION_FIX)
    list(GET LIBRESSL_VERSION_LIST 3 LIBRESSL_VERSION_PATCH)

    if (NOT LIBRESSL_VERSION_PATCH STREQUAL "00")
      from_hex("${LIBRESSL_VERSION_PATCH}" _tmp)
      math(EXPR LIBRESSL_VERSION_PATCH_ASCII "${_tmp} + 96")
      unset(_tmp)
      string(ASCII "${LIBRESSL_VERSION_PATCH_ASCII}" LIBRESSL_VERSION_PATCH_STRING)
    endif ()

    set(LIBRESSL_VERSION "${LIBRESSL_VERSION_MAJOR}.${LIBRESSL_VERSION_MINOR}.${LIBRESSL_VERSION_FIX}${LIBRESSL_VERSION_PATCH_STRING}")
  endif ()
endif ()

find_package_handle_standard_args(LibreSSL
  REQUIRED_VARS
    LIBRESSL_LIBRARIES
    LIBRESSL_INCLUDE_DIR
  VERSION_VAR
    LIBRESSL_VERSION
  FAIL_MESSAGE
    "Could NOT find LibreSSL, try to set the path to LibreSSL root folder in the system variable LIBRESSL_ROOT_DIR"
)

mark_as_advanced(
    LIBRESSL_ROOT_DIR
    LIBRESSL_INCLUDE_DIR
    LIBRESSL_LIBRARIES
)
