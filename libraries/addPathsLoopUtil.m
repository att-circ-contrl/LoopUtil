function addPathsLoopUtil

% function addPathsLoopUtil
%
% This function detects its own path and adds appropriate child paths to
% Matlab's search path.
%
% No arguments or return value.


% Detect the current path.

thisdir = which('addPathsLoopUtil');
thisdir = dir(thisdir);
thisdir = thisdir.folder;


% Add the new paths.
% (This checks for duplicates, so we don't have to.)

% Utility libraries.
addpath([ thisdir '/lib-nloop-util' ]);
addpath([ thisdir '/lib-nloop-proc' ]);
addpath([ thisdir '/lib-nloop-io' ]);
addpath([ thisdir '/lib-nloop-plot' ]);

% Vendor-specific libraries.
addpath([ thisdir '/lib-nloop-intan' ]);
addpath([ thisdir '/lib-vendor-intan' ]);

% Application libraries.
addpath([ thisdir '/lib-nloop-chantool' ]);


% Done.

end


%
% This is the end of the file.
