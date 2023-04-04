function newmeta = nlOpenE_parseProcessorXMLv5_ACCConditionalTrig( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta = nlOpenE_parseProcessorXMLv5_ACCConditionalTrig( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% an ACC Lab Conditional Trigger plugin instance, and adds type-specific
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


% The trigger behavior config is stored at the top level.
% Labels are stored in the editor.


% Get the top-level config and figure out how many inputs and outputs
% there are. This is hard-coded into the plugin, but do it anyways.

outconfiglist = ...
  nlUtil_findXMLStructNodesTopLevel( xmlproc, { 'TTLOutput' }, {} );

outcount = length(outconfiglist);
inconfiglist = ...
  nlUtil_findXMLStructNodesTopLevel( outconfiglist{1}, { 'TTLInput' }, {} );
incount = length(inconfiglist);

newmeta.outcount = outcount;
newmeta.incount = incount;


% Traverse the top-level config and record trigger behavior.
% This also initializes the structure storing all of the configuration info.

% Walk through the outputs.

newmeta.outconditions = cell(1,outcount);

for outloopidx = 1:length(outconfiglist)
  thisoutconfig = outconfiglist{outloopidx};

  thisoutnum = thisoutconfig.('OutIndexAttribute');
  thisoutenabled = logical(thisoutconfig.('IsEnabledAttribute'));
  thisoutanyall = 'any';
  if logical(thisoutconfig.('NeedAllInputsAttribute'))
    thisoutanyall = 'all';
  end

  thisoutmeta = struct( 'enabled', thisoutenabled, 'anyall', thisoutanyall );
  thisoutmeta = helper_addLogicConfig(thisoutmeta, thisoutconfig);

  % Walk through the inputs for this output.

  thisoutmeta.inconditions = cell(1,incount);
  inconfiglist = ...
    nlUtil_findXMLStructNodesTopLevel( thisoutconfig, { 'TTLInput' }, {} );

  for inloopidx = 1:length(inconfiglist)
    thisinconfig = inconfiglist{inloopidx};

    thisinnum = thisinconfig.('InIndexAttribute');
    thisinenabled = logical(thisinconfig.('IsEnabledAttribute'));
    thisinttlbank = thisinconfig.('TTLChanAttribute');
    thisinttlbit = thisinconfig.('TTLBitAttribute');

    % Negative values are used as "not initialized" placeholders.
    % Valid values are 0-based.
    if thisinttlbank < 0
      thisinttlbank = NaN;
    end
    if thisinttlbit < 0
      thisinttlbit = NaN;
    end

    thisinmeta = struct( 'enabled', thisinenabled, ...
      'digbankidx', thisinttlbank, 'digbit', thisinttlbit );

    thisinmeta = helper_addLogicConfig(thisinmeta, thisinconfig);

    % Convert to 1-based for storage.
    thisoutmeta.inconditions{thisinnum + 1} = thisinmeta;
  end

  % Convert to 1-based for storage.
  newmeta.outconditions{thisoutnum + 1} = thisoutmeta;
end


% Traverse the editor config, storing labels.

outlabellist = ...
  nlUtil_findXMLStructNodesTopLevel( xmleditor, { 'OutputLabel' }, {} );

for outloopidx = 1:length(outlabellist)
  thisoutlabeltag = outlabellist{outloopidx};

  thisoutnum = thisoutlabeltag.('OutIndexAttribute');
  % Convert from string to character vector.
  thisoutname = char(thisoutlabeltag.('LabelAttribute'));

  % Convert to 1-based for storage.
  newmeta.outconditions{thisoutnum + 1}.name = thisoutname;

  % Walk through the inputs for this output.

  inlabellist = ...
    nlUtil_findXMLStructNodesTopLevel( thisoutlabeltag, { 'InputLabel' }, {} );

  for inloopidx = 1:length(inlabellist)
    thisinlabeltag = inlabellist{inloopidx};

    thisinnum = thisinlabeltag.('InIndexAttribute');
    % Convert from string to character vector.
    thisinname = char(thisinlabeltag.('LabelAttribute'));

    % Convert to 1-based for storage.
    newmeta.outconditions{thisoutnum + 1}.inconditions{thisinnum + 1}.name = ...
      thisinname;
  end
end


% Traverse the metadata structure, building summary and detailed descriptions.

thismsg = sprintf( '.. Node %d is an ACC Lab conditional trigger plugin.', ...
  newmeta.procnode );

descsummary = [ newmeta.descsummary { thismsg } ];
descdetailed = [ newmeta.descdetailed { thismsg } ];

for outloopidx = 1:length(newmeta.outconditions)
  thisoutmeta = newmeta.outconditions{outloopidx};

  thisoutname = thisoutmeta.name;
  thisoutenabled = thisoutmeta.enabled;
  thisoutanyall = thisoutmeta.anyall;

  [ thisoutlogicmain thisoutlogicaux ] = ...
    helper_summarizeLogic(thisoutmeta);

  % NOTE - We started some sessions with outputs disabled that we enabled
  % while running. So report disabled ones in the summary too.
  % Only outputs can be toggled at run-time; inputs are fixed.

  enlabel = ' (off)';
  if thisoutenabled
    enlabel = '';
  end

  thismsg = [ 'Out' num2str(outloopidx-1) enlabel ': "' thisoutname ...
    '": ' thisoutlogicmain ];
  descsummary = [ descsummary { thismsg } ];
  descdetailed = [ descdetailed { thismsg } { thisoutlogicaux } ];

  thismsg = 'Any of:';
  if strcmp('all', thisoutanyall)
    thismsg = 'All of:';
  end
  descsummary = [ descsummary { thismsg } ];
  descdetailed = [ descdetailed { thismsg } ];

  for inloopidx = 1:length(thisoutmeta.inconditions)
    thisinmeta = thisoutmeta.inconditions{inloopidx};

    thisinname = thisinmeta.name;
    thisinenabled = thisinmeta.enabled;
    thisinbank = thisinmeta.digbankidx;
    thisinbit = thisinmeta.digbit;

    [ thisinlogicmain thisinlogicaux ] = ...
      helper_summarizeLogic(thisinmeta);

    thismsg = [ '   In' num2str(inloopidx-1) ' (TTL ' ];
    if isnan(thisinbank) || isnan(thisinbit)
      thismsg = [ thismsg '---' ];
    else
      thismsg = [ thismsg num2str(thisinbank) ':' num2str(thisinbit) ];
    end
    thismsg = [ thismsg '): "' thisinname '": ' thisinlogicmain ];

    % Suppress disabled inputs, but show even if the output is disabled.
    if thisinenabled
      descsummary = [ descsummary { thismsg } ];
    end
    descdetailed = [ descdetailed { thismsg } { [ '   ' thisinlogicaux ] } ];
    if ~thisinenabled
      descdetailed = [ descdetailed { '   (Disabled)' } ];
    end
  end
end

newmeta.descsummary = descsummary;
newmeta.descdetailed = descdetailed;


% Done.
end


%
% Helper Functions


% This adds logic metadata fields to the specifed metadata structure.

function newmeta = helper_addLogicConfig( oldmeta, thisconfig )

  newmeta = oldmeta;

  thislogic = ...
    nlUtil_findXMLStructNodesTopLevel( thisconfig, { 'LogicConfig' }, {} );
  thislogic = thislogic{1};

  newmeta.delayminsamps = thislogic.('DelayMinAttribute');
  newmeta.delaymaxsamps = thislogic.('DelayMaxAttribute');
  newmeta.sustainsamps = thislogic.('SustainTimeAttribute');
  newmeta.deadsamps = thislogic.('DeadTimeAttribute');
  newmeta.deglitchsamps = thislogic.('DeglitchTimeAttribute');
  newmeta.activehigh = logical( thislogic.('ActiveHighAttribute') );

  % Attributes are defined in TTLToolsCondition.h in PluginLibTTLTools.

  thistype = 'error';
  thistypeidx = thislogic.('FeatureAttribute');

  if 0 == thistypeidx
    thistype = 'high';
  elseif 1 == thistypeidx
    thistype = 'low';
  elseif 2 == thistypeidx
    thistype = 'rising';
  elseif 3 == thistypeidx
    thistype = 'falling';
  end

  newmeta.trigtype = thistype;
end


% This generates one-line (character vector) summaries of primary and
% auxiliary logic metadata.

function [ descmain descaux ] = helper_summarizeLogic( logicmeta )

  % Build the primary desc using the most salient information.

  descmain = [ 'Trig on ' logicmeta.trigtype ', asserted ' ];
  if logicmeta.activehigh
    descmain = [ descmain 'high for ' ];
  else
    descmain = [ descmain 'low for ' ];
  end
  descmain = [ descmain sprintf('%d samps.', logicmeta.sustainsamps) ];


  % Put the rest in the auxiliary desc.

  descaux = sprintf( ...
    'Delayed %d .. %d samps, stable for %d, %d since last.', ...
    logicmeta.delayminsamps, logicmeta.delaymaxsamps, ...
    logicmeta.deglitchsamps, logicmeta.deadsamps );

end


%
% This is the end of the file.
