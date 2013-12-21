project (timeshift)

cmake_minimum_required (VERSION 2.6)

set (EXEC_NAME "timeshift")
set (RELEASE_NAME "A hello world.")
set (VERSION "0.1")
set (VERSION_INFO "Release")
set (GETTEXT_PACKAGE "timeshift")
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/timeshift")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

find_package (PkgConfig)
pkg_check_modules (DEPS REQUIRED gtk+-3.0 granite)

add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
include (ValaPrecompile)
ensure_vala_version ("0.16" MINIMUM)

# files we want to compile
vala_precompile (VALA_C ${EXEC_NAME}
    src/Settings/SavedState.vala
    src/config.vala
    src/View/AppToolbar.vala
    src/View/AppMenu.vala
    src/TimeShift.vala
# tell what libraries to use when compiling
PACKAGES
    gtk+-3.0 granite
)

add_executable (${EXEC_NAME} ${VALA_C})

include (GSettings)
add_schema ("schemas/fabien.timeshift.gschema.xml")

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/timeshift.desktop DESTINATION ${DATADIR}/applications/)
