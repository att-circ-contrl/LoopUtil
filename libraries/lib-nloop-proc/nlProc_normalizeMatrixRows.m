function newmatrix = nlProc_normalizeMatrixRows( oldmatrix, normrange )

% function newmatrix = nlProc_normalizeMatrixRows( oldmatrix, normrange )
%
% This normalizes the rows of a matrix so that for each row the sum of that
% row's absolute values is equal to a row quota value drawn from the
% specified normalization range.
%
% This works most intuitively with a data range of [ 0 1 ], but can work
% with any real-valued data.
%
% "oldmatrix" is the matrix to normalize.
% "normrange" [ min max ] is the range of values to draw each row's quota
%   from. Quota values are uniformly distributed in this range, and each row
%   is normalized so that its absolute values sum to the quota.
%
% "newmatrix" is a copy of "oldmatrix" with rows normalized.


% Initialize.
newmatrix = oldmatrix;


% Convert to absolute values.

signmatrix = sign(newmatrix);
newmatrix = abs(newmatrix);


% Walk through the matrix, normalizing each row.

rowcount = size(newmatrix,1);

rowquotas = rand(1,rowcount);
rowquotas = rowquotas * (max(normrange) - min(normrange)) + min(normrange);

for ridx = 1:rowcount
  thisrow = newmatrix(ridx,:);
  scalefact = rowquotas(ridx) / sum(thisrow);
  newmatrix(ridx,:) = thisrow * scalefact;
end


% Turn these back into signed values.

newmatrix = newmatrix .* signmatrix;


% Done.
end


%
% This is the end of the file.
