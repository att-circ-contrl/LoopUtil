function [ expvar basis ] = nlBasis_getBasisDirectICA( ...
  datavalues, basiscounts, minexpvar, verbosity )

% function [ expvar basis ] = nlBasis_getBasisDirectICA( ...
%   datavalues, basiscounts, minexpvar, verbosity )
%
% This performs independent component analysis of a set of input vectors and
% expresses the result as a basis vector decomposition per BASISVECTORS.txt.
%
% This performs ICA directly on the input (without performing PCA first).
%
% Mean subtraction is not performed; the mean across channels is treated as
% part of the signal rather than as background.
%
% NOTE - Performing ICA on raw time-series waveforms takes a while.
%
% "datavalues" is a Nvectors x Ntimesamples matrix of sample vectors. For
%   ephys data, this is typically Nchans x Ntimesamples.
% "basiscounts" is a vector containing independent component counts to test.
% "minexpvar" is the minimum explained variance to accept. If this is NaN,
%   the component count with the maximum explained variance is chosen. If
%   this is not NaN, then the smallest component count with an explained
%   variance above minexpvar is chosen (or the largest explained variance
%   if none are above-threshold).
% "verbosity" is 'verbose', 'normal', or 'quiet'.
%
% "expvar" is the explained variance of the ICA decomposition.
% "basis" is a structure describing the ICA decomposition, per
%   BASISVECTORS.txt. The background is zero.


expvar = NaN;
basis = struct([]);


scratch = size(datavalues);
nvectors = scratch(1);
ntimesamps = scratch(2);

zerobg = zeros(1,ntimesamps);


% Sort the basis counts to test, so that we can identify the smallest that
% reaches the threshold.
basiscounts = sort(basiscounts);


% If we aren't using a threshold, ask for an impossibly high threshold.
if isnan(minexpvar)
  minexpvar = inf;
end


for bidx = 1:length(basiscounts)

  nbasis = basiscounts(bidx);

  % Bail out if we're asked for more components than data points.
  if nbasis > nvectors
    continue;
  end


  % Get this decomposition.

  % NOTE - Adding timestamps, since some use cases take a while.

  if strcmp(verbosity, 'verbose')
    disp(sprintf( '.. Getting %d basis vectors using ICA (%s).', ...
      nbasis, char(datetime) ));
  end

  tic;

  ricamodel = rica( datavalues, nbasis );

  icatime = euUtil_makePrettyTime(toc);

  thisbasis = transpose( ricamodel.TransformWeights );
  thiscoeffs = transform( ricamodel, datavalues );

  thismodel = struct( 'basisvecs', thisbasis, 'coeffs', thiscoeffs, ...
      'background', zerobg );


  % Get the explained variance for this decomposition.
  thisfom = nlBasis_calcExplainedVariance( datavalues, thismodel );


  % If this is better than what we already have, store it.

  if isnan(expvar) || (thisfom > expvar)
    expvar = thisfom;
    basis = thismodel;
  end

  if strcmp(verbosity, 'verbose')
    disp(sprintf( ...
      '.. ICA with %d basis vectors gave a FOM of %.3f after %s.', ...
      nbasis, thisfom, icatime ));
  elseif ~strcmp(verbosity, 'quiet')
    disp(sprintf( ...
      '.. ICA with %d basis vectors gave a FOM of %.3f.', ...
      nbasis, thisfom ));
  end

end


% Done.
end


%
% This is the end of the file.
