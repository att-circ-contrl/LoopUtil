function newmeta =nlOpenE_parseProcessorXMLv5_TNECrossingDetector( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta =nlOpenE_parseProcessorXMLv5_TNECrossingDetector( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% a TNE Lab Crossing Detector plugin instance, and adds type-specific
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


% Get the configuration and copy relevant fields.

config = nlUtil_findXMLStructNodesTopLevel( xmleditor, { 'values' }, {} );
config = config{1};

newmeta.inputchan = config.('inputChanIdAttribute');
newmeta.wantrising = logical( config.('bRisingAttribute') );
newmeta.wantfalling = logical( config.('bFallingAttribute') );

newmeta.outputTTLchan = config.('outputChanIdAttribute');


% Note - Threshold types are declared via enum in CrossingDetector.h.
% The starting value is the compiler's default (usually 0).

newmeta.threshtype = 'unknown';
modevalue = config.('thresholdTypeAttribute');

if 0 == modevalue
  newmeta.threshtype = 'constant';
elseif 1 == modevalue
  newmeta.threshtype = 'random';
elseif 2 == modevalue
  newmeta.threshtype = 'channel';
elseif 3 == modevalue
  newmeta.threshtype = 'adaptive';
elseif 4 == modevalue
  newmeta.threshtype = 'averagemult';
else
  disp(sprintf( ['###  [nlOpenE_parseProcessorXMLv5_TNECrossingDetector]  ' ...
    'Unknown thresholding mode "%d".' ], modevalue ));
end


% Constant and averagemult.
newmeta.threshold = config.('thresholdAttribute');

% Averagemult.
newmeta.averageseconds = config.('averageDecaySecondsAttribute');

% Uninform random sampling.
randmin = config.('minThreshAttribute');
randmax = config.('maxThreshAttribute');
newmeta.randomrange = [ randmin randmax ];

% External threshold.
newmeta.extthreshchan = config.('thresholdChanIdAttribute');

% Adaptive thresholding.

newmeta.adaptinputname = char( config.('indicatorChanNameAttribute') );
newmeta.adapttarget = config.('indicatorTargetAttribute');

newmeta.adaptinputrange = [];
wantclamp = logical( config.('useIndicatorRangeAttribute') );

if wantclamp
  clampmin = config.('indicatorRangeMinAttribute');
  clampmax = config.('indicatorRangeMaxAttribute');
  newmeta.adaptinputrange = [ clampmin clampmax ];
end

newmeta.adaptoutputrange = [];
wantclamp = logical( config.('useAdaptThreshRangeAttribute') );

if wantclamp
  clampmin = config.('adaptThreshRangeMinAttribute');
  clampmax = config.('adaptThreshRangeMaxAttribute');
  newmeta.adaptoutputrange = [ clampmin clampmax ];
end

newmeta.adaptlearnratestart = config.('learningRateAttribute');
newmeta.adaptlearnratemin = config.('minLearningRateAttribute');
newmeta.adaptlearnratedecay = config.('decayRateAttribute');


% Don't bother extracting pulse duration, jump limiting, etc.


% Build human-readable descriptions.

thismsg = ...
  sprintf( '.. Node %d is a TNE Lab crossing detector.', newmeta.procnode );

newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];

[ thissummary thisdetailed ] = ...
  nlOpenE_getCrossingDetectThresholdDesc_v5( newmeta );

newmeta.descsummary = [ newmeta.descsummary thissummary ];
newmeta.descdetailed = [ newmeta.descdetailed thisdetailed ];


% Done.
end


%
% This is the end of the file.
