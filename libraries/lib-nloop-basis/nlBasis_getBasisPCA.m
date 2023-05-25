function [ expvar basis ] = nlBasis_getBasisPCA( ...
  datavalues, basiscounts, minexpvar, verbosity )

% function [ expvar basis ] = nlBasis_getBasisPCA( ...
%   datavalues, basiscounts, minexpvar, verbosity )
%
% This performs principal component analysis of a set of input vectors and
% expresses the result as a basis vector decomposition per BASISVECTORS.txt.
%
% The mean (which is removed by PCA) is saved as the "background" in the
% decomposition.
%
% "datavalues" is a Nvectors x Ntimesamples matrix of sample vectors. For
%   ephys data, this is typically Nchans x Ntimesamples.
% "basiscounts" is a vector containing principal component counts to test.
% "minexpvar" is the minimum explained variance to accept. If this is NaN,
%   the component count with the maximum explained variance is chosen. If
%   this is not NaN, then the smallest component count with an explained
%   variance above minexpvar is chosen (or the largest explained variance
%   if none are above-threshold).
% "verbosity" is 'normal' or 'quiet'.
%
% "expvar" is the explained variance of the PCA decomposition.
% "basis" is a structure describing the PCA decomposition, per
%   BASISVECTORS.txt. The mean is saved as the background.


expvar = NaN;
basis = struct([]);


scratch = size(datavalues);
nvectors = scratch(1);
ntimesamps = scratch(2);


maxbasiscount = max(basiscounts);
% We can only have as many components as we have data vectors.
maxbasiscount = min(maxbasiscount, nvectors);

% Sort the basis counts to test, so that we can identify the smallest that
% reaches the threshold.
basiscounts = sort(basiscounts);


% If we aren't using a threshold, ask for an impossibly high threshold.
if isnan(minexpvar)
  minexpvar = inf;
end



% NOTE - Because this uses the covariance matrix, we need to have more
% than one data vector.
if nvectors < 2
  return;
end

if ~strcmp(verbosity, 'quiet')
%  disp('.. Getting basis vectors using PCA.');
end


% Get the PCA decomposition. We only need to do this once.

[ pcabasis, pcaweights, ~, ~, pcaexplained, pcamean ] = ...
  pca( datavalues, 'NumComponents', maxbasiscount );


% Sort through the basis vectors we got out and figure out how many to
% keep.

% NOTE - Explained variance increases monotonically, so if we don't have
% a valid threshold we'll always get the maximum number of basis vectors
% out. Iterating is still cheap, so don't bother special-casing that.

for bidx = 1:length(basiscounts)

  % Bail out if we've already met our stopping criteria.
  % This returns false for NaN.

  if expvar >= minexpvar
    continue;
  end


  % Bail out if we're asking for more components than we have.

  nbasis = basiscounts(bidx);

  if nbasis > nvectors
    continue;
  end


  % Evaluate decomposition with this many vectors.

  thisfom = sum( pcaexplained(1:nbasis) );
  thisfom = thisfom / 100;

  % In pcabasis, the columns are basis vectors. We want rows.
  thisbasis = transpose(pcabasis);
  thisbasis = thisbasis(1:nbasis,:);

  thiscoeffs = pcaweights(:,1:nbasis);

  % pcamean is already a row vector.


  % If this is better than what we already have, store it.

  if isnan(expvar) || (thisfom > expvar)
    expvar = thisfom;
    basis = struct( 'basisvecs', thisbasis, 'coeffs', thiscoeffs, ...
      'background', pcamean );
  end


  % Tattle, if requested.
  if ~strcmp(verbosity, 'quiet')
    disp(sprintf( ...
      '.. PCA with %d basis vectors gave a FOM of %.3f.', ...
      nbasis, thisfom ));
  end

end


% Done.
end


%
% This is the end of the file.
