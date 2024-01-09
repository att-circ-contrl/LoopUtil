function [ newdata newxedges newyedges ] = ...
  nlProc_padHeatmapNaNs( olddata, oldxedges, oldyedges )

% function [ newdata newxedges newyedges ] = ...
%   nlProc_padHeatmapNaNs( olddata, oldxedges, oldyedges )
%
% This function adds new X and Y values and histogram bins in a 2D histogram
% to arrange things so that "surf" will render all non-NaN bins in the
% original data.
%
% When plotting histogram bins as surfaces, any bins before NaN bins won't
% be rendered (as one of the vertices for that bin's face is NaN). To solve
% this, NaN bins get very thin shim bins inserted before them.
%
% "olddata" is a matrix indexed by (y,x) that contains data values.
% "oldxedges" is a vector containing X axis values for the edges of the
%   histogram bins (one more entry than "olddata" has columns).
% "oldyedges" is a vector containing Y axis values for the edges of the
%   histogram bins (one more entry than "olddata" has rows).
%
% "newdata" is a copy of "olddata" with shim bins added.
% "newxedges" is a copy of "oldxedges" with shim bins added.
% "newyedges" is a copy of "oldyedges" with shim bins added.


%
% Figure out which bins (on each axis) need to be replicated.
% These are bins that have a non-NaN cell followed by a NaN cell.

rowcount = size(olddata,1);
colcount = size(olddata,2);

xneedspadding = false(1,colcount);
yneedspadding = false(rowcount,1);

for ridx = 1:rowcount
  thisrow = olddata(ridx,:);
  thismask = isnan(thisrow);

  % Find non-NaN to NaN transitions.
  thismask(1:colcount-1) = (~thismask(1:colcount-1)) & thismask(2:colcount);
  thismask(colcount) = false;

  xneedspadding = xneedspadding | thismask;
end

for cidx = 1:colcount
  thiscol = olddata(:,cidx);
  thismask = isnan(thiscol);

  % Find non-NaN to NaN transitions.
  thismask(1:rowcount-1) = (~thismask(1:rowcount-1)) & thismask(2:rowcount);
  thismask(rowcount) = false;

  yneedspadding = yneedspadding | thismask;
end


%
% Walk through the data, doing replication.

xepsilon = 0.01 * min(abs( diff(oldxedges) ));
yepsilon = 0.01 * min(abs( diff(oldyedges) ));

newdata = olddata(1,:);
newyedges = [];

addedcount = 0;
for ridx = 1:rowcount
  newdata(ridx + addedcount,:) = olddata(ridx,:);
  newyedges(ridx + addedcount) = oldyedges(ridx);

  if yneedspadding(ridx)
    addedcount = addedcount + 1;
    newdata(ridx + addedcount,:) = olddata(ridx,:);
    newyedges(ridx + addedcount) = oldyedges(ridx + 1) - yepsilon;
  end
end
% Fencepost.
newyedges(rowcount + 1 + addedcount) = oldyedges(rowcount + 1);

olddata = newdata;

newdata = olddata(:,1);
newxedges = [];

addedcount = 0;
for cidx = 1:colcount
  newdata(:,cidx + addedcount,:) = olddata(:,cidx);
  newxedges(cidx + addedcount) = oldxedges(cidx);

  if xneedspadding(cidx)
    addedcount = addedcount + 1;
    newdata(:,cidx + addedcount) = olddata(:,cidx);
    newxedges(cidx + addedcount) = oldxedges(cidx + 1) - xepsilon;
  end
end
% Fencepost.
newxedges(colcount + 1 + addedcount) = oldxedges(colcount + 1);


% Done.
end


%
% This is the end of the file.
