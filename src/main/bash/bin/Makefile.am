SUBDIRS = . 

include $(top_srcdir)/directories.inc

bashrun = @BASHRUN@

@do_subst_command@

BASHSCRIPTS = \
    doc2pdf.in \
    libreoffice-create-stack.in \
    libreoffice-download.in \
    doc-converter-add-role.in

GBASHSCRIPTS = $(BASHSCRIPTS:.in=)

bin_SCRIPTS = \
    $(GBASHSCRIPTS)

dist_noinst_DATA = \
    $(BASHSCRIPTS)

$(GBASHSCRIPTS): % : %.in
	$(do_subst) $< > $@

CLEANFILES = $(GBASHSCRIPTS)
