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


## Deferred to version 2:



## Abbreviated changelog:

* 13 Oct 2020 --
Milestone release.
* 09 Oct 2020 --
Fixed frequency axis scaling bug in calcSpectrumSkew.m.


This is the end of the file.
