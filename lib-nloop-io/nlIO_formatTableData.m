function newtable = nlIO_formatTableData( oldtable, formatlut )

% function newtable = nlIO_formatTableData( oldtable, formatlut )
%
% This function converts the specified data columns in oldtable into strings,
% using "sprintf" with the format specified for that column's entry in the
% lookup table.
%
% "oldtable" is the table to convert.
% "formatlut" is a "containers.Map" object mapping table column names to
%   sprintf format character arrays.
%
% "newtable" is a copy of "oldtable" with the specified columns converted.


newtable = table();

colnames = oldtable.Properties.VariableNames;

for cidx = 1:length(colnames)
  thislabel = colnames{cidx};
  oldcoldata = oldtable.(thislabel);

  if ~isKey(formatlut, thislabel)
    % Not in the LUT; just copy the old data.
    newtable.(thislabel) = oldcoldata;
  else
    % In the LUT; translate data values to formatted strings.

    thisformat = formatlut(thislabel);
    newcoldata = {};

    % We're always writing to a cell array, but what we read from varies.
    if iscell(oldcoldata)
      % Reading from a cell array (probably string data).
      for didx = 1:length(oldcoldata)
        thisval = oldcoldata{didx};
        newcoldata{didx} = sprintf(thisformat, thisval);
      end
    else
      % Reading from a vector (probably numeric data).
      for didx = 1:length(oldcoldata)
        thisval = oldcoldata(didx);
        newcoldata{didx} = sprintf(thisformat, thisval);
      end
    end

    if ~iscolumn(newcoldata)
      newcoldata = transpose(newcoldata);
    end
    newtable.(thislabel) = newcoldata;
  end
end


% Done.

end


%
% This is the end of the file.
