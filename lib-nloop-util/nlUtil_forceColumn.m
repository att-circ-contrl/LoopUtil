function newseries = nlUtil_forceColumn(oldseries)

% function newseries = nlUtil_forceColumn(oldseries)
%
% This function forces a one-dimensional vector into Nx1 form.
%
% "oldseries" is a 1xN or Nx1 vector.
%
% "newseries" is the corresponding Nx1 vector.


% This is trivial code, but it's trivial code that I keep having to repeat.

if iscolumn(oldseries)
  newseries = oldseries;
else
  newseries = transpose(oldseries);
end


%
% Done.

end


%
% This is the end of the file.
