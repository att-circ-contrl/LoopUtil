function newmeta = nlOpenE_parseProcessorXMLv5_TNEPhaseCalculator( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta = nlOpenE_parseProcessorXMLv5_TNEPhaseCalculator( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% a TNE Lab Phase Calculator plugin instance, and adds type-specific
% metadata to the supplied metadata structure.
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


% Get the processing config and copy relevant fields.

procconfig = nlUtil_findXMLStructNodesTopLevel( xmleditor, { 'values' }, {} );
procconfig = procconfig{1};

newmeta.bandcorners = ...
  [ procconfig.('lowCutAttribute'), procconfig.('highCutAttribute') ];
newmeta.bandedges = ...
  [ procconfig.('rangeMinAttribute'), procconfig.('rangeMaxAttribute') ];

newmeta.predictorder = procconfig.('arOrderAttribute');
newmeta.predictupdatems = procconfig.('calcIntervalAttribute');

% NOTE - Output mode values are declared via enum in PhaseCalculator.h.

newmeta.outputmode = 'unknown';
modevalue = procconfig.('outputModeAttribute');

if 1 == modevalue
  newmeta.outputmode = 'phase';
elseif 2 == modevalue
  newmeta.outputmode = 'magnitude';
elseif 3 == modevalue
  newmeta.outputmode = 'both';
elseif 4 == modevalue
  % This is in the enum, but I'm not sure if it's still used.
  newmeta.outputmode = 'imaginary';
else
  disp(sprintf( ['###  [nlOpenE_parseProcessorXMLv5_TNEPhaseCalculator]  ' ...
    'Unknown output mode "%d".' ], modevalue ));
end


% FIXME - Ignoring the phase error visualizer.


% Build human-readable descriptions.

thismsg = sprintf( [ '.. Node %d is a TNE Lab phase calculator' ...
  '  (%.1f-%.1f Hz, %s).' ], newmeta.procnode, min(newmeta.bandcorners), ...
  max(newmeta.bandcorners), newmeta.outputmode );

newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];

thismsg = ...
  sprintf( '   Band edges %.1f-%.1f Hz, AR order %d updating every %d ms.', ...
    min(newmeta.bandedges), max(newmeta.bandedges), ...
    newmeta.predictorder, newmeta.predictupdatems );

newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];


% Done.
end


%
% This is the end of the file.
