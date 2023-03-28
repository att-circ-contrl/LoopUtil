function samprate = nlOpenE_getIntanRecorderSamprateFromIndex( rateidx )

% function samprate = nlOpenE_getIntanRecorderSamprateFromIndex( rateidx )
%
% This translates the Open Ephys configuration selection value for sampling
% rate into an actual sampling rate.
%
% This is defined by the order in which they're added in the
% SampleRateInterface object's combobox in RHD2000Editor.cpp.
%
% "rateidx" is the sampling rate index (should be 1..17).
%
% "samprate" is the sampling rate in Hz.


samprate = NaN;


ratelut = [ 1000, 1250, 1500, 2000, 2500, ...
  3000, 3333, 4000, 5000, 6250, ...
  8000, 10000, 12500, 15000, 20000, ...
  25000, 30000 ];


rateidx = round(rateidx);

if (rateidx >= 1) && (rateidx <= 17)
  samprate = ratelut(rateidx);
end


% Done.
end


%
% This is the end of the file.
