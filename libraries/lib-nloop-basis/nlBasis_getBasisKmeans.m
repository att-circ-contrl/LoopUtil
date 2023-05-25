function [ silval basis ] = nlBasis_getBasisKmeans( ...
  datavalues, kvalues, minsilval, verbosity )

% function [ silval basis ] = nlBasis_getBasisKmeans( ...
%   datavalues, kvalues, minsilval, verbosity )
%
% This performs k-means decomposition of a set of input vectors and expresses
% the result as a basis vector decomposition with each mean being one basis.
%
% Basis vector decompositions are described in BASISVECTORS.txt. Expressing
% k-means in this form is intended to make it easier to use various auxiliary
% functions with the resulting decomposition. Coefficients are 1 for the each
% input vector's cluster mean and 0 otherwise, with a background of zero
% (so this doesn't actually do a real basis decomposition of the input).
%
% Silhouette values range from -1 to +1. A "good" decomposition has a
% silhouette value of at least 0.6.
%
% "datavalues" is a Nvectors x Ntimesamples matrix of sample vectors. For
%   ephys data, this is typically Nchans x Ntimesamples.
% "kvalues" is a vector containing cluster counts to test.
% "minsilval" is the minimum silhouette value to accept. If this is NaN,
%   all k values are tested and the one with the maximum silhouette value is
%   chosen. If this is not NaN, then the smallest k value with a silhouette
%   value of at least minsilval is chosen (or the largest silhouette value
%   if none are above-threshold).
% "verbosity" is 'normal' or 'quiet'.
%
% "silval" is the silhouette value of the k-means decomposition.
% "basis" is a structure describing the k-means decomposition, per
%   BASISVECTORS.txt. Each mean is one basis vector. The background is zero.


silval = NaN;
basis = struct([]);


% FIXME - Magic values.
% We have to repeat k-means many times to get somewhat-consistent results.

% 100x is tolerable. 1000x is very slightly better. Compromise at 300x.
repeat_count_kmeans = 300;



scratch = size(datavalues);
nvectors = scratch(1);
ntimesamps = scratch(2);

zerobg = zeros(1,ntimesamps);


% Sort the k values to test, so that we can identify the smallest that
% reaches the threshold.
kvalues = sort(kvalues);


% If we aren't using a threshold, ask for an impossibly high threshold.
if isnan(minsilval)
  minsilval = inf;
end


for kidx = 1:length(kvalues)

  nbasis = kvalues(kidx);

  % Bail out if we're asked for more clusters than data points.
  if nbasis > nvectors
    continue;
  end

  % Bail out if we've met our stopping criteria.
  % This returns false for NaN.
  if silval >= minsilval
    continue;
  end


  % Get this decomposition and its figure of merit.

  [ clustlabels, clustvecs, distsums ] = ...
    kmeans( datavalues, nbasis, 'Replicates', repeat_count_kmeans );

  thisbasis = clustvecs;

  thiscoeffs = zeros(nvectors, nbasis);
  for vidx = 1:nvectors
    thiscoeffs(vidx, clustlabels(vidx)) = 1;
  end

  thisfom = mean( silhouette(datavalues, clustlabels) );


  % If this is better than what we already have, store it.

  if isnan(silval) || (thisfom > silval)
    silval = thisfom;
    basis = struct( 'basisvecs', thisbasis, 'coeffs', thiscoeffs, ...
      'background', zerobg );
  end


  % Tattle, if requested.

  if ~strcmp(verbosity, 'quiet')
    disp(sprintf( ...
      '.. K-means quantization with %d vectors gave a FOM of %.3f.', ...
      nbasis, thisfom ));
  end

end


% Done.
end


%
% This is the end of the file.
