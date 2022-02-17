function evstructarray = nlFT_uncompressFTEvents(evtable, typelut)

% function evstructarray = nlFT_uncompressFTEvents(evtable, typelut)
%
% This de-compresses a compressed Field Trip event list that was produced by
% nlFT_compressFTEvents(). Table columns are converted back into structure
% fields, the "type" column is converted back to cell data, and empty
% "offset" and "duration" fields are created if not already present.
%
% If an empty LUT is given, the "type" column is copied as-is rather than
% translated. Otherwise all compressed "type" values must be valid indices
% into the lookup table.
%
% "evtable" is a table containing compressed event data.
% "typelut" is a cell array containing values to store in the "type" field
%   in the reconstructed structure array.
%
% "evstructarray" is a Field Trip event list (structure array).


%
% Build data as cell arrays before creating the structure array.


% We know the "sample" field exists and is numeric.

sampledata = num2cell(evtable.sample);


% Value exists but might or might not be numeric.

valuedata = evtable.value;
if ~iscell(valuedata)
  valuedata = num2cell(valuedata);
end


% Get type indices and decode them.

typecodes = evtable.type;
if isempty(typelut)
  % Copy type codes verbatim as type data.
  typedata = num2cell(typecodes);
else
  % Decode type codes.
  typedata = typelut(typecodes);
end


% Get offset and duration if present.

offsetdata = {};
if ismember('offset', evtable.Properties.VariableNames)
  offsetdata = num2cell(evtable.offset);
else
  offsetdata(1:length(sampledata)) = {[]};
end

durationdata = {};
if ismember('duration', evtable.Properties.VariableNames)
  durationdata = num2cell(evtable.duration);
else
  durationdata(1:length(sampledata)) = {[]};
end


% Assemble the structure array.

if ~isrow(sampledata)   ; sampledata = transpose(sampledata)     ; end
if ~isrow(valuedata)    ; valuedata = transpose(valuedata)       ; end
if ~isrow(typedata)     ; typedata = transpose(typedata)         ; end
if ~isrow(offsetdata)   ; offsetdata = transpose(offsetdata)     ; end
if ~isrow(durationdata) ; durationdata = transpose(durationdata) ; end

evstructarray = struct( 'sample', sampledata, 'value', valuedata, ...
  'type', typedata, 'offset', offsetdata, 'duration', durationdata );


% Done.

end


%
% This is the end of the file.
