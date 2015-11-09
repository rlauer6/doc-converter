AC_DEFUN([SCHEMA_MYSQL_SESSION], [

    AC_ARG_WITH(
    	[session-db],[  --with-session-db=dbname, example: bedrock, default: bedrock],
    	[SESSION_DB=$withval],
        [SESSION_DB=bedrock]
    )
    
    AC_SUBST([SESSION_DB])
    
    AC_ARG_WITH(
    	[session-username],[  --with-session-username=USER],
    	[SESSION_USERNAME=$withval],
        [SESSION_USERNAME=fred]
    )
    
    AC_SUBST([SESSION_USERNAME])
    
    AC_ARG_WITH(
    	[session-password],[  --with-session-password=PASSWORD],
    	[SESSION_PASSWORD=$withval],
        [SESSION_PASSWORD=flintstone]
    )
    
    AC_SUBST([SESSION_PASSWORD])
    
    AC_ARG_WITH(
    	[session-tablename],[  --with-session-tablename=NAME],
    	[SESSION_TABLENAME=$withval],
        [SESSION_TABLENAME=session]
    )
    
    AC_SUBST([SESSION_TABLENAME])
       
])
