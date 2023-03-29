function newmeta = nlOpenE_parseProcessorXMLv5_ChannelMap( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta = nlOpenE_parseProcessorXMLv5_ChannelMap( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% a channel mapping node, and adds type-specific metadata to the supplied
% metadata structure.
%
% "oldmeta" is the metadata structure built by the "entry point" function.
%   It contains the "common" metadata described in PROCMETA_OPENEPHYSv5.txt.
% "xmlproc" is a structure containing the XML parse tree (per readstruct())
%   of the "processor" tag being interpreted.
% "xmleditor" is a structure containing the XML parse tree of the "editor"
%   tag within the "processor" tag, or struct([]) if none was found.
%
% "newmeta" is a copy of "oldmeta" augmented with plugin-specific metadata.


% NOTE - Assume that everything we need is here (no bulletproofing).


% Copy the existing metadata.
newmeta = oldmeta;


% Wrap the old channel map parsing function.
% This searches for the editor, so pass it the processor node's tree, not
% the editor's tree.

maplist = nlOpenE_parseChannelMapXML_v5( xmlproc );

% We should get exactly one result from this.
if isempty(maplist)
  % Problem.
  disp([ '###  [nlOpenE_parseProcessorXMLv5_ChannelMap]  ' ...
    'No channel map found.' ]);
else
  newmeta.chanmap = maplist(1);

  thismsg = sprintf( '.. Node %d is a channel map (%d channels).', ...
    newmeta.procnode, length(newmeta.chanmap.oldchan) );

  newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
  newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];

  % FIXME - Not adding anything more to the detailed description for now.
  % Channel mapping could go here, but is very spammy.
end


% Done.
end


%
% This is the end of the file.
