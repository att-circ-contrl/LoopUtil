function header = nlFT_readTableHeader(fname)

% function header = nlFT_readTableHeader(fname)
%
% This constructs a Field Trip header based on information previously
% supplied to nlFT_initReadTable(). The idea is to be able to give Field
% Trip a way to read non-uniformly-sampled tabular data as waveform data.
%
% This is intended to be called by ft_read_header() via the "headerformat"
% argument.
%
% "fname" is the filename passed to ft_read_header(). This is ignored.


% Import global variables.

global nlFT_readTable_datatable;
global nlFT_readTable_chancolumns;
global nlFT_readTable_timecolumn;
global nlFT_readTable_timefirst;
global nlFT_readTable_timelast;
global nlFT_readTable_samplespertimeunit;
global nlFT_readTable_samprate;

% If anything hasn't been initialized, it has a value of "[]".
% We can test for that with "isempty", just as with the empty table case.


% Initialize to an error value.
header = struct([]);


% Proceed if we've configured a table.
if ~isempty(nlFT_readTable_datatable)

  % Get metadata.
  sampcount = nlFT_readTable_timelast - nlFT_readTable_timefirst;
  sampcount = 1 + (sampcount * nlFT_readTable_samplespertimeunit);
  chancount = length(nlFT_readTable_chancolumns);

  % Build a plausible-looking header for continuous data.

  header = struct( ...
    'Fs', nlFT_readTable_samprate, ...
    'nChans', chancount, 'nSamples', sampcount, ...
    'nSamplesPre', 0, 'nTrials', 1 );

  header.label = nlFT_readTable_chancolumns;

  scratch = nlFT_readTable_chancolumns;
  scratch(:) = { 'analog' };
  header.chantype = scratch;

  scratch(:) = { 'unknown' };
  header.chanunit = scratch;

end


% Done.

end


%
% This is the end of the file.
