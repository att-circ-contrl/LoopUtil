# NeuroLoop utilities - Documentation - Makefile
# Written by Christopher Thomas.

CHANGUIDE=chantool-guide
CHANBASE=changuide

REFNAME=neuroloop-utility-libraries
REFBASE=nlutilref


CHANBITS=\
	$(CHANGUIDE).tex		\
	$(CHANBASE)-over.tex		\
	$(CHANBASE)-howto.tex

REFBITS=\
	$(REFNAME).tex			\
	$(REFBASE)-over.tex

REFAUTO=\
	$(REFBASE)-io.tex		\
	$(REFBASE)-plot.tex		\
	$(REFBASE)-proc.tex		\
	$(REFBASE)-util.tex		\
	$(REFBASE)-intan.tex		\
	$(REFBASE)-vend-intan.tex	\
	$(REFBASE)-chantool.tex		\
	$(REFBASE)-examples.tex		\
	$(REFBASE)-notes.tex


default: force

changuide: $(CHANGUIDE).pdf
libref: $(REFNAME).pdf

force: clean changuide libref
	make autoclean

clean: tclean autoclean
	rm -f $(CHANGUIDE).pdf
	rm -f $(REFNAME).pdf

autoclean:
	rm -f $(REFAUTO)

tclean:
	rm -f $(CHANGUIDE)*.log $(CHANGUIDE)*.aux $(CHANGUIDE)*.toc
	rm -f $(REFNAME)*.log $(REFNAME)*.aux $(REFNAME)*.toc
	rm -f texput.*


$(CHANGUIDE).pdf: $(CHANBITS)
	pdflatex $(CHANGUIDE).tex
	pdflatex $(CHANGUIDE).tex
	make tclean


refauto-bits: refauto-corelibs refauto-vendorlibs refauto-applibs \
	refauto-examples refauto-notes

refauto-corelibs:
	./copy-code.pl --outfile=$(REFBASE)-io.tex --matlabdoc \
		"--chapter=\`\`nlIO'' Functions" --label=sect-io \
		../libraries/lib-nloop-io/*.m
	./copy-code.pl --outfile=$(REFBASE)-plot.tex --matlabdoc \
		"--chapter=\`\`nlPlot'' Functions" --label=sect-plot \
		../libraries/lib-nloop-plot/*.m
	./copy-code.pl --outfile=$(REFBASE)-proc.tex --matlabdoc \
		"--chapter=\`\`nlProc'' Functions" --label=sect-proc \
		../libraries/lib-nloop-proc/*.m
	./copy-code.pl --outfile=$(REFBASE)-util.tex --matlabdoc \
		"--chapter=\`\`nlUtil'' Functions" --label=sect-util \
		../libraries/lib-nloop-util/*.m

refauto-vendorlibs:
	./copy-code.pl --outfile=$(REFBASE)-intan.tex --matlabdoc \
		"--chapter=\`\`nlIntan'' Functions" --label=sect-intan \
		../libraries/lib-nloop-intan/*.m
	./copy-code.pl --outfile=$(REFBASE)-vend-intan.tex --matlabdoc \
		"--chapter=\`\`vIntan'' Functions" --label=sect-vend-intan \
		../libraries/lib-vendor-intan/*.m

refauto-applibs:
	./copy-code.pl --outfile=$(REFBASE)-chantool.tex --matlabdoc \
		"--chapter=\`\`nlChan'' Functions" --label=sect-chan \
		../libraries/lib-nloop-chantool/*.m

refauto-examples:
	./copy-code.pl --outfile=$(REFBASE)-examples.tex --verbatim \
		"--chapter=Sample Code" --label=sect-examples \
		../code-examples/*.m

refauto-notes:
	./copy-code.pl --outfile=$(REFBASE)-notes.tex --verbatim \
		"--chapter=Special Structures and Function Handles" \
		--label=sect-notes ../libraries/lib-*/*txt

$(REFNAME).pdf: $(REFBITS) refauto-bits
	pdflatex $(REFNAME).tex
	pdflatex $(REFNAME).tex
	make tclean

#
# This is the end of the file.
