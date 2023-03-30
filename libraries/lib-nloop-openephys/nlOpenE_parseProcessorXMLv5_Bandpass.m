function newmeta = nlOpenE_parseProcessorXMLv5_Bandpass( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta = nlOpenE_parseProcessorXMLv5_Bandpass( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% a bandpass filter node, and adds type-specific metadata to the supplied
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


% FIXME - This is stored in two places: once in the editor, and then
% again on a per-channel basis with a "should filter" flag set to 0.
% I'm _hoping_ that's a hold-over from an old version of the plugin that
% did per-channel filtering with customizable bands.


% FIXME - Just ignore the per-channel settings.

filtconfig = nlUtil_findXMLStructNodesTopLevel( xmleditor, { 'values' }, {} );
filtconfig = filtconfig{1};

thishigh = filtconfig.('HighCutAttribute');
thislow = filtconfig.('LowCutAttribute');

newmeta.band = [ thislow thishigh ];

thismsg = sprintf( '.. Node %d is a band-pass filter (%.1f-%.1f Hz).', ...
  newmeta.procnode, thislow, thishigh );
newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];


% Done.
end


%
% This is the end of the file.
