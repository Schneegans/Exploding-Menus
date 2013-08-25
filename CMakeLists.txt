################################################################
# Project Prototype
################################################################

project("prototype" C)

cmake_minimum_required(VERSION 2.6)

# Location where cmake first looks for modules.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

################################################################
# Find Vala
################################################################

include(ValaPrecompile)
include(ValaVersion)

find_package(Vala)
ensure_vala_version("0.11.0" MINIMUM)

################################################################
# Configure and find libraries
################################################################

find_package(PkgConfig)

# check whether GTK3 is supported
pkg_check_modules(GTK3 gtk+-3.0)
pkg_check_modules(GIO REQUIRED gio-unix-2.0)
pkg_check_modules(CAIRO REQUIRED cairo)
pkg_check_modules(GEE REQUIRED gee-1.0)
pkg_check_modules(X11 REQUIRED x11)
pkg_check_modules(XTST REQUIRED xtst)
pkg_check_modules(JSON json-glib-1.0)

find_library(M_LIB m)
find_library(GTHREAD_LIB gthread-2.0)

set(CFLAGS
    ${GIO_CFLAGS}
    ${GTK3_CFLAGS} ${GTK3_CFLAGS_OTHER}
    ${CAIRO_CFLAGS} ${CAIRO_CFLAGS_OTHER}
    ${GEE_CFLAGS} ${CAIRO_CFLAGS_OTHER}
    ${X11_CFLAGS} ${X11_CFLAGS_OTHER}
	-s -O3 -w
#	-g
)

add_definitions(${CFLAGS})

set(LIBS
    ${GIO_LIBRARIES}
	${GTK3_LIBRARIES}
	${CAIRO_LIBRARIES}
	${GEE_LIBRARIES}
	${XTST_LIBRARIES}
	${X11_LIBRARIES}
	${M_LIB}
    ${GTHREAD_LIB}
	${JSON_LIBRARIES}
)
link_libraries(${LIBS})

set(LIB_PATHS
    ${GIO_LIBRARY_DIRS}
	${GTK2_LIBRARY_DIRS}
	${GTK3_LIBRARY_DIRS}
	${CAIRO_LIBRARY_DIRS}
	${GEE_LIBRARY_DIRS}
	${XTST_LIBRARY_DIRS}
    ${X11_LIBRARY_DIRS}
	${JSON_LIBRARY_DIRS}
)
link_directories(${LIB_PATHS})

set(INCLUDE_PATHS
    ${GIO_INCLUDE_DIRS}
	${GTK3_INCLUDE_DIRS}
	${CAIRO_INCLUDE_DIRS}
	${GEE_INCLUDE_DIRS}
	${XTST_INCLUDE_DIRS}
    ${X11_INCLUDE_DIRS}
	${JSON_INCLUDE_DIRS}
)
include_directories(${INCLUDE_PATHS})

################################################################
# Add executable
################################################################

set(EXECUTABLE_OUTPUT_PATH ${prototype_SOURCE_DIR})

set(VALA_PKGS
  cairo
  gee-1.0
  x11
  gio-unix-2.0
  posix
  xtst
  json-glib-1.0
)

LIST(APPEND VALA_PKGS gtk+-3.0)
LIST(APPEND VALA_PKGS gdk-x11-3.0)

add_subdirectory(src)

################################################################
# Summary
################################################################

message( "" )
message( "Summary:" )
message( "  EXECUTABLE_OUTPUT_PATH = ${EXECUTABLE_OUTPUT_PATH}" )
message( "  VALA_EXECUTABLE = ${VALA_EXECUTABLE}" )
message( "Libs:" )
message( "  GTK3_LIBRARIES = ${GTK3_LIBRARIES}" )
message( "  CAIRO_LIBRARIES = ${CAIRO_LIBRARIES}" )
message( "  GEE_LIBRARIES = ${GEE_LIBRARIES}" )
message( "  XTST_LIBRARIES = ${XTST_LIBRARIES}" )
message( "  X11_LIBRARIES = ${X11_LIBRARIES}" )
message( "" )
