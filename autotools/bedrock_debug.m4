AC_DEFUN([BEDROCK_DEBUG], [

    AC_MSG_CHECKING([[whether to enable bedrock debug]])

    AC_ARG_ENABLE([bedrock_debug],
        [[  --enable-bedrock_debug       configure bedrock config file for bedrock_debug, default: disabled]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  bedrock_debug_enabled=true  ;;
                no)   bedrock_debug_enabled=false ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--enable-bedrock_debug' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            bedrock_debug_enabled=false
        ]
    )

    if ${bedrock_debug_enabled}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([BEDROCK_DEBUG_ENABLED], [${bedrock_debug_enabled}])
])

