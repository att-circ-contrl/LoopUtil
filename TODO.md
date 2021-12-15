# NeuroLoop utilities v1 bug list, feature requests, and abbreviated changelog.


## To-do list and bug list for version 1:

* (channel tool) Feature request:
Be able to read epoch markers from event codes and collect statistics only
for portions of the signal within epochs.

* (channel tool) Feature request: Function on epoched segments without being
able to filter the original continuous signal (zero-pad and then filter the
epoch only).

* (channel tool) Add "cancel" buttons to interrupt processing and plotting.

* (channel tool) The in-dialog "pretty and slow" plots for burst power spectra
have colour issues. Stand-alone plots look okay. These are made using
nlPlot_axesPlotPersist(). This may be a palette-fighting issue.

* (channel tool) Add CSV output to callback_dataSaveAll().

* (channel tool) Add spike channel sorting. This has been deferred for now.

* (channel tool) Add "at most N chosen burst channels per bank".

* (channel tool) Burst band selection label needs "Hz" after frequency range.

* (channel tool) Empty plot is white the first time but invisible after
subsequent updates before plotting.

* (channel tool) Auto-refresh when entering the burst channel sorting dialog.
Perhaps do so after adjusting, rather than having to click "refresh". Perhaps
also auto-select the first channel in the list.

* (impedance) Move "simple" clustering into ZMODELS instead of it being a
special case. Pass an arbitrary model structure to readAndBinImpedance().

* (impedance) Fold metadata like "order to test clusters" and "maximum
distance to be in a cluster" into ZMODELS.

* (channel tool) Add support for channel mapping.

* (channel tool) Add support for selecting banks to process (right now
configuration is hard-coded to use Intan's naming conventions).

* (channel tool) Filter out channels that are artifacty (previous feature,
removed during refactoring).

* (processing) Normalize persistence spectrum power to make plotting range
insensitive to signal amplitude.

* (I/O) Provide a multi-threaded iteration function for users who have the
parallel computing toolbox.

* (Intan) Finish breaking out "traditional intan format" code.

* (Intan) Add one-file-per-type Intan reading code (as "Neuroscope" vendor?).

* (channel tool) GUI initialization fails if re-running after moving the
burst frequency sliders (via "clear; close all; nloop_channeltool").


## Deferred to version 2:



## Abbreviated changelog:

* 15 Dec 2021 --
Moved libraries to a "libraries" folder and added a top-level script to add
sub-folders to Matlab's path.
Moved application code to "code-applications" and my test code to
"code-examples".
* 14 Dec 2021 --
Moved I/O routines into their own folder.
Moved channel iteration into I/O, from channel tool.
Refactored I/O to centralize vendor-independent code and to package
vendor-specific code.
Started porting Intan's code to the library, with permission. Metadata code
is ported, monolithic "Intan format" code is not.
* 13 Oct 2020 --
Milestone release.
* 09 Oct 2020 --
Fixed frequency axis scaling bug in calcSpectrumSkew.m.


This is the end of the file.
