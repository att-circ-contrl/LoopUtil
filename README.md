# NeuroLoop utilities v1

## Overview

This is a set of libraries and utilities written to support closed-loop
neural stimulation experiments. As of October 2020, the emphasis is on
detecting transient oscillations in the local field potential ("LFP bursts")
and providing stimulation triggers that are phase-aligned to oscillations.
In the future the libraries and utilities may be extended to cover additional
experiment scenarios.

The NeuroLoop project is copyright (c) 2020 by Vanderbilt University, and
is released under the Creative Commons Attribution 4.0 International
License.


## Documentation

The following directories contain documentation:

* manual -- LaTeX build directory for project documentation.
Use `make -C manual` to build it.


## Applications

The following Matlab scripts are intended for direct use:

* nloop_chantool.m --
This is a GUI application that looks at folders containing Intan per-channel
data and identifies channels that have spikes and channels that have
LFP bursts.


## Libraries

The following directories contain library code:

* lib-nloop-chantool --
Library functions specific to the `nloop_chantool` script.
* lib-nloop-intan --
Library functions for manipulating data saved in Intan's format.
* lib-nloop-io --
Library functions for loading and saving data that aren't vendor-specific.
* lib-nloop-plot --
Helper functions for plotting. These are not publication-quality.
* lib-nloop-proc --
Library functions for performing signal processing.
* lib-nloop-util --
Helper functions that don't fall into the other categories.

* lib-vendor-intan --
Library functions for manipulating data saved in Intan's format, derived from
code supplied by Intan Technologies (used and re-licensed with permission).


## Sample Code

(FIXME -- Turn my test scripts into sample code.)


This is the end of the file.
