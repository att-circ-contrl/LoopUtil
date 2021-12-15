function newtable = nlIO_quoteTableStrings(oldtable)

% function newtable = nlIO_quoteTableStrings(oldtable)
%
% This function returns a copy of the input table with all string cell values
% and all column names in quotes.
%
% This is a workaround for an issue with "writetable". If "writetable" is
% called to write CSV with 'QuoteStrings' set to true, only cell values are
% quoted, not column names. If column names are manually quoted, they get
% triple quotes. The solution is to set 'QuoteStrings' false and manually
% quote all strings and all column names, which this function does.

newtable = table();

colnames = oldtable.Properties.VariableNames;

for cidx = 1:length(colnames)
  thislabel = colnames{cidx};
  thisdata = oldtable.(thislabel);

  % String data is only stored in cell arrays.
  % Cell arrays might contain other types of data too, though.
  if iscell(thisdata)
    for didx = 1:length(thisdata)
      thisval = thisdata{didx};
      if ischar(thisval)
        thisval = [ '"' thisval '"' ];
      end
      thisdata{didx} = thisval;
    end
  end

  thislabel = [ '"' thislabel '"' ];
  newtable.(thislabel) = thisdata;
end


% Done.

end


%
% This is the end of the file.
