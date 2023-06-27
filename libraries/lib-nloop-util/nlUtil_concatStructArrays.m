function newlist = nlUtil_concatStructArrays(firstlist, secondlist)

% function newlist = nlUtil_concatStructArrays(firstlist, secondlist)
%
% This concatenates two structure arrays. It does this field by field, so
% that any missing fields are added and initialized.
%
% If the two source structures are known to have the same fields, use
% horzcat/vertcat instead.
%
% "firstlist" is a structure array.
% "secondlist" is a structure array.
%
% "newlist" is a structure array containing the elements of "firstlist" and
%   "secondlist".


newlist = firstlist;

newcount = length(newlist);
fieldlist = fieldnames(secondlist);

for sidx = 1:length(secondlist)

  thisrec = secondlist(sidx);
  newcount = newcount + 1;

  for fidx = 1:length(fieldlist)
    thisfield = fieldlist{fidx};
    newlist(newcount).(thisfield) = thisrec.(thisfield);
  end

end


% Done.
end


%
% This is the end of the file.
