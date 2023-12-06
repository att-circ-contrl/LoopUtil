# NeuroLoop utilities - Documentation - Makefile
# Written by Christopher Thomas.

CHANGUIDE=chantool-guide
CHANBASE=changuide

REFNAME=neuroloop-utility-libraries
REFBASE=nlutilref

MODELGUIDE=model-guide
MODELBASE=models


CHANBITS=\
	$(CHANGUIDE).tex		\
	$(CHANBASE)-over.tex		\
	$(CHANBASE)-howto.tex

MODELBITS=\
	$(MODELGUIDE).tex		\
	$(MODELBASE)-over.tex		\
	$(MODELBASE)-robinson.tex

REFBITS=\
	$(REFNAME).tex			\
	$(REFBASE)-over.tex

REFAUTO=\
	$(REFBASE)-artifact.tex		\
	$(REFBASE)-basis.tex		\
	$(REFBASE)-ft.tex		\
	$(REFBASE)-io.tex		\
	$(REFBASE)-plot.tex		\
	$(REFBASE)-proc.tex		\
	$(REFBASE)-synth.tex		\
	$(REFBASE)-util.tex		\
	$(REFBASE)-intan.tex		\
	$(REFBASE)-vend-intan.tex	\
	$(REFBASE)-openephys.tex	\
	$(REFBASE)-chantool.tex		\
	$(REFBASE)-sanity.tex		\
	$(REFBASE)-examples.tex		\
	$(REFBASE)-notes-core.tex	\
	$(REFBASE)-notes-abstract.tex	\
	$(REFBASE)-notes-apps.tex


default: force

changuide: $(CHANGUIDE).pdf
modelguide: $(MODELGUIDE).pdf
libref: $(REFNAME).pdf

force: clean changuide modelguide libref install
	make autoclean

clean: tclean autoclean
	rm -f $(CHANGUIDE).pdf
	rm -f $(REFNAME).pdf
	rm -f $(MODELGUIDE).pdf

autoclean:
	rm -f $(REFAUTO)

tclean:
	rm -f $(CHANGUIDE)*.log $(CHANGUIDE)*.aux $(CHANGUIDE)*.toc
	rm -f $(REFNAME)*.log $(REFNAME)*.aux $(REFNAME)*.toc
	rm -f $(MODELGUIDE)*.log $(MODELGUIDE)*.aux $(MODELGUIDE)*.toc
	rm -f texput.*

install:
	mv *pdf ../manual


$(CHANGUIDE).pdf: $(CHANBITS)
	pdflatex $(CHANGUIDE).tex
	pdflatex $(CHANGUIDE).tex
	make tclean


$(MODELGUIDE).pdf: $(MODELBITS)
	pdflatex $(MODELGUIDE).tex
	pdflatex $(MODELGUIDE).tex
	make tclean


refauto-bits: refauto-corelibs refauto-abstractlibs refauto-applibs \
	refauto-examples refauto-notes

DIRSCORE=\
	../libraries/lib-nloop-artifact	\
	../libraries/lib-nloop-basis	\
	../libraries/lib-nloop-io	\
	../libraries/lib-nloop-plot	\
	../libraries/lib-nloop-proc	\
	../libraries/lib-nloop-synth	\
	../libraries/lib-nloop-util

refauto-corelibs:
	./copy-code.pl --outfile=$(REFBASE)-artifact.tex --matlabdoc \
		"--chapter=\`\`nlArt'' Functions" --label=sect-artifact \
		../libraries/lib-nloop-artifact/*.m
	./copy-code.pl --outfile=$(REFBASE)-basis.tex --matlabdoc \
		"--chapter=\`\`nlBasis'' Functions" --label=sect-basis \
		../libraries/lib-nloop-basis/*.m
	./copy-code.pl --outfile=$(REFBASE)-io.tex --matlabdoc \
		"--chapter=\`\`nlIO'' Functions" --label=sect-io \
		../libraries/lib-nloop-io/*.m
	./copy-code.pl --outfile=$(REFBASE)-plot.tex --matlabdoc \
		"--chapter=\`\`nlPlot'' Functions" --label=sect-plot \
		../libraries/lib-nloop-plot/*.m
	./copy-code.pl --outfile=$(REFBASE)-proc.tex --matlabdoc \
		"--chapter=\`\`nlProc'' Functions" --label=sect-proc \
		../libraries/lib-nloop-proc/*.m
	./copy-code.pl --outfile=$(REFBASE)-synth.tex --matlabdoc \
		"--chapter=\`\`nlSynth'' Functions" --label=sect-synth \
		../libraries/lib-nloop-synth/*.m
	./copy-code.pl --outfile=$(REFBASE)-util.tex --matlabdoc \
		"--chapter=\`\`nlUtil'' Functions" --label=sect-util \
		../libraries/lib-nloop-util/*.m

DIRSABSTRACT=\
	../libraries/lib-nloop-ft	\
	../libraries/lib-nloop-intan	\
	../libraries/lib-vendor-intan	\
	../libraries/lib-nloop-openephys

refauto-abstractlibs:
	./copy-code.pl --outfile=$(REFBASE)-ft.tex --matlabdoc \
		"--chapter=\`\`nlFT'' Functions" --label=sect-ft \
		../libraries/lib-nloop-ft/*.m
	./copy-code.pl --outfile=$(REFBASE)-intan.tex --matlabdoc \
		"--chapter=\`\`nlIntan'' Functions" --label=sect-intan \
		../libraries/lib-nloop-intan/*.m
	./copy-code.pl --outfile=$(REFBASE)-vend-intan.tex --matlabdoc \
		"--chapter=\`\`vIntan'' Functions" --label=sect-vend-intan \
		../libraries/lib-vendor-intan/*.m
	./copy-code.pl --outfile=$(REFBASE)-openephys.tex --matlabdoc \
		"--chapter=\`\`nlOpenE'' Functions" --label=sect-openephys \
		../libraries/lib-nloop-openephys/*.m

DIRSAPPS=\
	../libraries/lib-nloop-chantool		\
	../libraries/lib-nloop-sanitycheck

refauto-applibs:
	./copy-code.pl --outfile=$(REFBASE)-chantool.tex --matlabdoc \
		"--chapter=\`\`nlChan'' Functions" --label=sect-chan \
		../libraries/lib-nloop-chantool/*.m
	./copy-code.pl --outfile=$(REFBASE)-sanity.tex --matlabdoc \
		"--chapter=\`\`nlCheck'' Functions" --label=sect-sanity \
		../libraries/lib-nloop-sanitycheck/*.m

refauto-examples:
	./copy-code.pl --outfile=$(REFBASE)-examples.tex --verbatim \
		"--chapter=Sample Code" --label=sect-examples \
		../code-examples/*.m

refauto-notes:
	./copy-code.pl --outfile=$(REFBASE)-notes-core.tex --verbatim \
		"--chapter=Core Library Structures and Additional Notes" \
		--label=sect-notes-core `find $(DIRSCORE)|grep txt`
	./copy-code.pl --outfile=$(REFBASE)-notes-abstract.tex --verbatim \
	"--chapter=Compatibility Library Structures and Additional Notes" \
		--label=sect-notes-abstract `find $(DIRSABSTRACT)|grep txt`
	./copy-code.pl --outfile=$(REFBASE)-notes-apps.tex --verbatim \
	"--chapter=Application Library Structures and Additional Notes" \
		--label=sect-notes-apps `find $(DIRSAPPS)|grep txt`

$(REFNAME).pdf: $(REFBITS) refauto-bits
	pdflatex $(REFNAME).tex
	pdflatex $(REFNAME).tex
	make tclean

#
# This is the end of the file.
