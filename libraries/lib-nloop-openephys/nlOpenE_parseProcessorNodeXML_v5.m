function procmeta = nlOpenE_parseProcessorNodeXML_v5( xmlstruct )

% function procmeta = nlOpenE_parseProcessorNodeXML_v5( xmlstruct )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag and
% extracts configuration metadata from it.
%
% This is an "entry point" function; it extracts information common to all
% nodes and then calls helper functions to extract additional information
% specific to individual plugins and node types.
%
% "xmlstruct" is a structure containing an XML parse tree (per readstruct()).
%   This should be the parse tree for a "processor" node from an Open Ephys
%   v0.5 configuration file.
%
% "procmeta" is a structure containing node metadata, or struct([]) if an
%   error occurred. Node metadata is described in PROCMETA_OPENEPHYSv5.txt.


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


  % We usually, but don't always, have a list of <EVENTCHANNEL> tags.
  % These have "name="N" number="N"" from 0..N-1, so just count how many
  % there are and don't bother parsing them.
  % These are the TTL _banks_, not the individual TTL _channels_.

  evbanklist = ...
    nlUtil_findXMLStructNodesTopLevel( xmlstruct, { 'eventchannel' }, {} );

  procmeta.eventbanks = length(evbanklist);


  % Get the editor tag's parse tree.
  % This usually, but doesn't always, exist.
  thiseditor = ...
    nlUtil_findXMLStructNodesTopLevel( xmlstruct, { 'editor' }, {} );
  if ~isempty(thiseditor)
    proceditor = thiseditor{1};
  end


  % Store empty description fields.
  procmeta.descsummary = {};
  procmeta.descdetailed = {};


  % If this is a type of processor that we recognize, call a helper function.

  if strcmp(procmeta.procname, 'Intan Rec. Controller')
    procmeta = nlOpenE_parseProcessorXMLv5_IntanRec( ...
      procmeta, xmlstruct, proceditor );
  elseif strcmp(procmeta.procname, 'Channel Map')
    procmeta = nlOpenE_parseProcessorXMLv5_ChannelMap( ...
      procmeta, xmlstruct, proceditor );
  elseif strcmp(procmeta.procname, 'Record Node')
    procmeta = nlOpenE_parseProcessorXMLv5_FileRecord( ...
      procmeta, xmlstruct, proceditor );
  elseif strcmp(procmeta.procname, 'File Reader')
    procmeta = nlOpenE_parseProcessorXMLv5_FileReader( ...
      procmeta, xmlstruct, proceditor );
  elseif strcmp(procmeta.procname, 'Arduino Output')
    procmeta = nlOpenE_parseProcessorXMLv5_ArduinoOut( ...
      procmeta, xmlstruct, proceditor );
  elseif strcmp(procmeta.procname, 'Bandpass Filter')
    procmeta = nlOpenE_parseProcessorXMLv5_Bandpass( ...
      procmeta, xmlstruct, proceditor );
  % NOTE - Not getting config for splitter or lfp viewer.

  elseif strcmp(procmeta.procname, 'Phase Calculator')
    % TNE Lab phase calculator.
    procmeta = nlOpenE_parseProcessorXMLv5_TNEPhaseCalculator( ...
      procmeta, xmlstruct, proceditor );
  elseif strcmp(procmeta.procname, 'Crossing Detector')
    % TNE Lab crossing detector.
    procmeta = nlOpenE_parseProcessorXMLv5_TNECrossingDetector( ...
      procmeta, xmlstruct, proceditor );

  elseif strcmp(procmeta.procname, 'TTL Cond Trigger')
    % ACC Lab conditional trigger.
    procmeta = nlOpenE_parseProcessorXMLv5_ACCConditionalTrig( ...
      procmeta, xmlstruct, proceditor );
  end
  % NOTE - Not getting config for ACC Lab TTL front panel or toggle panel.

end


% Done.
end


%
% This is the end of the file.
