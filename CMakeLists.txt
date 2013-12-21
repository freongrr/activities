project(timeshift)
set(RELEASE_NAME "Time Shift time tracker.")
set(VERSION "0.1")
set(VERSION_INFO "Release")
set(DATADIR "${CMAKE_INSTALL_PREFIX}/share/timeshift")
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# First checks
cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)
find_package(Vala REQUIRED)
find_package(PkgConfig)

# Some configuration
configure_file(${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)

# Vala
include(ValaVersion)
include(ValaPrecompile)
ensure_vala_version ("0.22" MINIMUM)

# Dependencies
set(TIMESHIFT_DEPS gtk+-3.0 granite)

pkg_check_modules(GTK+ REQUIRED "gtk+-3.0 >= 3.10")
pkg_check_modules(DEPS REQUIRED ${TIMESHIFT_DEPS})

add_definitions(${DEPS_CFLAGS})
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
add_definitions(-DVALA_VERSION="${VALA_SHORTVER}")
add_definitions(-w) # Disable gcc warnings

link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

include_directories(${CMAKE_BINARY_DIR}/src)

# Sources
vala_precompile(VALA_C
    src/TimeShift.vala
    src/Settings/SavedState.vala
    src/View/AppToolbar.vala
    src/View/AppMenu.vala
    src/config.vala
PACKAGES
    ${TIMESHIFT_DEPS}
)

# Executable
add_executable (timeshift ${VALA_C})

# Installation
install(TARGETS timeshift RUNTIME DESTINATION bin)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/timeshift.desktop DESTINATION share/applications)
