function nlFT_initReadTable( datatable, chancolumns, timecolumn, ...
  timefirst, timelast, samplespertimeunit, samprate )

% function nlFT_initReadTable( datatable, chancolumns, timecolumn, ...
%   timefirst, timelast, samplespertimeunit, samprate )
%
% This stores a table and metadata to be read using nlFT_readTableHeader()
% and nlFT_readTableData(). The idea is to be able to give Field Trip a way
% to read non-uniformly-sampled tabular data as waveform data.
%
% FIXME - Support for nlFT_readTableEvents NYI.
%
% To release memory allocated for the copy of the table, call this with an
% empty table.
%
% "datatable" is the table to read.
% "chancolumns" is a cell array containing column labels of data columns.
% "timecolumn" is the label of the timestamp column.
% "timefirst" is the timestamp value corresponding to sample 1.
% "timelast" is the timestamp value corresponding to the last waveform sample.
% "samplespertimeunit" is the number of samples corresponding to a timestamp
%   change of 1.0 timestamp units. For seconds, this is equal to "samprate".
% "samprate" is the number of samples per second.
%
% FIXME - This stores state as global variables, including a copy of the
% table. This was the least-ugly way to store persistent state.


% Import global variables.

global nlFT_readTable_datatable;
global nlFT_readTable_chancolumns;
global nlFT_readTable_timecolumn;
global nlFT_readTable_timefirst;
global nlFT_readTable_timelast;
global nlFT_readTable_samplespertimeunit;
global nlFT_readTable_samprate;


% Set global variable values.

nlFT_readTable_datatable = datatable;
nlFT_readTable_chancolumns = chancolumns;
nlFT_readTable_timecolumn = timecolumn;
nlFT_readTable_timefirst = timefirst;
nlFT_readTable_timelast = timelast;
nlFT_readTable_samplespertimeunit = samplespertimeunit;
nlFT_readTable_samprate = samprate;


% Done.

end


%
% This is the end of the file.
