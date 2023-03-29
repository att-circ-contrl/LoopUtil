function newmeta = nlOpenE_parseProcessorXMLv5_IntanRec( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta = nlOpenE_parseProcessorXMLv5_IntanRec( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% an Intan recording controller node, and adds type-specific metadata to
% the supplied metadata structure.
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


% Get salient information from the editor.

newmeta.samprate = nlOpenE_getIntanRecorderSamprateFromIndex( ...
  xmleditor.('SampleRateAttribute') );
newmeta.bandpass = ...
  [ xmleditor.('LowCutAttribute'), xmleditor.('HighCutAttribute') ];


% Get the channel names and numbers.

newmeta.chanlabels = {};

chaninfo = ...
  nlUtil_findXMLStructNodesTopLevel( xmlproc, { 'channel_info' }, {} );

if isempty(chaninfo)
  % Problem.
  disp([ '###  [nlOpenE_parseIntanRecorderXML_v5]  ' ...
    'Can''t find CHANNEL_INFO tag.' ]);
else
  chaninfo = chaninfo{1};
  chanlist = nlUtil_findXMLStructNodesTopLevel( chaninfo, { 'channel' }, {} );

  chanlabels = {};
  channumbers = [];

  for cidx = 1:length(chanlist)
    chantag = chanlist{cidx};
    chanlabels{cidx} = char( chantag.('nameAttribute') );
    channumbers(cidx) = chantag.('numberAttribute');
  end

  % Make sure these are sorted (they should already be).
  [ channumbers, sortidx ] = sort(channumbers);
  chanlabels = chanlabels(sortidx);

  % "number" ranges from 0..N-1, so don't save it.
  newmeta.chanlabels = chanlabels;
end


% Build human-deadable descriptions.

thismsg = sprintf( [ '.. Node %d is an Intan recording controller' ...
  ' (%.1f-%d Hz, %.1f ksps, %d ch).' ], newmeta.procnode, ...
  min(newmeta.bandpass), round(max(newmeta.bandpass)), ...
  newmeta.samprate / 1000, length(newmeta.chanlabels) );

newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];

% FIXME - Not adding anything more to the detailed description for now.
% Channel list could go here, but is very spammy.


% Done.
end


%
% This is the end of the file.
