function newbasis = nlBasis_getBackgroundResidue( oldbasis )

% function newbasis = nlBasis_getBackgroundResidue( oldbasis )
%
% This takes a basis decomposition structure and removes all basis components
% from the background vector. The coefficient matrix is adjusted to add these
% background components to the signal vectors.
%
% "oldbasis" is a structure defining the basis decomposition, per
%   BASISVECTORS.txt.
%
% "newbasis" is a modified version of "oldbasis" with the same basis vectors
%   but with weight coefficients and the background modified.


newbasis = oldbasis;

scratch = size(oldbasis.coeffs);
nvectors = scratch(1);
nbasis = scratch(2);


% Express the supplied background as a linear combination of the basis
% vectors.
% NOTE - This helper function works best with orthogonal basis vectors.

[ bgcoeffs, bgresidue ] = nlBasis_decomposeSignalsUsingBasis( ...
  oldbasis.background, oldbasis.basisvecs );


% Add the linear component to the coefficients and store the residue as the
% new background.

newbasis.background = bgresidue;
newbasis.coeffs = newbasis.coeffs + repmat(bgcoeffs, nvectors, 1);


% Done.
end


%
% This is the end of the file.
