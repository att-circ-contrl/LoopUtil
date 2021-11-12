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
	$(REFBASE)-chantool.tex		\
	$(REFBASE)-intan.tex		\
	$(REFBASE)-io.tex		\
	$(REFBASE)-plot.tex		\
	$(REFBASE)-proc.tex		\
	$(REFBASE)-util.tex		\
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


refauto-bits:
	./copy-code.pl --outfile=$(REFBASE)-chantool.tex --matlabdoc \
		"--chapter=\`\`nlChan'' Functions" --label=sect-chan \
		../lib-nloop-chantool/*.m
	./copy-code.pl --outfile=$(REFBASE)-intan.tex --matlabdoc \
		"--chapter=\`\`nlIntan'' Functions" --label=sect-intan \
		../lib-nloop-intan/*.m
	./copy-code.pl --outfile=$(REFBASE)-io.tex --matlabdoc \
		"--chapter=\`\`nlIO'' Functions" --label=sect-io \
		../lib-nloop-io/*.m
	./copy-code.pl --outfile=$(REFBASE)-plot.tex --matlabdoc \
		"--chapter=\`\`nlPlot'' Functions" --label=sect-plot \
		../lib-nloop-plot/*.m
	./copy-code.pl --outfile=$(REFBASE)-proc.tex --matlabdoc \
		"--chapter=\`\`nlProc'' Functions" --label=sect-proc \
		../lib-nloop-proc/*.m
	./copy-code.pl --outfile=$(REFBASE)-util.tex --matlabdoc \
		"--chapter=\`\`nlUtil'' Functions" --label=sect-util \
		../lib-nloop-util/*.m
	./copy-code.pl --outfile=$(REFBASE)-notes.tex --verbatim \
		"--chapter=Special Structures and Function Handles" \
		--label=sect-notes ../lib-*/*txt

$(REFNAME).pdf: $(REFBITS) refauto-bits
	pdflatex $(REFNAME).tex
	pdflatex $(REFNAME).tex
	make tclean

#
# This is the end of the file.
