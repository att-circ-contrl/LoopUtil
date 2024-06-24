function newlabels = nlFT_makeFTNameList( banklabel, channums )

% function newlabels = nlFT_makeFTNameList( banklabel, channums )
%
% This turns a NeuroLoop bank label and a vector channel numbers into a
% cell array of Field Trip channel labels.
%
% "banklabel" is the NeuroLoop bank label (a valid field name character array).
% "channum" is a vector containing NeuroLoop channel numbers (arbitrary
%   nonnegative integers).
%
% "newlabel" is a cell array containing character vectors with the
%   corresponding Field Trip channel labels.


newlabels = cell(size(channums));

for lidx = 1:length(channums)
  newlabels{lidx} = nlFT_makeFTName( banklabel, channums(lidx) );
end


% Done.

end


%
% This is the end of the file.
