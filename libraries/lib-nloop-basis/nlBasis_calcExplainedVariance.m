function expvar = nlBasis_calcExplainedVariance( datavalues, basis )

% function expvar = nlBasis_calcExplainedVariance( datavalues, basis )
%
% This function estimates the explained variance of a basis vector model
% reconstruction of supplied data.
%
% For well-behaved distributions, the explained variance fraction is the
% square of the correlation coefficient of the original and reconstructed
% signals.
%
% This function calculates the mean across Nvectors in the original data
% and subtracts it from the original and reconstruction when calculating
% the variance. The mean would otherwise greatly inflate the explained
% variance.
%
% "datavalues" is a Nvectors x Ntimesamples matrix of sample vectors. For
%   ephys data, this is typically Nchans x Ntimesamples.
% "basis" is a structure describing a basis vector decomposition of the
%   data, per BASISVECTORS.txt.
%
% "expvar" is the fraction of the variance explained by the decomposition.


expvar = NaN;


scratch = size(datavalues);
nvectors = scratch(1);
ntimesamps = scratch(2);


databackground = sum(datavalues, 1) / nvectors;


% Calculate this row by row instead of getting the full reconstructed
% dataset, since the dataset may be large.

rvalues = [];

for vidx = 1:nvectors
  thisdata = datavalues(vidx,:);

  thiscoeffs = basis.coeffs(vidx,:);
  thisrecon = thiscoeffs * basis.basisvecs + basis.background;

  thisdata = thisdata - databackground;
  thisrecon = thisrecon - databackground;

  thisrmatrix = corrcoef( thisrecon, thisdata );
  rvalues(vidx) = thisrmatrix(1,2);
end

expvar = mean(rvalues .* rvalues);


% Done.
end


%
% This is the end of the file.
