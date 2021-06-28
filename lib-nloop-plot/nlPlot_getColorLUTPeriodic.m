function collut = nlPlot_getColorLUTPeriodic()

% function collut = nlPlot_getColorLUTPeriodic()
%
% This function returns a cell array of color triplets. Colors are chosen
% so that successive colors are similar and so that the list may be iterated
% through repeatedly.
%
% "collut" is a cell array containing color triplets.


% FIXME - This is pretty ugly, but adequate.

cpal = nlPlot_getColorPalette();

collut = { cpal.brn, cpal.yel, cpal.grn, cpal.cyn, cpal.mag, cpal.red };


%
% Done.

end


%
% This is the end of the file.
