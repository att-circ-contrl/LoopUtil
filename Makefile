# NeuroLoop project - Utilities - Makefile
# Written by Christopher Thomas.

MATLAB=matlab
MATFLAGS=-nodisplay -nodesktop -nosplash
MATGUIFLAGS=-nodesktop -nosplash

default: clean runtest gallery

clean:
	rm -f plots/*

runtest:
	cd code-examples; nice -n +10 $(MATLAB) $(MATFLAGS) \
		-r "addpath('../libraries'); run('do_test.m'); exit;"

# NOTE - We can't call "exit", or else we'll exit immediately after starting
# the GUI, since it's in a different thread.
runchan:
	cd code-applications; nice -n +10 $(MATLAB) $(MATGUIFLAGS) \
		-r "addpath('../libraries'); run('nloop_channeltool.m');"

docs:
	make -C manual-src

dclean:
	make -C manual-src clean

gallery:
	cd plots; makegallery.pl --width=24% --nofolders *png; cd ..

gallery3:
	cd plots; makegallery.pl --width=32% --nofolders *png; cd ..

#
# This is the end of the file.
