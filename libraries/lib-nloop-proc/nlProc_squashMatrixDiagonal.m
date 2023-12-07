function newmatrix = nlProc_squashMatrixDiagonal( oldmatrix )

% function newmatrix = nlProc_squashMatrixDiagonal( oldmatrix )
%
% This sets all diagonal elements of the input matrix to zero.
% The input matrix does not have to be square.
%
% "oldmatrix" is the matrix to modify.
%
% "newmatrix" is a copy of "oldmatrix" with diagonal elements set to zero.

newmatrix = oldmatrix;

mindim = min(size(newmatrix));

for idx = 1:mindim
  newmatrix(idx,idx) = 0;
end


% Done.
end


%
% This is the end of the file.
