function newtable = ...
  nlProc_binTableDataSimple( oldtable, bindefs, testorder, newcol )

% function newtable = ...
%  nlProc_binTableDataSimple( oldtable, bindefs, testorder, newcol )
%
% This applies catagory labels to table data rows by partitioning based on
% values in one or more table columns. Category labels are character arrays.
%
% "oldtable" is the table to apply labels to.
% "bindefs" is a structure indexed by category label. Each field contains
%   a structure array specifying conditions for that category label. A
%   condition structure contains the following fields:
%     "source" is the column to test.
%     "range" [min max] is the range of accepted values.
%     "negate" is true to only accept values _outside_ the range.
%   All conditions must match for the label to be applied. Tests on
%   non-existent source columns automatically fail.
% "testorder" is a cell array of category labels specifying the order in
%   which to test bin definitions. The last successful test determines the
%   label applied. Labels that don't have bin definitions automatically
%   succeed (this is useful for specifying a default label). Bin definitions
%   not in this list aren't tested.
% "newcol" is the name of the column to store category labels in.
%
% "newtable" is a copy of "oldtable" with the category label column added.


newtable = oldtable;
tabheight = height(oldtable);
colnames = oldtable.Properties.VariableNames;


% Initialize the new column.
% This has to contain something; the user might not specify a default.
% Make sure this is a column vector, as well.

newlabels = {};
newlabels(1:tabheight,1) = { 'no_match' };


% Walk through the specified conditions, testing them.

for tidx = 1:length(testorder)
  thiscat = testorder{tidx};

  if ~isfield(bindefs, thiscat)
    % Label without a bin definition. Apply it to everything.
    newlabels(1:tabheight,1) = { thiscat };
  else

    % Walk through the specified list of tests.

    thisdef = bindefs.(thiscat);
    thismask = [];
    thismask(1:tabheight,1) = true;

    for didx = 1:length(thisdef)
      thissrc = thisdef(didx).source;
      thisrange = thisdef(didx).range;
      thisneg = thisdef(didx).negate;

      if ~ismember(thissrc, colnames)
        % Tests on non-existent columns automatically fail.
        thismask(1:tabheight,1) = false;
      else
        thisdata = oldtable.(thissrc);
        thistest = ...
          (thisdata >= min(thisrange)) & (thisdata <= max(thisrange));
        if thisneg
          thistest = ~thistest;
        end
        thismask = thismask & thistest;
      end
    end

    % Apply the new label to any matching rows.
    newlabels(thismask) = { thiscat };

  end
end


% Store the new category column.

newtable.(newcol) = newlabels;


% Done.

end


%
% This is the end of the file.
