function keepflags = nlProc_decimateBresenham( keepcount, origarray )

% function keepflags = nlProc_decimateBresenham( keepcount, origarray )
%
% This selects a subset of elements of a supplied vector to keep, and
% returns a logical vector indicating which to keep and which to discard.
%
% The idea is to be able to say "newarray = origarray(keepflags)" afterwards,
% or filter other arrays with the same geometry.
%
% This will provide output with multidimensional arrays, but because the
% decimation is performed using one-dimensional indexing the N-dimensional
% output may have aliasing patterns. It works best with one-dimensional
% vectors.
%
% "keepcount" is the desired number of elements to keep.
% "origarray" is a vector or cell array of arbitrary type (usually a label
%   or channel list) with the same dimensions as the element array to filter.
%
% "keepflags" is a boolean vector with the same dimensions as "origarray"
%   that's true for elements to be kept and false for elements to discard.


keepflags = true(size(origarray));

% Use one-dimensional indexing, even if input is multidimensional.
origcount = numel(origarray);

if origcount > keepcount

  % Use the Bresenham algorithm to decide which elements to keep.

  bres_err = round(0.5 * origcount);
  for oidx = 1:origcount
    bres_err = bres_err + keepcount;
    if bres_err >= origcount
      bres_err = bres_err - origcount;
    else
      keepflags(oidx) = false;
    end
  end

end


% Done.
end


%
% This is the end of the file.
