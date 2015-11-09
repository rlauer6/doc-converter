SUBDIRS = .

include $(top_srcdir)/directories.inc

ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

apache_user  = @apache_user@
apache_group = @apache_group@

@do_subst_command@

CONFIG = \
    doc-converter.conf.in

GCONFIG = \
    $(CONFIG:.conf.in=.conf)

dist_noinst_DATA = \
    $(CONFIG) \
    doc-converter.cfg.in

dcconfigdir = $(datadir)/doc-converter

dcconfig_DATA = \
    doc-converter.cfg

apache_confd_DATA = \
    $(GCONFIG)

if APACHE_CGI_SYMLINKS_ENABLED
apache_cgi_symlinks = SymLinksIfOwnerMatch
else
apache_cgi_symlinks =
endif

$(GCONFIG): % : %.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@

doc-converter.cfg: % : %.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@

all:

CLEANFILES = \
    $(GCONFIG) \
    doc-converter.cfg

if RPM_BUILD_MODE
else
install-data-hook:
	[ $$(id -u) = "0" ] && chown -R $(apache_user):$(apache_group) $(DESTDIR)$(apache_sitedir) || true
endif
