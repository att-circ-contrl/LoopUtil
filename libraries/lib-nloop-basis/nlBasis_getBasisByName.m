function [ fomvalue basis ] = nlBasis_getBasisByName( ...
  datavalues, basiscounts, minfom, method, verbosity )

% function [ fomvalue basis ] = nlBasis_getBasisByName( ...
%   datavalues, basiscounts, minfom, method, verbosity )
%
% This calls nlBasis_getBasisXX() to get a basis vector decomposition of
% input data by a user-specified method.
%
% "datavalues" is a Nvectors x Ntimesamples matrix of sample vectors. For
%   ephys data, this is typically Nchans x Ntimesamples.
% "basiscounts" is a vector containing basis component counts to test.
% "minfom" is the minimum figure of merit value to accept. If this is NaN,
%   the component count with the maximum figure of merit value is chosen. If
%   this is not NaN, then the smallest component count with a figure of
%   merit above minfom is chosen (or the largest figure of merit value if
%   none are above-threshold).
% "method" is 'kmeans', 'pca', 'ica_direct', or 'ica_pca'.
% "verbosity" is 'verbose', 'normal', or 'quiet'.
%
% "fomvalue" is a figure-of-merit value (typically fraction of explained
%   variance).
% "basis" is a structure describing the decomposition, per BASISVECTORS.txt.


fomvalue = NaN;
basis = struct([]);


methodlut = struct( ...
  'kmeans', @nlBasis_getBasisKmeans, ...
  'pca', @nlBasis_getBasisPCA, ...
  'ica_direct', @nlBasis_getBasisDirectICA, ...
  'ica_pca', @nlBasis_getBasisPCAICA );


if isfield( methodlut, method )
  [ fomvalue basis ] = ...
    methodlut.(method)( datavalues, basiscounts, minfom, verbosity );
else
  disp([ '### [nlBasis_getBasisByName]  Unknown method "' method '".' ]);
end


% Done.
end


%
% This is the end of the file.
