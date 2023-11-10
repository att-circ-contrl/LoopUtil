function resultlist = nlUtil_getCellOfStructField( ...
  cellofstruct, desiredfield, defaultvalue )

% function resultlist = nlUtil_getCellOfStructField( ...
%   cellofstruct, desiredfield, defaultvalue )
%
% This accepts a cell array of structures, examines each structure for the
% specified field, and returns a cell array or vector containing the field
% contents from each structure.
%
% This is intended to do what "{ foostruct.fieldname }" and
% "[ foostruct.fieldname ]" do for struct arrays, with cell arrays of
% structures (used when field names aren't consistent).
%
% "cellofstruct" is a cell array, where each cell contains a struct or a
%   struct array.
% "desiredfield" is the name of the field to look for.
% "defaultvalue" is the value to return for structures that are missing the
%   desired field. This also indicates the data type to look for; if
%   "defaultvalue" is a character vector, fields are assumed to contain
%   character vectors; otherwise they're assumed to have numeric or boolean
%   content.
%
% "resultlist" is a 1xN cell array (if handling character data) or vector
%   (if handling numeric/boolean data) with one entry per struct encountered
%   in the input.


wantcell = ischar(defaultvalue);

resultlist = [];
if wantcell
  resultlist = {};
end


for cidx = 1:length(cellofstruct)

  thisstruct = cellofstruct{cidx};

  if ~isempty(thisstruct)

    if ~isrow(thisstruct)
      thisstruct = transpose(thisstruct);
    end

    if isfield(thisstruct, desiredfield)
      if wantcell
        thisresult = { thisstruct.(desiredfield) };
      else
        thisresult = [ thisstruct.(desiredfield) ];
      end
    else
      if wantcell
        thisresult = cell([1 length(thisstruct)]);
        thisresult(:) = { defaultvalue };
      else
        thisresult = NaN([1 length(thisstruct)]);
        thisresult(:) = defaultvalue;
      end
    end

    resultlist = [ resultlist thisresult ];

  end

end


% Done.
end


%
% This is the end of the file.
