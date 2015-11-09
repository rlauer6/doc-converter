AC_DEFUN([GOOGLE_ANALYTICS], [

    AC_MSG_CHECKING([[whether to enable google analytics]])

    AC_ARG_ENABLE([google_analytics],
        [[  --enable-google_analytics       configure bedrock config file for google_analytics, default: enabled]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  google_analytics_enabled=true  ;;
                no)   google_analytics_enabled=false ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--enable-google_analytics' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            google_analytics_enabled=true
        ]
    )

    if ${google_analytics_enabled}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([GOOGLE_ANALYTICS_ENABLED], [${google_analytics_enabled}])
])

