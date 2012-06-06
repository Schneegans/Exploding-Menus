################################################################
# Actually compile the executable
################################################################

# determine source and header files
file(GLOB VALA_SRC RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.vala */*.vala)

if (${GTK3_FOUND})
  LIST(APPEND DEFINES --define HAVE_GTK_3)
endif(${GTK3_FOUND})

if (${GMENU3_FOUND})
    LIST(APPEND DEFINES --define HAVE_GMENU_3)
endif (${GMENU3_FOUND})

# use valac to compile sources to c files
vala_precompile(
    VALA_C
        ${VALA_SRC}
    PACKAGES
        ${VALA_PKGS}
    OPTIONS
        --vapidir=${CMAKE_SOURCE_DIR}/vapi/
        --thread
        ${DEFINES}
)

# compile c-sources
add_executable(prototype ${VALA_C})

