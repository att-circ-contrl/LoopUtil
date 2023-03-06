function ismatch = ...
  nlUtil_testXMLStructAttributes( xmlstruct, attribswanted )

% function ismatch = ...
%   nlUtil_testXMLStructAttributes( xmlstruct, attribswanted )
%
% This searches through an XML parse structure (returned by readstruct()),
% and determines whether the top-level node matches the desired attribute
% criteria.
%
% "xmlstruct" is a structure containing an XML parse tree (per readstruct()).
% "attribswanted" is a cell array containing names and values of attributes
%   to match. If _all_ specified attributes match _any_ of their permitted
%   values, or if "attribswanted" is empty, the structure matches. The cell
%   array has the form { 'attr1', { 'val1', 'val2' }, 'attr2', ... }. Matched
%   values are character arrays and are not sensitive to case.
%
% "ismatch" is true if "xmlstruct" matches the desired attribute criteria
%   and false otherwise.


% Matlab's "readstruct()" function stores three types of field:
% - "Text" contains text that was outside of child tags, within the top-level
%   tag.
% - "Foo" is one or more "<Foo>" child tags, stored as a structure array.
% - "BarAttribute" is a "<Foo Bar="abc">" attribute for the top-level tag.


ismatch = true;


flist = fieldnames(xmlstruct);

% Walk through the desired attributes list.
for aidx = 2:2:length(attribswanted)

  desiredname = attribswanted{aidx-1};
  desiredvaluelist = attribswanted{aidx};

  % Remember that names have "Attribute" appended.
  desiredname = [ desiredname 'Attribute' ];

  % This returns an empty list if there are no matches.
  % Doing it this way allows case-insensitive matching.

  fidx = min(find(strcmpi( desiredname, flist )));
  if isempty(fidx)
    % This attribute wasn't present.
    ismatch = false;
  else
    thisfname = flist{fidx};
    thisval = xmlstruct.(thisfname);

    if ~any(strcmpi( thisval, desiredvaluelist ))
      % This attribute was present but didn't match any permitted value.
      ismatch = false;
    end
  end

end


% Done.
end

%
% This is the end of the file.
