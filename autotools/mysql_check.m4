dnl -*-m4-*-
dnl 
dnl ##
dnl ## $Id: mysql_check.m4,v 1.1.1.1 2011/11/13 14:51:02 rlauer Exp $
dnl ##
dnl 
dnl This file provides the 'MYSQL_CHECK' autoconf macro, which may be
dnl used to add checks in your 'configure.ac' file for 'mysql'
dnl 
dnl By default, the mysql client package is "required"; if it is not found,
dnl the 'configure' program will print an error message and exit with an
dnl error status (via AC_MSG_ERROR). However, you may pass a parameter
dnl indicating that the module is optional; in that case 'configure' will
dnl simply print a message indicating that the module was not found and
dnl continue on.
dnl 
dnl An automake conditional MYSQL_FOUND will be set if the mysql client programs
dnl 'mysql' and 'mysqladmin' are found.  You can use this conditional in your
dnl Makefile.am files.  For example:
dnl 
dnl if MYSQL_FOUND
dnl MAYBE_MYSQL = mysql
dnl endif
dnl
dnl Dependencies
dnl ============
dnl 
dnl None
dnl 
dnl Usage
dnl =====
dnl 
dnl MYSQL_CHECK([REQUIRED|OPTIONAL])
dnl
dnl  The default is for the mysql client package to be REQUIRED
dnl
AC_DEFUN([MYSQL_CHECK],[
    required=$1
    if test -z "$required"; then
       required="REQUIRED"
    fi

    AC_PATH_PROG([mysql],
        [mysql])
    if test -z "$mysql" ; then
        if test "$required" =  "REQUIRED"; then
            AC_MSG_ERROR([mysql not found? You might want to check this.])
        else
            AC_MSG_WARN([mysql not found? You might want to check this.])
        fi
    fi

    AC_PATH_PROG([mysqladmin],
        [mysqladmin])

    if test -z "$mysqladmin" ; then
        if test "$required" =  "REQUIRED"; then
            AC_MSG_ERROR([mysqladmin not found? You might want to check this.])
	    else
            AC_MSG_WARN([mysqladmin not found? You might want to check this.])
        fi
    fi

    AM_CONDITIONAL([MYSQL_FOUND], [test -n "$mysql$" && test -n "$mysqladmin"])
])
