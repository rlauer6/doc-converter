AC_DEFUN([AX_MOD_PERL], [

    AC_MSG_CHECKING([[whether to enable mod_perl]])

    AC_ARG_ENABLE([mod_perl],
        [[  --enable-mod_perl       configure virtual host config file for mod_perl, default: enabled]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  ax_mod_perl_enabled=true  ;;
                no)   ax_mod_perl_enabled=false ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--enable-mod_perl' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            ax_mod_perl_enabled=true
        ]
    )

    if ${ax_mod_perl_enabled}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([MOD_PERL_ENABLED], [${ax_mod_perl_enabled}])
])

