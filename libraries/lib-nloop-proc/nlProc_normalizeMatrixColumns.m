function newmatrix = nlProc_normalizeMatrixColumns( oldmatrix, normrange )

% function newmatrix = nlProc_normalizeMatrixColumns( oldmatrix, normrange )
%
% This normalizes the columns of a matrix so that for each column the sum of
% that column's absolute values is equal to a column quota value drawn from
% the specified normalization range.
%
% This works most intuitively with a data range of [ 0 1 ], but can work
% with any real-valued data.
%
% "oldmatrix" is the matrix to normalize.
% "normrange" [ min max ] is the range of values to draw each column's quota
%   from. Quota values are uniformly distributed in this range, and each
%   column is normalized so that its absolute values sum to the quota.
%
% "newmatrix" is a copy of "oldmatrix" with columns normalized.


% Wrap the row-normalization function.

newmatrix = transpose(oldmatrix);
newmatrix = nlProc_normalizeMatrixRows( newmatrix, normrange );
newmatrix = transpose(newmatrix);


% Done.
end


%
% This is the end of the file.
