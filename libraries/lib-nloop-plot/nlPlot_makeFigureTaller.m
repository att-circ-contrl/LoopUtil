function [ oldpos newpos ] = ...
  nlPlot_makeFigureTaller( thisfig, rowcount, rowmin )

% This reads thisfig.Position, and calculates a modified version of it
% that accomodates the desired Y axis size.
%
% To expand the figure:
%   thisfig.Position = newpos;
% To restore the original size:
%   thisfig.Position = oldpos;
%
% "thisfig" is the figure to read geometry information from.
% "rowcount" is the actual number of Y axis elements being plotted.
% "rowmin" is the number of Y axis elements that can fit in the figure
%   without resizing it.
%
% "oldpos" is the old value of thisfig.Position.
% "newpos" is the new value of thisfig.Position.


% This is trivial, but I have to keep looking it up. So, it's in a helper
% function now.

oldpos = thisfig.Position;
newpos = thisfig.Position;

if rowcount > rowmin
  newpos(4) = round( newpos(4) * rowcount / rowmin );
end


% Done.
end


%
% This is the end of the file.
