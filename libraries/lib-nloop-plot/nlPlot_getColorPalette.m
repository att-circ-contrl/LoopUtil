function cols = nlPlot_getColorPalette()

% function cols = nlPlot_getColorPalette()
%
% This function returns a structure containing color triplets indexed by
% color name.
%
% Colors suppled are "blu", "brn", "yel", "mag", "grn", "cyn", and "red".
% These are mostly cribbed from get(cga,'colororder'), with tweaks.
% Additional colours are "blk", "wht", and "gry".
%
% "cols" is a structure containing color triplets.

cols = struct();

% Standard plot colours.
cols.blu = [ 0.0 0.4 0.7 ];
cols.brn = [ 0.8 0.4 0.1 ];  % Tweaked; original was [ 0.9 0.3 0.1 ].
cols.yel = [ 0.9 0.7 0.1 ];
cols.mag = [ 0.5 0.2 0.5 ];
cols.grn = [ 0.5 0.7 0.2 ];
cols.cyn = [ 0.3 0.7 0.9 ];
cols.red = [ 0.7 0.3 0.4 ];  % Lightened a bit; was [ 0.6 0.1 0.2 ].

% Other colours of interest.
cols.blk = [ 0.0 0.0 0.0 ];
cols.wht = [ 1.0 1.0 1.0 ];
cols.gry = [ 0.7 0.7 0.7 ];


%
% Done.

end


%
% This is the end of the file.
