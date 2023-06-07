function [ linestyles markstyles ] = nlPlot_getLineMarkStyleSpread( count )

% function [ linestyles markstyles ] = nlPlot_getLineMarkStyleSpread( count )
%
% This function returns a list of Matlab plotting line style and marker style
% specifiers, chosen to avoid repeating combinations where possible.
%
% "count" is the number of entries to return.
%
% "linestyles" is a cell array containing character vectors to be passed
%   as 'LineStyle' plot arguments.
% "markstyles" is a cell array containing character vectors to be passed as
%   'Marker' plot arguments.


% Make lists with sizes that are relatively prime, and cycle through them.

linelut = { '-', '--', '-.' };
marklut = { '+', 's', 'd', 'o', '^' };


linestyles = {};
markstyles = {};

for cidx = 1:count
  linestyles{cidx} = linelut(1 + mod( cidx-1, length(linelut) ));
  markstyles{cidx} = marklut(1 + mod( cidx-1, length(marklut) ));
end


% Done.
end


%
% This is the end of the file.
