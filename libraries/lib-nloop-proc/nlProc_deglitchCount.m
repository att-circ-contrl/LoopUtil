function newseries = ...
  nlProc_deglitchCount( oldseries, glitchsamps, dropoutsamps)

% function newseries = ...
%   nlProc_deglitchCount( oldseries, glitchsamps, dropoutsamps)
%
% This function removes spurious gaps (drop-outs) and brief events (glitches)
% from a one-dimensional boolean vector.
%
% This version of the function specifies durations using sample counts.
%
% "oldseries" is a logical vector to process.
% "glitchsamps" is the longest event duration to reject as spurious.
% "dropoutsamps" is the longest gap duration to reject as spurious.
%
% "newseries" is a modified version of "oldseries".


% Use Matlab's "moving minimum" and "moving maximum" functions for this.
% This may be inefficient for large window sizes.


% FIXME - The window size passed to movmax/movmin should be odd to prevent
% successive erosion/dilation operations from walking edges forward.
% Since it counts the sample it's on, for radius N window size is (2N+1).
% This will cover a glitch or dropout of size 2N.

% Convert duration into a radius, round it, and convert back to window size.
glitchsamps = round(0.5 * glitchsamps);
glitchsamps = 1 + 2 * max(glitchsamps,0);
dropoutsamps = round(0.5 * dropoutsamps);
dropoutsamps = 1 + 2 * max(dropoutsamps,0);


newseries = oldseries;

% Pave over drop-outs using dilation followed by erosion.
newseries = movmax(newseries, dropoutsamps);
newseries = movmin(newseries, dropoutsamps);

% Remove glitches using erosion followed by dilation.
newseries = movmin(newseries, glitchsamps);
newseries = movmax(newseries, glitchsamps);


% Done.
end


%
% This is the end of the file.
