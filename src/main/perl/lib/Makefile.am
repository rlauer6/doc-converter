SUBDIRS = .

include $(top_srcdir)/directories.inc

perlrun = @PERL@

if RPM_BUILD_MODE
perlwc = \#
else
perlwc = @PERL@
endif

ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

PACKAGE_VERSION = @PACKAGE_VERSION@
PROJECT_RELEASE = @PROJECT_RELEASE@

DOCCONVERTERMODULES = \
    DocConverter/Utils.pm.in

PERLMODULES = 

GDOCCONVERTERMODULES = $(DOCCONVERTERMODULES:.pm.in=.pm)

docconverterlibdir = $(perl5libdir)/DocConverter
amazonlibdir = $(perl5libdir)/Amazon
amazon_s3libdir = $(perl5libdir)/Amazon/S3

perl5lib_DATA = $(GPERLMODULES)

docconverterlib_DATA = $(GDOCCONVERTERMODULES)

amazonlib_DATA = Amazon/S3.pm
amazon_s3lib_DATA = Amazon/S3/Bucket.pm

dist_noinst_DATA = \
    $(PERLMODULES) \
    $(DOCCONVERTERMODULES) \
    Amazon/S3.pm \
    Amazon/S3/Bucket.pm

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir)  \
    -I $(builddir)/.. \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

# pattern rules
%.pm: %.pm.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) -wc $(PERLINCLUDE)  $@ || { rm $@ && exit 1; }

$(GDOCCONVERTERMODULES): % : %.in

$(GPERLMODULES): % : %.in

CLEANFILES = \
    $(GDOCCONVERTERMODULES) \
    $(GPERLMODULES)
