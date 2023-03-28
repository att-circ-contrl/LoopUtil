function [ procmeta proceditor ] = ...
  nlOpenE_parseProcessorNodeXML_v5( xmlstruct )

% function [ procmeta proceditor ] = ...
%   nlOpenE_parseProcessorNodeXML_v5( xmlstruct )
%
% This parses an Open Ephys v0.5 XML processor node, extracting information
% common to all nodes (or almost all; splitters are special).
%
% "xmlstruct" is a structure containing an XML parse tree (per readstruct()).
%   This should be the parse tree for a "processor" node from an Open Ephys
%   v0.5 configuration file.
%
% "procmeta" is a structure containing node metadata, or struct([]) if an
%   error occurred.
% "proceditor" is a structure containing the node's EDITOR tag, or struct([])
%   if no editor is present (as with splitter nodes).
%
% Metadata fields include the following:
%   "procname" is the "pluginName" attribute (a character vector).
%   "proclib" is the "libraryName" attribute (a character vector).
%   "procnode" is the "NodeId" attribute (a number).
%   "channelselect" is a logical vector containing the channel selection
%     state "param" values of all "channel" tags in the processor node.
%     Note that "number" starts counting at 0, so index is "number" + 1.
%     This may be an empty vector for special nodes like splitters.


procmeta = struct([]);
proceditor = struct([]);


% These fields should always exist, even for splitters and such.
% "libraryName" may contain an empty character vector; that's okay.

if isfield(xmlstruct, 'pluginNameAttribute') ...
  && isfield(xmlstruct, 'libraryNameAttribute') ...
  && isfield(xmlstruct, 'NodeIdAttribute')

  procmeta = struct();
  procmeta.procname = char( xmlstruct.('pluginNameAttribute') );
  procmeta.proclib = char( xmlstruct.('libraryNameAttribute') );
  procmeta.procnode = xmlstruct.('NodeIdAttribute');

  % We usually, but don't always, have a list of <CHANNEL> tags.

  chanlist = ...
    nlUtil_findXMLStructNodesTopLevel( xmlstruct, { 'channel' }, {} );

  channelselect = logical([]);
  if ~isempty(chanlist)
    selectflags = [];
    selectnumbers = [];

    for cidx = 1:length(chanlist)
      chantag = chanlist{cidx};

      % Each of these has exactly one "SELECTIONSTATE" child tag.
      statetag = nlUtil_findXMLStructNodesTopLevel( ...
        chanlist{cidx}, { 'selectionstate' }, {} );
      statetag = statetag{1};

      selectflags(cidx) = statetag.('paramAttribute');
      selectnumbers(cidx) = chantag.('numberAttribute');
    end

    % Make sure these are sorted (they should already be).
    [ selectnumbers, sortidx ] = sort(selectnumbers);
    selectflags = selectflags(sortidx);

    % FIXME - Blithely assume that the channel tag numbers were 0..N-1.
    channelselect = logical(selectflags);
  end

  procmeta.channelselect = channelselect;


  % This usually, but doesn't always, exist.
  thiseditor = ...
    nlUtil_findXMLStructNodesTopLevel( xmlstruct, { 'editor' }, {} );
  if ~isempty(thiseditor)
    proceditor = thiseditor{1};
  end

end


% Done.
end


%
% This is the end of the file.
