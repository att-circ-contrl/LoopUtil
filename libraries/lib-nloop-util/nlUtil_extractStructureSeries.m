function dataseries = ...
  nlUtil_extractStructureSeries( structlist, fieldwanted )

% function dataseries = ...
%   nlUtil_extractStructureSeries( structlist, fieldwanted )
%
% This accepts a structure array or a cell array of structures and compiles
% a data series containing values extracted from a specific structure field.
%
% This is intended for computing global statistics across data series stored
% in records.
%
% This will tolerate non-numeric data (such as cell arrays).
%
% If the requested field isn't found, an empty vector will be returned.
%
% "structlist" is a structure array or a cell array containing structures.
% "fieldwanted" is the name of the field to extract.
%
% "dataseries" is a 1xN vector containing the concatenated data series from
%   the specified structure fields. Each field's contents is reshaped to
%   a linear vector before being concatenated.

dataseries = [];

for ridx = 1:length(structlist)

  if iscell(structlist)
    thisrec = structlist{ridx};
  else
    thisrec = structlist(ridx);
  end

  if isfield(thisrec, fieldwanted)
    thisdata = thisrec.(fieldwanted);
    thisdata = reshape( thisdata, [ 1 prod(size(thisdata)) ] );

    if isempty(dataseries)
      dataseries = thisdata;
    else
      dataseries = [ dataseries thisdata ];
    end
  end

end


% Done.
end


%
% This is the end of the file.
