function newseries = nlUtil_forceRow(oldseries)

% function newseries = nlUtil_forceRow(oldseries)
%
% This function forces a one-dimensional vector into 1xN form.
%
% "oldseries" is a 1xN or Nx1 vector.
%
% "newseries" is the corresponding 1xN vector.


% This is trivial code, but it's trivial code that I keep having to repeat.

if isrow(oldseries)
  newseries = oldseries;
else
  newseries = transpose(oldseries);
end


%
% Done.

end


%
% This is the end of the file.
