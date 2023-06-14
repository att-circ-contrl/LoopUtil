function newbasis = nlBasis_estimateBasisFromCoefficients( ...
  datavalues, coeffs, bgmethod )

% function newbasis = nlBasis_estimateBasisFromCoefficients( ...
%   datavalues, coeffs, bgmethod )
%
% This estimates basis vectors and background for a given set of signals,
% given a coefficient matrix.
%
% This is intended to be used to ensure consistent basis decompositions
% in situations where several different data matrices are derived from the
% same dataset. One data matrix is chosen as "canon" and decomposed, and
% the basis vectors in the other matrices are estimated using this function
% and the "canon" coefficients.
%
% "datavalues" is a Nvectors x Ntimesamples matrix of sample vectors. For
%   ephys data, this is typicaly Nchans x Ntimesamples.
% "coeffs" is a Nvectors x Nbasis matrix with basis vector weights for each
%   input vector, per BASISVECTORS.txt.
% "bgmethod" is 'zero' (background set to zero), 'average' (background set
%   to the average across channels), or 'basis' (background estimated by
%   treating it as an additional basis with weight 1 in all data vectors).
%
% "newbasis" is a basis description structure per BASISVECTORS.txt containing
%   a copy of "coeffs" along with estimated basis band background vectors.


% Get metadata.

scratch = size(coeffs);
nchans = scratch(1);
nbasis = scratch(2);

scratch = size(datavalues);
nsamples = scratch(2);


% Figure out how we're estimating background.

% Default is "zero".
want_bg_basis = strcmp(bgmethod, 'basis');
want_bg_average = strcmp(bgmethod, 'average');


% If we have a simple background method, compute it and subtract it from
% the data.

background = zeros(1,nsamples);

if want_bg_average
  for cidx = 1:nchans
    background = background + datavalues(cidx,:);
  end

  background = background / nchans;

  for cidx = 1:nchans
    datavalues(cidx,:) = datavalues(cidx,:) - background;
  end
end


% If we're treating the background as a basis vector, augment the coefficient
% matrix.

if want_bg_basis
  coeffs(:,(nbasis+1)) = ones(nchans,1);
end


% Solve for the basis vectors.

% NOTE - There's a closed-form expression that would give us a Nbasis x Nbasis
% square matrix to invert for a minimum-least-squares solution, but the
% pseudo-inverse should give us exactly the same result with fewer typos.

% We've subtracted the background, so recon = coeffs * basisvecs.
% pinv(coeffs) * recon = pinv(coeffs) * coeffs * basisvecs
% pinv(coeffs) * recon = basisvecs
% pinv(coeffs) * data = (approx) basisvecs

% As long as Nvectors >= Nbasis, we should get the left inverse matrix.


basisvecs = pinv(coeffs) * datavalues;


% If we're treating the background as a basis vector, extract it.

if want_bg_basis
  background = basisvecs((nbasis+1),:);
  basisvecs = basisvecs(1:nbasis,:);
  coeffs = coeffs(:,1:nbasis);
end


% Package the output.

newbasis = struct();
newbasis.basisvecs = basisvecs;
newbasis.coeffs = coeffs;
newbasis.background = background;


% Done.
end


%
% This is the end of the file.
