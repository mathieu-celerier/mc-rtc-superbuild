if(NOT "$ENV{PATH}" MATCHES "${CMAKE_INSTALL_PREFIX}/bin")
  if(WIN32)
    set(PATH_SEP ";")
  else()
    set(PATH_SEP ":")
  endif()
  set(ENV{PATH} "${CMAKE_INSTALL_PREFIX}/bin${PATH_SEP}$ENV{PATH}")
endif()

if(APPLE)
  if(NOT "$ENV{DYLD_LIBRARY_PATH}" MATCHES "${CMAKE_INSTALL_PREFIX}/lib")
    set(ENV{DYLD_LIBRARY_PATH} "${CMAKE_INSTALL_PREFIX}/lib:$ENV{DYLD_LIBRARY_PATH}")
  endif()
elseif(UNIX)
  if(NOT "$ENV{LD_LIBRARY_PATH}" MATCHES "${CMAKE_INSTALL_PREFIX}/lib")
    set(ENV{LD_LIBRARY_PATH} "${CMAKE_INSTALL_PREFIX}/lib:$ENV{LD_LIBRARY_PATH}")
  endif()
endif()
