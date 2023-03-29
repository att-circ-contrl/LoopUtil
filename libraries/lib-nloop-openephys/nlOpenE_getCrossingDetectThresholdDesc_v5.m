function [ descsummary descdetailed ] = ...
  nlOpenE_getCrossingDetectThresholdDesc_v5( procmeta )

% function [ descsummary descdetailed ] = ...
%   nlOpenE_getCrossingDetectThresholdDesc_v5( procmeta )
%
% This generates a human-readable description of the threshold configuration
% for a TNE Lab crossing detector plugin.
%
% "procmeta" is the processor node metadata, per PROCMETA_OPENEPHYSv5.txt.
%
% "descsummary" is a cell array containing character vectors that are
%   individual lines of a human-readable summary of the configuration.
% "descdetailed" is a cell array containing character vectors that are
%   individual lines of a human-readable detailed description of the
%   configuration.


descsummary = {};
descdetailed = {};


prefix = '   ';


if ~strcmp( procmeta.procname, 'Crossing Detector' )
  disp([ '###  [nlOpenE_getCrossingDetectThresholdDesc_v5]  ' ...
    'This doesn''t look like a crossing detector metadata structure.' ]);
else

  % FIXME - Assume that we have everything we need (no bulletproofing).


  threshtype = procmeta.threshtype;


  thismsg = sprintf( [ prefix 'Using %s thresholding on ch %d' ], ...
    threshtype, procmeta.inputchan );

  if procmeta.wantrising && procmeta.wantfalling
    thismsg = [ thismsg ' (rise/fall)' ];
  elseif procmeta.wantrising
    thismsg = [ thismsg ' (rising)' ];
  elseif procmeta.wantfalling
    thismsg = [ thismsg ' (falling)' ];
  else
    thismsg = [ thismsg ' (none)' ];
  end

  thismsg = [ thismsg sprintf( ', output to TTL line %d.', ...
    procmeta.outputTTLchan ) ];

  descsummary = [ descsummary { thismsg } ];
  descdetailed = [ descdetailed { thismsg } ];


  thismsg = '';

  if strcmp(threshtype, 'constant')
    % FIXME - Picking a magic value for precision.
    thismsg = sprintf( [ prefix 'Constant threshold value is %.4f.' ], ...
      procmeta.threshold );
  elseif strcmp(threshtype, 'random')
    % FIXME - Blithely assuming that this is phase in degrees.
    thismsg = sprintf( [ prefix 'Random threshold is between %d and %d.' ], ...
      round(min(procmeta.randomrange)), round(max(procmeta.randomrange)) );
  elseif strcmp(threshtype, 'channel')
    thismsg = sprintf( [ prefix 'External threshold is on ch %d.' ], ...
      procmeta.extthreshchan );
  elseif strcmp(threshtype, 'adaptive')
    % FIXME - Indicator channel is stored by name, not by number.
    % FIXME - Blithely assuming that the target is a phase in degrees.
    thismsg = sprintf( [ prefix 'Adapting to get %d on chan "%s".' ], ...
       round(procmeta.adapttarget), procmeta.adaptinputname );
  elseif strcmp(threshtype, 'averagemult')
    thismsg = ...
      sprintf( [ prefix 'Threshold is %.1f times the RMS average.' ], ...
      procmeta.threshold );
  end

  descsummary = [ descsummary { thismsg } ];
  descdetailed = [ descdetailed { thismsg } ];

  % Give detailed tuning parameters for adaptive thresholding.

  if strcmp(threshtype, 'adaptive')
    % FIXME - Blithely assume ranges are phase in degrees.
    thismsg = sprintf( ...
      [ prefix 'Input clamped to %d .. %d, theshold to %d .. %d.' ], ...
      round(min(procmeta.adaptinputrange)), ...
      round(max(procmeta.adaptinputrange)), ...
      round(min(procmeta.adaptoutputrange)), ...
      round(max(procmeta.adaptoutputrange)) );
    descdetailed = [ descdetailed { thismsg } ];

    thismsg = sprintf( [ prefix ...
      'Learn rate starts at %.6f, decays to %.6f with rate %.6f.' ], ...
      procmeta.adaptlearnratestart, procmeta.adaptlearnratemin, ...
      procmeta.adaptlearnratedecay );
    descdetailed = [ descdetailed { thismsg } ];
  end

end


% Done.
end


%
% This is the end of the file.
