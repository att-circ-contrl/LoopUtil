function newbasis = nlBasis_getBackgroundCommon( oldbasis )

% function newbasis = nlBasis_getBackgroundCommon( oldbasis )
%
% This takes a basis decomposition structure and moves components that are
% common to all inputs to the background vector. The coefficient matrix is
% adjusted to remove these background components from the signal vectors.
%
% This works by calling nlBasis_getBackgroundResidue() to move all basis
% components to the signal vectors, and then taking the minimum or maximum
% coefficient value for each basis as that basis's contribution to the
% common background.
%
% "oldbasis" is a structure defining the basis decomposition, per
%   BASISVECTORS.txt.
%
% "newbasis" is a modified version of "oldbasis" with the same basis vectors
%   but with weight coefficients and the background modified.


newbasis = nlBasis_getBackgroundResidue( oldbasis );


scratch = size(newbasis.coeffs);
nvectors = scratch(1);
nbasis = scratch(2);


% For each basis vector, get the smallest coefficient min/max and add that
% component to the background, subtracting from the foreground.
for bidx = 1:nbasis

  thiscoefflist = newbasis.coeffs(:,bidx);
  thismin = min(thiscoefflist);
  thismax = max(thiscoefflist);

  thiscoeff = thismin;
  if abs(thismax) < abs(thismin)
    thiscoeff = thismax;
  end

  thisvec = newbasis.basisvecs(bidx,:);
  newbasis.background = newbasis.background + thisvec * thiscoeff;

  thiscoefflist = thiscoefflist - thiscoeff;
  newbasis.coeffs(:,bidx) = thiscoefflist;
end


% Done.
end


%
% This is the end of the file.
