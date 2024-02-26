function [ datamean datadev dataperc ] = ...
  nlProc_calcMatrixStats( datamatrix, perclist )

% function [ datamean datadev dataperc ] = ...
%   nlProc_calcMatrixStats( datamatrix, perclist )
%
% This calculates the mean, standard deviation, and various other measures
% about the contents of a matrix.
%
% "datamatrix" is a matrix of any dimensionality containing data values.
% "perclist" is a vector containing percentile thresholds (which can be []).
%   These values are in percent (i.e. ranging from 0 to 100).
%
% "datamean" is the mean of the non-NaN entries in "datamatrix".
% "datadev" is the standard deviation of the non-NaN entries in "datamatrix".
% "dataperc" is a vector containing Nth-percentile values of the non-NaN
%   entries in "datamatrix", for each specified percentile in "perclist".


datamean = NaN;
datadev = NaN;
dataperc = [];


% This produces a linear array as output.
datamatrix = datamatrix(~isnan(datamatrix));


if ~isempty(datamatrix)
  datamean = mean(datamatrix);
  datadev = std(datamatrix);

  if ~isempty(perclist)
    dataperc = prctile(datamatrix, perclist);
  end
end


% Done.
end


%
% This is the end of the file.
