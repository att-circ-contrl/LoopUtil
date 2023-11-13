function newlist = nlUtil_sprintfCellArray( formatstr, oldlist )

% function newlist = nlUtil_sprintfCellArray( formatstr, oldlist )
%
% This applies sprintf(formatstr) to every element of a supplied cell array
% or vector, storing the resulted formatted strings in a new cell array.
%
% NOTE - Name notwithstanding, numeric input may be supplied as a vector
% as an alternative to supplying it as a cell array.
%
% "formatstr" is a character vector containing a sprintf format specifier
%   with one substitution code.
% "oldlist" is a cell array or vector containing scalars or character vectors
%   to substitute into the format specifier.
%
% "newlist" is a cell array with the same number of elements as "oldlist"
%   containing the resulting character vectors.


newlist = cell(size(oldlist));

for lidx = 1:length(oldlist)
  if iscell(oldlist)
    newlist{lidx} = sprintf( formatstr, oldlist{lidx} );
  else
    newlist{lidx} = sprintf( formatstr, oldlist(lidx) );
  end
end


% Done.
end


%
% This is the end of the file.
