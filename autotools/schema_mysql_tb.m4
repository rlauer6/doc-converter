AC_DEFUN([SCHEMA_MYSQL_TREASURERSBRIEFCASE], [


    session_db=tb_master
    AC_ARG_WITH(
	[session-db], [  --with-session-db=DB, default: tb_master],
	[session_db=$withval]
    )

    AC_SUBST([session_db])

    session_username=tb-admin
    AC_ARG_WITH(
	[session-username], [  --with-session-username=USERNAME, default: tb-admin],
	[session_username=$withval]
    )

    AC_SUBST([session_username])

    session_password=Br1efca5e
    AC_ARG_WITH(
	[session-password], [  --with-session-password=PASSWORD],
	[session_password=$withval]
    )

    AC_SUBST([session_password])

    session_tablename=session
    AC_ARG_WITH(
	[session-tablename], [  --with-session-tablename=NAME],
	[session_tablename=$withval]
    )

    AC_SUBST([session_tablename])

    amazon_rds_server=treasurersbriefcase.com
    
    AC_ARG_WITH(
	[rds-server], [  --with-rds-server=HOST, default: treasurersbriefcase.com],
	[amazon_rds_server=$withval]
    )

    AC_SUBST([amazon_rds_server])
])
