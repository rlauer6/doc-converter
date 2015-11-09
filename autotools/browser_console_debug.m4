AC_DEFUN([BROWSER_CONSOLE_DEBUG], [

    AC_MSG_CHECKING([[whether to enable browser console debugging messages]])

    AC_ARG_ENABLE([browser_console_debug],
        [[  --enable-browser_console_debug       configure bedrock config file for browser_console_debug, default: disabled]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  browser_console_debug_enabled=true  ;;
                no)   browser_console_debug_enabled=false ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--enable-browser_console_debug' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            browser_console_debug_enabled=false
        ]
    )

    if ${browser_console_debug_enabled}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([BROWSER_CONSOLE_DEBUG_ENABLED], [${browser_console_debug_enabled}])
])

