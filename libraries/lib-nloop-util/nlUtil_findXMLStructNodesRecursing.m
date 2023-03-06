function matches = nlUtil_findXMLStructNodesRecursing( ...
  xmlstruct, tagswanted, attribswanted )

% function matches = nlUtil_findXMLStructNodesRecursing( ...
%   xmlstruct, tagswanted, attribswanted )
%
% This searches through an XML parse structure (returned by readstruct()),
% and identifies tree nodes at any level that match desired criteria. This
% recurses within non-matching nodes (but not matching nodes).
%
% This will not match the top-level structure itself (if given an empty tags
% list and a non-empty attributes list). To test against that case, pass
% "struct( 'toplevel', xmlstruct )" as the input parse tree.
%
% "xmlstruct" is a structure containing an XML parse tree (per readstruct()).
% "tagswanted" is a cell array containing the names of tags to match. If this
%   is empty, all nodes match. Matching is not sensitive to case.
% "attribswanted" is a cell array containing names and values of attributes
%   to match. If _all_ specified attributes match _any_ of their permitted
%   values, or if "attribswanted" is empty, the node matches. The cell array
%   has the form { 'attr1', { 'val1', 'val2' }, 'attr2', ... }. Matched
%   values are character arrays and are not sensitive to case.
%
% "matches" is a cell array containing parse tree nodes that matched the
%   selection criteria. These are themselves XML parse structures.


% Matlab's "readstruct()" function stores three types of field:
% - "Text" contains text that was outside of child tags, within the top-level
%   tag.
% - "Foo" is one or more "<Foo>" child tags, stored as a structure array.
% - "BarAttribute" is a "<Foo Bar="abc">" attribute for the top-level tag.


% NOTE - Re-implementing instead of calling the top-level-only function so
% that the match list is given as an in-order traversal.


matches = {};

flist = fieldnames(xmlstruct);

% FIXME - Diagnostics.
%disp('Testing XML node with fields:');
%disp(flist);

for fidx = 1:length(flist)
  thisfname = flist{fidx};
  thisval = xmlstruct.(thisfname);

  % Only process child nodes, not text or attributes.
  if isstruct(thisval)

% FIXME - Diagnostics.
if false
% FIXME - Suppress output of ludicrously spammy channels
blacklist = { 'selectionstate', 'parameters' };
if ~any(strcmpi(thisfname, blacklist))
disp(sprintf( 'Processing %d tags with type "%s".', ...
length(thisval), thisfname ));
end
end

    % This is an array of child nodes.
    for cidx = 1:length(thisval)
      thischild = thisval(cidx);

      tagmatch = true;
      if ~isempty(tagswanted)
        % Allow case-insensitive matching.
        tagmatch = any(strcmpi( thisfname, tagswanted ));
      end

      attribmatch = nlUtil_testXMLStructAttributes(thischild, attribswanted);

      if tagmatch && attribmatch
        matches = [ matches { thischild } ];
      else
        % Recurse.
        childmatches = nlUtil_findXMLStructNodesRecursing( ...
          thischild, tagswanted, attribswanted );
        % This works even if an empty cell array was returned.
        matches = [ matches childmatches ];
      end
    end

  end
end


% Done.
end

%
% This is the end of the file.
