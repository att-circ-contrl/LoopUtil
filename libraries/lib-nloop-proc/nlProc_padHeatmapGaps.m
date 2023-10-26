function [ newdata newxseries newyseries ] = ...
  nlProc_padHeatmapGaps( olddata, oldxseries, oldyseries )

% function [ newdata newxseries newyseries ] = ...
%   nlProc_padHeatmapGaps( olddata, oldxseries, oldyseries )
%
% This looks for nonuniformities in row and column coordinates in a
% supplied matrix of two-dimensional data, and pads any sufficiently large
% gaps with new cells containing NaN.
%
% The intention is to simplify plotting heatmaps and histograms of data
% with independent axes that have discontinuous ranges.
%
% To produce sensible output, oldxseries and oldyseries should mostly
% contain linearly spaced values. The "nominal" spacing is computed as the
% median of the difference between successive values.
%
% "olddata" is a matrix indexed by (y,x) that contains data values.
% "oldxseries" is a vector containing X axis values for each column in the
%   data matrix.
% "oldyseries" is a vector containing Y axis values for each row in the
%   data matrix.
%
% "newdata" is a copy of "olddata" that may have additional rows and columns
%   added which contain NaN values.
% "newxseries" is a copy of "oldxseries" that may have additional values.
% "newyseries" is a copy of "oldyseries" that may have additional values.

% Initialize.

newdata = [];
newxseries = [];
newyseries = [];


% Bail out if we have empty data.
if isempty(olddata)
  return;
end


% Calculate nominal spacing in each axis and identify gaps.

xpitch = median(diff(oldxseries));
ypitch = median(diff(oldyseries));

xneedgap = (diff(oldxseries) > (2.5 * xpitch));
yneedgap = (diff(oldyseries) > (2.5 * ypitch));


% Walk through columns, padding as-needed.

newxseries = [];
newdata = [];

newxseries(1) = oldxseries(1);
newdata = olddata(:,1);

for xidx = 1:length(xneedgap)
  prevcoord = oldxseries(xidx);
  thiscoord = oldxseries(xidx+1);
  thisslice = olddata(:,xidx+1);

  if xneedgap(xidx)
    % Add two coordinate points, with the correct spacing from each edge.
    dummycoord = [ prevcoord + xpitch, thiscoord - xpitch ];
    newxseries = horzcat(newxseries, dummycoord);

    dummydata = nan(size(thisslice));
    dummydata = horzcat(dummydata, dummydata);
    newdata = horzcat(newdata, dummydata);
  end

  newdata = horzcat(newdata, thisslice);
  newxseries = horzcat(newxseries, thiscoord);
end


% Walk through rows, padding as-needed.

newyseries = [];
olddata = newdata;
newdata = [];

newyseries(1) = oldyseries(1);
newdata = olddata(1,:);

for yidx = 1:length(yneedgap)
  prevcoord = oldyseries(yidx);
  thiscoord = oldyseries(yidx+1);
  thisslice = olddata(yidx+1,:);

  if yneedgap(yidx)
    % Add two coordinate points, with the correct spacing from each edge.
    dummycoord = [ prevcoord + ypitch, thiscoord - ypitch ];
    newyseries = horzcat(newyseries, dummycoord);

    dummydata = nan(size(thisslice));
    dummydata = vertcat(dummydata, dummydata);
    newdata = vertcat(newdata, dummydata);
  end

  newdata = vertcat(newdata, thisslice);
  newyseries = horzcat(newyseries, thiscoord);
end


% Force consistency.

if ~isrow(oldxseries)
  newxseries = transpose(newxseries);
end

if ~isrow(oldyseries)
  newyseries = transpose(newyseries);
end


% Done.
end


%
% This is the end of the file.
