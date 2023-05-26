function newmatrix = nlProc_fillNaNRows( oldmatrix )

% function newmatrix = nlProc_fillNaNRows( oldmatrix )
%
% This accepts a Nvectors x Ntimesamples matrix and calls nlProc_fillNaN to
% fill gaps in each of the matrix rows.
%
% "oldmatrix" is a Nvectors x Ntimesamples matrix containing NaN segments.
%
% "newmatrix" is an interpolated copy of "oldmatrix" without NaN segments.


newmatrix = oldmatrix;

scratch size(oldmatrix);
rowcount = scratch(1);

for ridx = 1:rowcount
  thisrow = oldmatrix(ridx,:);
  thisrow = nlProc_fillNaN(thisrow);
  oldmatrix(ridx,:) = thisrow;
end


% Done.
end


%
% This is the end of the file.
