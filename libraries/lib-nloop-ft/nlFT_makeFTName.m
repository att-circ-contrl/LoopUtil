function newlabel = nlFT_makeFTName( banklabel, channum )

% function newlabel = nlFT_makeFTName( banklabel, channum )
%
% This turns a NeuroLoop bank label and channel number into a Field Trip
% channel label.
%
% "banklabel" is the NeuroLoop bank label (a valid field name character array).
% "channum" is the NeuroLoop channel number (an arbitrary nonnegative integer).
%
% "newlabel" is a character array containing the corresponding Field Trip
%   channel label.


% This is trivial, but we're keeping it in one place to guarantee
% consistent implementation.

newlabel = sprintf( '%s_%03d', banklabel, channum );


% Done.

end


%
% This is the end of the file.
