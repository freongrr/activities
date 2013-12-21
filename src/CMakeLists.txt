# Sources
vala_precompile(VALA_C
    *.vala
    Settings/*.vala
    View/*.vala
    config.vala
PACKAGES
    ${TIMESHIFT_DEPS}
    posix
)

# Executable
add_executable (timeshift ${VALA_C})
install(TARGETS timeshift RUNTIME DESTINATION bin)
