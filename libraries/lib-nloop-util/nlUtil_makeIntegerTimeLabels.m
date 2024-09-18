function [ newlabels newtitles ] = ...
  nlUtil_makeIntegerTimeLabels( timevals, units )

% function [ newlabels newtitles ] = ...
%   nlUtil_makeIntegerTimeLabels( timevals, units )
%
% This makes plot- and filename-safe labels from a number series (intended
% to be positive and negative time values).
%
% "timevals" is a vector containing time values (may be negative). These get
%   rounded to the nearest integer values.
% "units" is a character vector with a unit label (such as 'ms'). This should
%   be plot- and filename-safe.
%
% "newlabels" is a cell array with labels that have the form 'n0000uu' or
%   'p0000uu', for negative and positive time values, respectively.
% "newtitles" is a cell array with labels that have the form '-0 uu' or
%   '+0 uu', for negative and positive time values, respectively.


intseries = round(timevals);

negmask = (intseries < 0);

newlabels = [ ...
  nlUtil_sprintfCellArray( [ 'n%04d' units ], intseries(negmask) ) ...
  nlUtil_sprintfCellArray( [ 'p%04d' units ], intseries(~negmask) ) ];

newtitles = nlUtil_sprintfCellArray( [ '%+d ' units ], intseries );


% Done.
end


%
% This is the end of the file.
