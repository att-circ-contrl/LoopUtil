function [ matches nonmatches ] = nlUtil_findXMLStructNodesTopLevel( ...
  xmlstruct, tagswanted, attribswanted )

% function [ matches nonmatches ] = nlUtil_findXMLStructNodesTopLevel( ...
%   xmlstruct, tagswanted, attribswanted )
%
% This searches through an XML parse structure (returned by readstruct()),
% and identifies tree nodes at the top level that match desired criteria.
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
% "matches" is a cell array containing top-level nodes that matched the
%   selection criteria. These are themselves XML parse structures.
% "nonmatches" is a cell array containing top-level nodes that did not match
%   the selection criteria. These are themselves XML parse structures.


% Matlab's "readstruct()" function stores three types of field:
% - "Text" contains text that was outside of child tags, within the top-level
%   tag.
% - "Foo" is one or more "<Foo>" child tags, stored as a structure array.
% - "BarAttribute" is a "<Foo Bar="abc">" attribute for the top-level tag.


matches = {};
nonmatches = {};


flist = fieldnames(xmlstruct);

matchcount = 0;
nonmatchcount = 0;

for fidx = 1:length(flist)
  thisfname = flist{fidx};
  thisval = xmlstruct.(thisfname);

  % Only process child nodes, not text or attributes.
  if isstruct(thisval)

    % This is an array of child nodes.
    for cidx = 1:length(thisval)
      thischild = thisval(cidx);

      tagmatch = true;
      if ~isempty(tagswanted)
        % Allow case-insensitive matching.
        tagmatch = any(strcmpi( thisfname, tagswanted ));
      end

      attribmatch = nlUtil_testXMLStructAttributes(thisval, attribswanted);

      if tagmatch && attribmatch
        matchcount = matchcount + 1;
        matches{matchcount} = thisval;
      else
        nonmatchcount = nonmatchcount + 1;
        nonmatches{nonmatchcount} = thisval;
      end
    end

  end
end


% Done.
end

%
% This is the end of the file.
