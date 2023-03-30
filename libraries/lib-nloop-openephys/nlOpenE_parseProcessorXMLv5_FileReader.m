function newmeta = nlOpenE_parseProcessorXMLv5_FileReader( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta = nlOpenE_parseProcessorXMLv5_FileReader( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% a file reader node, and adds type-specific metadata to the supplied
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


% Add new metadata.
% There isn't actually a whole lot of information available.

thistag = nlUtil_findXMLStructNodesTopLevel( xmleditor, { 'filename' }, {} );
thistag = thistag{1};

newmeta.filename = char( thistag.('pathAttribute') );

thistag = ...
  nlUtil_findXMLStructNodesTopLevel( xmleditor, { 'time_limits' }, {} );
thistag = thistag{1};

newmeta.sampstart = thistag.('start_timeAttribute');
newmeta.sampstop = thistag.('stop_timeAttribute');


% Get the channel count from the selection vector.
% FIXME - Blithely assume that all _declared_ channels are valid!
% Not sure what happens if "param" is set to 0 for any of them for a reader.
newmeta.chancount = length(newmeta.channelselect);


% We don't have the sampling rate or any other such information. As near as
% I can tell, we're supposed to read the indicated file to get all of that.


% Build a human-readable description.

thismsg = sprintf( '.. Node %d is a file reader (%d chans, %d samples).', ...
  newmeta.procnode, newmeta.chancount, ...
  (1 + newmeta.sampstop - newmeta.sampstart) );
newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];

thismsg = [ '   Reading from: "' newmeta.filename '"' ];
newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];


% Done.
end


%
% This is the end of the file.
