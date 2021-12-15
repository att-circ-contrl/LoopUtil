function outdata = nlUtil_structToTable(indata, ignorelist)

% function outdata = nlUtil_structToTable(indata, ignorelist)
%
% This converts a structure into a table. Table columns correspond to
% structure fields. Structure vectors forced to Nx1 (column) format.
% Specified structure fields may be skipped.
% NOTE - Data fields must all have the same length!
%
% "indata" is the structure to convert.
% "ignorelist" is a cell array containing structure field names to skip.
%
% "outdata" is a table with columns containing structure field data.


% Make a clean, filtered version of the input.

newstruct = struct();
colnames = fieldnames(indata);

for cidx = 1:length(colnames)
  thisname = colnames{cidx};
  if ~ismember(thisname, ignorelist)
    thisdata = indata.(thisname);

    % Force this to be a column vector.
    thisdata = nlUtil_forceRow(thisdata);
    thisdata = thisdata';

    newstruct.(thisname) = thisdata;
  end
end


% Build the table.
outdata = struct2table(newstruct);


% Done.

end


%
% This is the end of the file.
