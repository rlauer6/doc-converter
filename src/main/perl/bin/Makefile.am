SUBDIRS = .

include $(top_srcdir)/directories.inc

perlrun = @PERL@

if RPM_BUILD_MODE
perlwc = \# 
else
perlwc = @PERL@
endif

ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

POD2MAN = /usr/bin/pod2man

G1MANPAGES = $(GPERLSCRIPTS:.pl=.1dc) $(GUTILITIES:.pl=.1dc)

PERLSCRIPTS = \
    fix-OOXMLRecalcMode.pl.in \
    doc2pdf-client.pl.in

UTILITIES = 

GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)
GCOMMANDS = $(GPERLSCRIPTS:.pl=)

GUTILITIES = $(UTILITIES:.pl.in=.pl)

libexec_SCRIPTS = $(GCOMMANDS)
dist_noinst_DATA = $(PERLSCRIPTS) $(UTILITIES)
noinst_DATA = $(GUTILITIES)

man1_MANS = $(G1MANPAGES)

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

%.pl: %.pl.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) -wc $(PERLINCLUDE) $@ || { rm $@ && exit 1; }

$(GPERLSCRIPTS): % : %.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) -wc $(PERLINCLUDE) $@ || { rm $@ && exit 1; }

$(GCOMMANDS): % : %.pl
	cp $< $@

$(GCRON): % : %.in
	$(do_subst) $< > $@

$(G1MANPAGES): %.1dc : %.pl
	target_name="$@";\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1dc$$//') ;\
	"$(POD2MAN)" $< \
	--center=$(PACKAGE) \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1dc > "$${target_name}"

tags: $(PERLSCRIPTS) \
      $(UTILITIES) \
      startup.pl
	rm -f TAGS
	for a in $^; do \
	  ctags -e -a --language-force=perl $$a; \
	done

all:

CLEANFILES = $(GPERLSCRIPTS) $(GMANPAGES) $(GUTILITIES)

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages

.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for mpath in $(G1MANPAGES); do \
	rm -f "$${mpath}" ;\
	test $$? -eq 0 || exit 1 ;\
	done

if DISTCHECK_HACK
else
install-data-hook:
endif
