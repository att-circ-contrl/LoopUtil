function addPathsLoopUtil

% function addPathsLoopUtil
%
% This function detects its own path and adds appropriate child paths to
% Matlab's search path.
%
% No arguments or return value.


% Detect the current path.

fullname = which('addPathsLoopUtil');
[ thisdir fname fext ] = fileparts(fullname);


% Add the new paths.
% (This checks for duplicates, so we don't have to.)

% Utility libraries.
addpath([ thisdir filesep 'lib-nloop-util' ]);
addpath([ thisdir filesep 'lib-nloop-proc' ]);
addpath([ thisdir filesep 'lib-nloop-io' ]);
addpath([ thisdir filesep 'lib-nloop-plot' ]);
addpath([ thisdir filesep 'lib-nloop-sanitycheck' ]);

% Vendor-specific libraries.
addpath([ thisdir filesep 'lib-nloop-openephys' ]);
addpath([ thisdir filesep 'lib-nloop-intan' ]);
addpath([ thisdir filesep 'lib-vendor-intan' ]);

% Interoperability libraries.
addpath([ thisdir filesep 'lib-nloop-ft' ]);

% Application libraries.
addpath([ thisdir filesep 'lib-nloop-chantool' ]);


% Done.

end


%
% This is the end of the file.
