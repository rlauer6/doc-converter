SUBDIRS = .

include $(top_srcdir)/directories.inc

perlrun = @PERL@

if RPM_BUILD_MODE
perlwc = \# 
else
perlwc = @PERL@
endif

ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@
ax_perl5_extra_includes = @ax_perl5_extra_includes@

POD2MAN = /usr/bin/pod2man

G1MANPAGES = $(GPERLSCRIPTS:.pl=.1dc)
G2MANPAGES = $(GCGISCRIPTS:.cgi=.1dc)

@do_subst_command@

SCGISCRIPTS = 

# add any CGI scripts in your project here
CGISCRIPTS = \
    doc-converter.pl.in

PERLSCRIPTS = 

GCGISCRIPTS = $(CGISCRIPTS:.pl.in=.cgi)
GSCGISCRIPTS = $(SCGISCRIPTS:.sh.in=.cgi)
GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)

dist_noinst_DATA = $(CGISCRIPTS) $(PERLSCRIPTS) $(SCGISCRIPTS)

apache_site_cgibin_SCRIPTS = \
    $(GCGISCRIPTS) \
    $(GPERLSCRIPTS) \
    $(GSCGISCRIPTS)

man1_MANS = $(G1MANPAGES) $(G2MANPAGES)

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I ../$(builddir)/lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

.cgi: .pl.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) -wc $(PERLINCLUDE) $@ || { rm $@ && exit 1; }

.pl: .pl.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) -wc $(PERLINCLUDE) $@ || { rm $@ && exit 1; }

.cgi: .sh.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@


$(G1MANPAGES): %.1dc : %.pl
	target_name="$@";\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1dc$$//') ;\
	"$(POD2MAN)" $< \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1dc > "$${target_name}"

$(G2MANPAGES): %.1dc : %.cgi
	target_name="$@";\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1dc$$//') ;\
	"$(POD2MAN)" $< \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1dc > "$${target_name}"

all:

CLEANFILES = $(GCGISCRIPTS) $(GPERLSCRIPTS) $(GSCGISCRIPTS) $(G1MANPAGES) $(G2MANPAGES)

if DISTCHECK_HACK
else
install-data-hook:
	[ "$$(id -u)" == "0" ] && chown apache:apache $(DESTDIR)$(apache_site_cgibindir)/* || true
endif
