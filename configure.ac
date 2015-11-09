AC_INIT([doc-converter], [1.0.0], [rlauer6@comcast.net])

__poor_mans_expand_file_name () {
    _tmp_name=$1
    _tmp_last="`eval echo '${'"${_tmp_name}"'}'`"
    if test -z "${_tmp_last}"; then
        printf "__poor_mans_expand_file_name() (WARNING): var \"%s\" is empty\n" \
          "${_tmp_name}" 1>&2
        return 0;  # nothing to do
    fi
    _tmp_last_expanded="`eval echo ${_tmp_last}`"
    while test "${_tmp_last_expanded}" != "${_tmp_last}"; do

        # Set 'last' hold var to most recently expanded version...
        _tmp_last="${_tmp_last_expanded}"

        # ...and try to expand further.
        _tmp_last_expanded="`eval echo ${_tmp_last_expanded}`"
    done
    printf "%s\n" "${_tmp_last_expanded}"
    unset _tmp_last_expanded
    unset _tmp_last
    unset _tmp_name
    return 0;
}

[
do_subst_command='do_subst = sed \
  -e '"'"'s,[@]PACKAGE[@],$(PACKAGE),g'"'"' \
  -e '"'"'s,[@]PACKAGE_VERSION[@],$(PACKAGE_VERSION),g'"'"' \
  -e '"'"'s,[@]VERSION[@],$(VERSION),g'"'"' \
  -e '"'"'s,[@]PATH_SEPARATOR[@],$(PATH_SEPARATOR),g'"'"' \
  -e '"'"'s~[@]configure_input[@]~Generated from $@.in; do not edit by hand.~g'"'"' \
  -e "s,[@]BUILD_DATE[@],$$(date '"'"'+%Y-%m-%d %H:%M:%S'"'"'),g" \
  \
  -e '"'"'s,[@]bindir[@],$(bindir),g'"'"' \
  -e '"'"'s,[@]datadir[@],$(datadir),g'"'"' \
  -e '"'"'s,[@]exec_prefix[@],$(exec_prefix),g'"'"' \
  -e '"'"'s,[@]includedir[@],$(includedir),g'"'"' \
  -e '"'"'s,[@]infodir[@],$(infodir),g'"'"' \
  -e '"'"'s,[@]libdir[@],$(libdir),g'"'"' \
  -e '"'"'s,[@]libexecdir[@],$(libexecdir),g'"'"' \
  -e '"'"'s,[@]localstatedir[@],$(localstatedir),g'"'"' \
  -e '"'"'s,[@]mandir[@],$(mandir),g'"'"' \
  -e '"'"'s,[@]oldincludedir[@],$(oldincludedir),g'"'"' \
  -e '"'"'s,[@]prefix[@],$(prefix),g'"'"' \
  -e '"'"'s,[@]sbindir[@],$(sbindir),g'"'"' \
  -e '"'"'s,[@]sharedstatedir[@],$(sharedstatedir),g'"'"' \
  -e '"'"'s,[@]sysconfdir[@],$(sysconfdir),g'"'"' \
  -e '"'"'s,[@]spooldir[@],$(spooldir),g'"'"' \
  \
  -e '"'"'s,[@]abs_builddir[@],$(abs_builddir),g'"'"' \
  -e '"'"'s,[@]abs_srcdir[@],$(abs_srcdir),g'"'"' \
  -e '"'"'s,[@]abs_top_builddir[@],$(abs_top_builddir),g'"'"' \
  -e '"'"'s,[@]abs_top_srcdir[@],$(abs_top_srcdir),g'"'"' \
  -e '"'"'s,[@]srcdir[@],$(srcdir),g'"'"' \
  -e '"'"'s,[@]top_builddir[@],$(top_builddir),g'"'"' \
  -e '"'"'s,[@]top_srcdir[@],$(top_srcdir),g'"'"' \
\
  -e '"'"'s,[@]ax_perl5_extra_includes[@],$(ax_perl5_extra_includes),g'"'"' \
  -e '"'"'s,[@]ax_perl5_extra_includes_opt[@],$(ax_perl5_extra_includes_opt),g'"'"' \
  -e '"'"'s,[@]perl5libdir[@],$(perl5libdir),g'"'"' \
  -e '"'"'s,[@]perlrun[@],$(perlrun),g'"'"' \
  -e '"'"'s,[@]bashrun[@],$(bashrun),g'"'"' \
  -e '"'"'s,[@]BASHRUN[@],$(BASHRUN),g'"'"' \
  -e '"'"'s,[@]ksh[@],$(ksh),g'"'"' \
  -e '"'"'s,[@]logdir[@],$(logdir),g'"'"' \
\
  -e '"'"'s,[@]soffice[@],$(soffice),g'"'"' \
\
  -e '"'"'s,[@]apache_user[@],$(apache_user),g'"'"' \
  -e '"'"'s,[@]apache_group[@],$(apache_group),g'"'"' \
  -e '"'"'s,[@]apache_sitedir[@],$(apache_sitedir),g'"'"' \
  -e '"'"'s,[@]apache_site_logdir[@],$(apache_site_logdir),g'"'"' \
  -e '"'"'s,[@]apache_site_configdir[@],$(apache_site_configdir),g'"'"' \
  -e '"'"'s,[@]apache_site_config_ddir[@],$(apache_site_config_ddir),g'"'"' \
  -e '"'"'s,[@]apache_site_cgibindir[@],$(apache_site_cgibindir),g'"'"' \
  -e '"'"'s,[@]apache_site_htdocsdir[@],$(apache_site_htdocsdir),g'"'"' \
  -e '"'"'s,[@]apache_site_imgdir[@],$(apache_site_imgdir),g'"'"' \
  -e '"'"'s,[@]apache_site_cssdir[@],$(apache_site_cssdir),g'"'"' \
  -e '"'"'s,[@]apache_site_javascriptdir[@],$(apache_site_javascriptdir),g'"'"' \
  -e '"'"'s,[@]apache_site_workdir[@],$(apache_site_workdir),g'"'"' \
  -e '"'"'s,[@]apache_site_spooldir[@],$(apache_site_spooldir),g'"'"' \
  -e '"'"'s,[@]apache_site_sessiondir[@],$(apache_site_sessiondir),g'"'"' \
  -e '"'"'s,[@]apache_site_cachedir[@],$(apache_site_cachedir),g'"'"' \
  -e '"'"'s,[@]apache_site_perl5libdir[@],$(apache_site_perl5libdir),g'"'"' \
  -e '"'"'s,[@]apache_cgi_symlinks[@],$(apache_cgi_symlinks),g'"'"' \
\
  -e '"'"'s,[@]apache_site_work_dir[@],$(apache_site_work_dir),g'"'"' \
  -e '"'"'s,[@]apache_site_spool_dir[@],$(apache_site_spool_dir),g'"'"' \
\
  -e '"'"'s,[@]apache_site_reportsdir[@],$(apache_site_reportsdir),g'"'"' \
  -e '"'"'s,[@]apache_vhost_dir[@],$(apache_vhost_dir),g'"'"' \
  -e '"'"'s,[@]apache_vhost_confdir[@],$(apache_vhost_confdir),g'"'"' \
  -e '"'"'s,[@]apache_vhost_domain[@],$(apache_vhost_domain),g'"'"' \
  -e '"'"'s,[@]apache_vhost_server[@],$(apache_vhost_server),g'"'"' \
  -e '"'"'s,[@]apache_vhost_alias[@],$(apache_vhost_alias),g'"'"' \
'
]

AC_SUBST([do_subst_command])

AC_CONFIG_AUX_DIR([autotools])
AC_CONFIG_MACRO_DIR([autotools])

AM_INIT_AUTOMAKE([-Wall -Werror -Wno-override foreign tar-ustar])

DFLT_MAINTAINER="rlauer6@comcast.net"
AC_SUBST([DFLT_MAINTAINER])

dnl AC_REVISION puts cvs revision in comment at top of generated 'configure'
AC_REVISION([$Revision: 1.3 $])

if ! test -e release; then
 PROJECT_RELEASE="0"
else
  PROJECT_RELEASE=$(cat release)
fi

AC_SUBST([PROJECT_RELEASE])

AC_PATH_PROG([PERL], [perl])

if test -z "$PERL" ; then 
  AC_MSG_ERROR([perl not found?])
fi

x=$(perl -e 'use Config qw/config_vars/; config_vars('installsitelib');'); eval $x;
perl5libdir=$installsitelib

echo "perl5libdir " $perl5libdir
AC_ARG_WITH(
        [perl5libdir],[  --with-perl5libdir (defaults to [installsitelib])],
        [
    if test "${withval}" = 'no'; then
        true
    elif test "$withval" = 'yes'; then
        perl5libdir=$($PERL -MConfig -wle 'print $Config{sitelib};')
    else
        perl5libdir=$withval    
    fi
        ]
)
	
AC_SUBST([perl5libdir])

AC_PATH_PROG([BASHRUN],
	[bash])

if test -z "$BASHRUN" ; then 
  AC_MSG_ERROR([bash not found?])
fi

AC_ARG_ENABLE([distcheck-hack],
     [  --enable-distcheck-hack indicate that a distcheck is being done],
     [case "${enableval}" in
       yes) hack=true ;;
       no)  hack=false ;;
       *) AC_MSG_ERROR([bad value ${enableval} for --enable-distcheck-hack]) ;;
     esac],[hack=false])
     AM_CONDITIONAL([DISTCHECK_HACK], [test x$hack = xtrue])

AC_ARG_WITH( [libreofficedir], [  --with-libreofficedir ], [libreofficedir=$withval])

AC_SUBST([libreofficedir])

RPM_BUILD_MODE

APACHE_CONFIG

ads_PERL_MODULE([Amazon::S3], [OPTIONAL])

AC_CONFIG_FILES([
    Makefile
    config/Makefile
    cloudformation/Makefile
    src/Makefile
    src/main/Makefile
    src/main/bash/Makefile
    src/main/bash/bin/Makefile
    src/main/perl/Makefile
    src/main/perl/bin/Makefile
    src/main/perl/cgi-bin/Makefile
    src/main/perl/lib/Makefile
    ${PACKAGE_NAME}.spec
])

AC_OUTPUT

printf "${PACKAGE} has been configured with the following options:\n"
printf "                        Prefix: %s\n" "`__poor_mans_expand_file_name prefix`"
printf "                 User binaries: %s\n" "`__poor_mans_expand_file_name bindir`"
printf "               System binaries: %s\n" "`__poor_mans_expand_file_name sbindir`"
printf "           Configuration files: %s\n" "`__poor_mans_expand_file_name sysconfdir`"
printf "              Localstate files: %s\n" "`__poor_mans_expand_file_name localstatedir`"
printf "                  Manual pages: %s\n" "`__poor_mans_expand_file_name mandir`"
printf "\n"
printf "            Document Converter:\n"
printf "                libreofficedir: %s\n" "`__poor_mans_expand_file_name libreofficedir`"
printf "\n"
printf "          Apache Configuration:\n"
printf "              apache_vhost_dir: %s\n" "`__poor_mans_expand_file_name apache_vhost_dir`"

if test -z "$apache_vhost_domain"; then
printf "           apache_vhost_domain: %s\n" "none"
else
printf "           apache_vhost_domain: %s\n" "`__poor_mans_expand_file_name apache_vhost_domain`"
fi

if test -z "$apache_vhost_server"; then
printf "           apache_vhost_server: %s\n" "none"
else
printf "           apache_vhost_server: %s\n" "`__poor_mans_expand_file_name apache_vhost_server`"
fi

printf "               apache_confddir: %s\n" "`__poor_mans_expand_file_name apache_confddir`"
printf "                   apache_user: %s\n" "`__poor_mans_expand_file_name apache_user`"
printf "                  apache_group: %s\n" "`__poor_mans_expand_file_name apache_group`"
printf "\n"

printf "            Perl Configuration:\n"
printf "                          perl: %s\n" "`__poor_mans_expand_file_name PERL`"
printf "\n"
