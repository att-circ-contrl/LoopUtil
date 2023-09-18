function [ validstart validend nanstart nanend ] = ...
  nlProc_findNaNSpans( dataseries )

% function [ validstart validend nanstart nanend ] = ...
%   nlProc_findNaNSpans( dataseries )
%
% This segments a signal into NaN and non-NaN regions.
%
% "dataseries" is a vector containing signal samples.
%
% "validstart" is a vector containing the starting sample indices of
%   non-NaN regions.
% "validend" is a vector containing the ending sample indices of non-NaN
%   regions.
% "nanstart" is a vector containing the starting sample indices of NaN
%   regions.
% "nanend" is a vector containing the ending sample indices of NaN regions.


validstart = [];
validend = [];
nanstart = [];
nanend = [];

sampcount = length(dataseries);

if sampcount > 1

  % We have a list containing at least two samples

  nanmask = isnan(dataseries);
  validstartmask = nanmask(1:(sampcount-1)) & (~nanmask(2:sampcount));
  validendmask = (~nanmask(1:(sampcount-1))) & nanmask(2:sampcount);


  % This is NaN followed by non-NaN.

  risingedgelist = find(validstartmask);

  validstart = risingedgelist + 1;
  nanend = risingedgelist;


  % This is non-NaN followed by NaN.

  fallingedgelist = find(validendmask);

  validend = fallingedgelist;
  nanstart = fallingedgelist + 1;


  % Handle data series endpoints.

  % Force geometry, so that we can use horzcat without problems.
  if ~isrow(validstart) ; validstart = transpose(validstart) ; end
  if ~isrow(validend) ; validend = transpose(validend) ; end
  if ~isrow(nanstart) ; nanstart = transpose(nanstart) ; end
  if ~isrow(nanend) ; nanend = transpose(nanend) ; end

  % Add appropriate samples.

  if isnan(dataseries(1))
    nanstart = [ 1 nanstart ];
  else
    validstart = [ 1 validstart ];
  end

  if isnan(dataseries(sampcount))
    nanend = [ nanend sampcount ];
  else
    validend = [ validend sampcount ];
  end

  % The lists should now be the same length and properly aligned.

elseif sampcount > 0

  % Handle the case where we were given a single sample.

  if isnan(dataseries(1))
    nanstart = 1;
    nanend = 1;
  else
    validstart = 1;
    validend = 1;
  end

end


% Done.
end


%
% This is the end of the file.
