function recmeta = nlOpenE_parseIntanRecorderXML_v5( xmlstruct )

% function recmeta = nlOpenE_parseIntanRecorderXML_v5( xmlstruct )
%
% This parses an Open Ephys v0.5 XML configuration tree for an Intan
% recording controller processor node.
%
% "xmlstruct" is a structure containing an XML parse tree (per readstruct()).
%   This should be the parse tree for the "processor" node for an Intan
%   recording controller.
%
% "recmeta" is a structure containing metadata for the recording controller,
%   or struct([]) if this isn't a recording controller config node.
%
% Recording controller metadata structure fields include the following:
% FIXME - NYI.


% Get metadata common to all nodes.
[ recmeta thiseditor ] = nlOpenE_parseProcessorNodeXML_v5( xmlstruct );

% Get Intan-specific metadata.
if ~isempty(recmeta)
  if ~strcmp(recmeta.procname, 'Intan Rec. Controller')
    disp([ '###  [nlOpenE_parseIntanRecorderXML_v5]  Passed something' ...
      ' that wasn''t an Intan recording controller processor node.' ]);

    % Empty structure array, to indicate an error.
    recmeta = struct([]);
  else

    % Assume that everything we need is here.

    % Get salient information from the editor.
    recmeta.samprate = nlOpenE_getIntanRecorderSamprateFromIndex( ...
      thiseditor.('SampleRateAttribute') );
    recmeta.bandpass = ...
      [ thiseditor.('LowCutAttribute'), thiseditor.('HighCutAttribute') ];

    % Get the channel names and numbers.

    chaninfo = ...
      nlUtil_findXMLStructNodesTopLevel( xmlstruct, { 'channel_info' }, {} );

    if isempty(chaninfo)
      % Problem.
      disp([ '###  [nlOpenE_parseIntanRecorderXML_v5]  ' ...
        'Can''t find CHANNEL_INFO tag.' ]);

      % Empty structure array, to indicate an error.
      recmeta = struct([]);
    else
      chaninfo = chaninfo{1};
      chanlist = nlUtil_findXMLStructNodesTopLevel( ...
        chaninfo, { 'channel' }, {} );

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
      recmeta.chanlabels = chanlabels;
    end

  end
end


% Done.
end


%
% This is the end of the file.
