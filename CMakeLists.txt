project (activities)

cmake_minimum_required (VERSION 2.6)

set (EXEC_NAME "activities")
set (RELEASE_NAME "Track activies and the time you spend.")
set (VERSION "0.1")
set (VERSION_INFO "Release")
set (GETTEXT_PACKAGE "activities")
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/activities")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set (DEPENDENCIES gtk+-3.0 granite gee-1.0 libsoup-2.4 json-glib-1.0)

find_package (PkgConfig)
pkg_check_modules (DEPS REQUIRED ${DEPENDENCIES})

add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
include (ValaPrecompile)
ensure_vala_version ("0.20" MINIMUM)

# TODO : enable that
#SET(VALA_COMPILE_FLAGS "--enable-experimental-non-null")
#SET(VALA_COMPILE_FLAGS --enable-checking --fatal-warnings)
#SET(VALA_COMPILE_FLAGS_DEBUG -X -ggdb3)

configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)

link_libraries (m)

# files we want to compile
vala_precompile (VALA_C ${EXEC_NAME}
    src/Activities.vala
    src/config.vala
    src/Model/ActivityStore.vala
    src/Model/Activity.vala
    src/Model/Backend.vala
    src/Model/DummyBackend.vala
    src/Model/DummySerializer.vala
    src/Model/JIRABackend.vala
    src/Model/JIRADeserializer.vala
    src/Model/ProjectManager.vala
    src/Model/Project.vala
    src/Model/RemoteBackend.vala
    src/Model/Serializer.vala
    src/Model/Task.vala
    src/Settings/ProjectDefinitions.vala
    src/Settings/SavedState.vala
    src/Utils/UrlBuilder.vala
    src/View/ActivityCellRenderer.vala
    src/View/ActivityForm.vala
    src/View/ActivityList.vala
    src/View/AppMenu.vala
    src/View/AppToolbar.vala
    src/View/DateTimePicker.vala
    src/View/MainWindow.vala
    PACKAGES ${DEPENDENCIES}
    OPTIONS ${VALA_COMPILE_FLAGS}
)

add_executable (${EXEC_NAME} ${VALA_C})

include (GSettings)
add_schema ("schemas/lp.fabien.cortina.activities.gschema.xml")

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/activities.desktop DESTINATION ${DATADIR}/applications/)