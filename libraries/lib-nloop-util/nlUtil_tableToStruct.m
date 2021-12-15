function outdata = nlUtil_tableToStruct(indata, rowcol)

% function outdata = nlUtil_tableToStruct(indata, rowcol)
%
% This converts a table into a structure. Structure fields correspond to
% table columns, and are stored as either 1xN or Nx1 vectors.
%
% "indata" is the table to convert.
% "rowcol" is 'row' to output 1xN vectors and 'col' for Nx1 vectors.
%
% "outdata" is a structure containing table column data.


outdata = table2struct(indata, 'ToScalar', true);

if strcmp('row', rowcol)
  colnames = fieldnames(outdata);
  for cidx = 1:length(colnames)
    outdata.(colnames{cidx}) = nlUtil_forceRow( outdata.(colnames{cidx}) );
  end
end


% Done.

end


%
% This is the end of the file.
