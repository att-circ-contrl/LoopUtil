function newmeta = nlOpenE_parseProcessorXMLv5_FileRecord( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta = nlOpenE_parseProcessorXMLv5_FileRecord( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% a file-writing node ("Record Node"), and adds type-specific metadata to
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


% Parse record node metadata.

% FIXME - I _think_ saving config works as follows:
%
% The "channelselect" vector indicates how many of the external inputs
% are accepted by the plugin.
% The "recordstate" vector indicates how many of the accepted inputs are
% written out.


% There should be exactly one of these.

recsettings = ...
  nlUtil_findXMLStructNodesTopLevel( xmleditor, { 'settings' }, {} );

newmeta.writefolder = '';
newmeta.wantevents = false;
newmeta.wantspikes = false;

if isempty(recsettings)
  disp([ '###  [nlOpenE_parseProcessorXMLv5_FileRecord]  ' ...
    'Can''t find settings.' ]);
else
  recsettings = recsettings{1};
  newmeta.writefolder = char( recsettings.('pathAttribute') );
  newmeta.wantevents = logical( recsettings.('recordEventsAttribute') );
  newmeta.wantspikes = logical( recsettings.('recordSpikesAttribute') );
end

% NOTE - There's one "recordstate" per _subprocessor_. We can have
% multiple subprocessors (the TNE Lab Phase Calculator adds channels that
% show up as a second one, in magnitude plus phase mode).

recoutput = ...
  nlUtil_findXMLStructNodesRecursing( xmleditor, { 'recordstate' }, {} );

savedchans = logical([]);
sidx = 0;

if isempty(recoutput)
  disp([ '###  [nlOpenE_parseProcessorXMLv5_FileRecord]  ' ...
    'Can''t find "recordstate".' ]);
else
  for pidx = 1:length(recoutput)
    thisrecoutput = recoutput{pidx};

    % Search by iteration, since these are contiguous values starting at 0.
    cidx = 0;
    wasfound = true;
    while wasfound
      thislabel = sprintf('CH%dAttribute', cidx);
      wasfound = isfield(thisrecoutput, thislabel);
      if wasfound
        sidx = sidx + 1;
        cidx = cidx + 1;
        savedchans(sidx) = logical(thisrecoutput.(thislabel));
      end
    end
  end
end

newmeta.savedchans = savedchans;


% Build human-readable descriptions.

thismsg = ...
  sprintf( '.. Node %d is a Record (file write) node (%d of %d ch', ...
  newmeta.procnode, sum(newmeta.savedchans), length(newmeta.savedchans) );
if newmeta.wantevents
  thismsg = [ thismsg ', events' ];
end
if newmeta.wantspikes
  thismsg = [ thismsg ', spikes' ];
end
thismsg = [ thismsg ').' ];

newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];

thismsg = [ '   Folder: "', newmeta.writefolder, '"' ];
newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];


% FIXME - Not adding anything more to the detailed description for now.
% Channel list might go here but is very spammy.


% Done.
end


%
% This is the end of the file.
