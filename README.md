# NeuroLoop utilities v1

## Overview

This is a set of libraries and utilities written to support closed-loop
neural stimulation experiments. As of October 2020, the emphasis is on
detecting transient oscillations in the local field potential ("LFP bursts")
and providing stimulation triggers that are phase-aligned to oscillations.
In the future the libraries and utilities may be extended to cover additional
experiment scenarios.

The NeuroLoop project is copyright (c) 2020-2021 by Vanderbilt University,
and is released under the Creative Commons Attribution 4.0 International
License.


## Documentation

The following directories contain documentation:

* `manual` -- LaTeX build directory for project documentation.
Use `make -C manual` to build it.


## Applications

Application scripts are intended for direct use. These are found in
the `code-applications` directory. The following scripts are provided:

* `nloop_chantool.m` --
This is a GUI application that looks at folders containing Intan per-channel
data and identifies channels that have spikes and channels that have
LFP bursts.


## Libraries

Libraries are provided in the `libraries` directory. With that directory
on path, call the `addPathsLoopUtil` function to add sub-folders.

Library subdirectories are listed below.

"Core" libraries:

* `lib-nloop-io` --
Library functions for loading and saving data that aren't vendor-specific.
* `lib-nloop-plot` --
Helper functions for plotting. These are not publication-quality.
* `lib-nloop-proc` --
Library functions for performing signal processing.
* `lib-nloop-util` --
Helper functions that don't fall into the other categories.

"Abstraction" libraries:

* `lib-nloop-ft` --
Library functions for interoperating with Field Trip.
* `lib-nloop-intan` --
High-level library functions for manipulating data saved in Intan's format.
* `lib-vendor-intan` --
Low-level library functions for manipulating data saved in Intan's format,
derived from code supplied by Intan Technologies (used and re-licensed with
permission).
* `lib-nloop-openephys` --
High-level library functions for manipulating data saved in Open Ephys's
format.

"Application" libraries:

* `lib-nloop-chantool` --
Library functions specific to the `nloop_chantool` script.
* `lib-nloop-check` --
Library functions specific to the in-house "sanity checking" script.


## Sample Code

Sample code scripts are intended to illustrate how the libraries are used.
These are found in the `code-examples` directory. The following scripts
are provided:

### `code-example-reading` folder:

This demonstrates how to read and process ephys data.

* `do_test.m` --
This is my test script for exercising the "LoopUtil" library. It does the
same operations as the channel tool, without a GUI. Referencing is performed
a bit differently as of Dec. 2021 (it can do common-average referencing and
it does rereferencing before artifact removal rather than after). You'll
need to edit the `plotdir` variable and create a configuration script that
points to your data to use it.
* `do_config_reider.m`, `do_config_frey_tungsten.m`, and
`do_config_frey_silicon.m` are representative configuration scripts using
private datasets. See the preamble of `do_test.m` for details on what needs
to be configured and what optional settings may additionally be configured.

### `code-example-robinson` folder:

This demonstrates how to generate synthetic data using the extended
Robinson model functions.


_(This is the end of the file.)_
