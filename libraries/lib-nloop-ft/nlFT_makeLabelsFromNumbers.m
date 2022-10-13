function chanlabels = nlFT_makeLabelsFromNumbers( bankname, channums )

% function chanlabels = nlFT_makeLabelsFromNumbers( bankname, channums )
%
% This function calls "nlFT_makeFTName" to convert channel numbers into
% labels for a list of channel numbers.
%
% "bankname" is the bank name to use when building channel labels.
% "channums" is a vector containing channel numbers.
%
% "chanlabels" is a Nx1 cell array containing channel labels.


chanlabels = {};

for cidx = 1:length(channums)
  chanlabels{cidx} = nlFT_makeFTName( bankname, channums(cidx) );
end

if ~iscolumn(chanlabels)
  chanlabels = transpose(chanlabels);
end


% Done.

end


%
% This is the end of the file.
