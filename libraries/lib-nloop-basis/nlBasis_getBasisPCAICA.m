function [ expvar basis ] = nlBasis_getBasisPCAICA( ...
  datavalues, basiscounts, minexpvar, verbosity, pcamaxbasis, pcaminexpvar )

% function [ expvar basis ] = nlBasis_getBasisPCAICA( ...
%   datavalues, basiscounts, minexpvar, verbosity, pcamaxbasis, pcaminexpvar )
%
% This performs principal component analysis of a set of input vectors to get
% an intermediate representation of the input, and then performs independent
% component analysis in PCA space. The resulting basis vectors are transformed
% back into signal space and expressed as a basis vector decomposition per
% BASISVECTORS.txt.
%
% The mean (which is removed by PCA) is saved as the "background" in the
% decomposition.
%
% "datavalues" is a Nvectors x Ntimesamples matrix of sample vectors. For
%   ephys data, this is typically Nchans x Ntimesamples.
%
% "basiscounts" is a vector containing independent component counts to test.
% "minexpvar" is the minimum explained variance to accept. If this is NaN,
%   the component count with the maximum explained variance is chosen. If
%   this is not NaN, then the smallest component count with an explained
%   variance above minexpvar is chosen (or the largest explained variance
%   if none are above-threshold).
% "verbosity" is 'verbose', 'normal', or 'quiet'.
% "pcamaxbasis" is the maximum number of PCA components to use in the first
%   step. If NaN or omitted, this defaults to 20.
% "pcaminexpvar" is the minimum explained variance to accept in the PCA
%   decomposition. If NaN or omitted, this defaults to 0.98. If this target
%   can't be met, the maximum number of PCA components is used.
%
% "expvar" is the explained variance of the PCA-ICA decomposition.
% "basis" is a structure describing the PCA-ICA decomposition, per
%   BASISVECTORS.txt. The mean is saved as the background.


expvar = NaN;
basis = struct([]);


scratch = size(datavalues);
nvectors = scratch(1);
ntimesamps = scratch(2);


% Sort the basis counts to test, so that we can identify the smallest that
% reaches the threshold.
basiscounts = sort(basiscounts);


% Set PCA parameters to defaults if they aren't specified.

if ~exist('pcamaxbasis', 'var')
  pcamaxbasis = NaN;
end
if ~exist('pcaminexpvar', 'var')
  pcaminexpvar = NaN;
end

if isnan(pcamaxbasis)
  pcamaxbasis = 20;
end
% Use at least 3 components for PCA.
pcaminbasis = 3;
pcamaxbasis = max(pcamaxbasis, pcaminbasis);

if isnan(pcaminexpvar)
  pcaminexpvar = 0.98;
end


% NOTE - We need to have at least as many data points as our minimum number
% of PCA basis vectors.
if nvectors < pcaminbasis
  return;
end


if strcmp(verbosity, 'verbose')
  disp('.. Getting basis vectors using ICA on PCA-transformed input.');
end



%
% First pass: Get a PCA transformation into a lower-dimensional space.

[ pcaexpvar pcamodel ] = nlBasis_getBasisPCA( ...
  datavalues, pcaminbasis:pcamaxbasis, pcaminexpvar, 'quiet' );

% Figure out how many components we actually had.
chosenpcacount = size(pcamodel.basisvecs);
chosenpcacount = chosenpcacount(1);

if strcmp(verbosity, 'verbose')
  disp(sprintf( '.. Used %d PCA components (%.1f %% of variance).', ...
    chosenpcacount, pcaexpvar * 100 ));
end


%
% Second pass: Perform ICA on the transformed input.

% NOTE - Since we're computing the FOM with respect to the original signal,
% we have to explicitly iterate rather than letting the ICA helper do it.

for bidx = 1:length(basiscounts)

  nbasis = basiscounts(bidx);

  % Bail out if we're trying to get more components than data points.
  if nbasis > nvectors
    continue;
  end


  % Get the ICA decomposition of the Nvectors x Npca coefficient matrix
  % instead of the Nvectors x Ntime data matrix.
  % The ICA basis is in PCA space.

  [ thisfom icamodel ] = nlBasis_getBasisDirectICA( ...
    pcamodel.coeffs, nbasis, minexpvar, 'quiet' );


  % Invert the PCA transformation to get the time-domain basis vectors.

  % data = pcacoeffs * pcabasis
  % data = (icacoeffs * icabasis) * pcabasis
  % data = icacoeffs * (icabasis * pcabasis)
  % data = icacoeffs * thisbasis

  thisbasis = icamodel.basisvecs * pcamodel.basisvecs;
  thiscoeffs = icamodel.coeffs;

  thismodel = struct( 'basisvecs', thisbasis, 'coeffs', thiscoeffs, ...
    'background', pcamodel.background );


  % Get the explained variance for this decomposition.
  thisfom = nlBasis_calcExplainedVariance( datavalues, thismodel );


  % If this is better than what we already have, store it.

  if isnan(expvar) || (thisfom > expvar)
    expvar = thisfom;
    basis = thismodel;
  end

  if ~strcmp(verbosity, 'quiet')
    disp(sprintf( ...
      '.. PCA-ICA with %d basis vectors gave a FOM of %.3f.', ...
      nbasis, thisfom ));
  end

end


% Done.
end


%
% This is the end of the file.
