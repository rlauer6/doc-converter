crondir       = /etc/cron.d
logrotatedir  = /etc/logrotate.d
init_ddir     = /etc/init.d

doc_converterdir = $(datadir)/doc-converter

soffice       = $(libreofficedir)/program/soffice

# Apache Virtual Host configuration file name
apache_vhost_config = @apache_vhost_config@

# Apache Virtual Host Alias
apache_vhost_alias  = @apache_vhost_alias@

# domain/server name
apache_vhost_domain  = @apache_vhost_domain@
apache_vhost_server  = @apache_vhost_server@

# Apache Virtual Host configurtation directory
apache_confdir = @apache_confdir@
apache_confddir = @apache_confddir@

apache_vhost_confdir = @apache_vhost_confdir@/vhosts

# Apache Virtual Host site directories
apache_vhost_dir          = @apache_vhost_dir@
apache_sitedir            = $(apache_vhost_dir)/$(apache_vhost_server)
apache_site_cachedir      = $(apache_sitedir)/cache
apache_site_cgibindir     = $(apache_sitedir)/cgi-bin
apache_site_configdir     = $(apache_sitedir)/config
apache_site_htdocsdir     = $(apache_sitedir)/htdocs
apache_site_imgdir        = $(apache_sitedir)/htdocs/img
apache_site_javascriptdir = $(apache_sitedir)/htdocs/javascript
apache_site_cssdir        = $(apache_sitedir)/htdocs/css
apache_site_admindir      = $(apache_sitedir)/htdocs/admin
apache_site_includedir    = $(apache_sitedir)/include
apache_site_logdir        = $(apache_sitedir)/logs
apache_site_pebblesdir    = $(apache_sitedir)/pebbles
apache_site_reportsdir    = $(apache_sitedir)/reports
apache_site_sessiondir    = $(apache_sitedir)/session
apache_site_spooldir      = $(apache_sitedir)/spool
apache_site_workdir       = $(apache_sitedir)/work
apache_site_perl5libdir   = $(apache_sitedir)/share/perl5
site_perl5libdir          = $(apache_sitedir)/share/perl5

