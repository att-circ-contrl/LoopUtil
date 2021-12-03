function metadata = vIntan_read_header( fname )

% function metadata = vIntan_read_header( fname )
%
% This reads the metadata header from Intan ".rhd" and ".rhs" files.
% If reading fails, an empty structure array is returned.
%
% This file is derived from code supplied by Intan Technologies (used and
% re-licensed with permission).
%
% "fname" is the name of the file to read from, including path.
%
% "metadata" is a structure containing header data, per "INTAN_METADATA.txt".


% NOTE - Derived from Intan's 2021 Feb 8 code (version 3.0).


% Initialize.
metadata = struct();
isok = false;
file_is_open = false;

% RHD/RHS switch.
is_stim = false;


% Open the file and read the magic number.
if isfile(fname)

  fid = fopen(fname, 'r');
  file_is_open = true;

  % Get various file metadata.
  finfo = dir(filename);
  filesize = finfo.bytes;
  filepath = finfo.folder;


  % Check 'magic number' at beginning of file to make sure it's an Intan file.
  magic_number = fread(fid, 1, 'uint32');
  if magic_number == hex2dec('c6912702')
    isok = true;
  elseif magic_number == hex2dec('d69127ac')
    isok = true;
    is_stim = true;
  end
end


% If it looks good, continue reading metadata.

if isok

  % Save filename and path.
  metadata.filename = fname;
  metadata.path = filepath;

  % Save device type.
  metadata.devtype = 'RHD';
  if is_stim
    metadata.devtype = 'RHS';
  end


  % Read and save version number.

  data_file_main_version_number = fread(fid, 1, 'int16');
  data_file_secondary_version_number = fread(fid, 1, 'int16');

  metadata.version_major = data_file_main_version_number;
  metadata.version_minor = data_file_secondary_version_number;


  % Compute and save the block size. This applies to monolithic data.

  if is_stim
    num_samples_per_data_block = 128;
  elseif (data_file_main_version_number == 1)
    num_samples_per_data_block = 60;
  else
    num_samples_per_data_block = 128;
  end

  metadata.num_samples_per_block = num_samples_per_data_block;


  % Read amplifier sampling rate and frequency settings.

  sample_rate = fread(fid, 1, 'single');

  dsp_enabled = fread(fid, 1, 'int16');
  actual_dsp_cutoff_frequency = fread(fid, 1, 'single');
  actual_lower_bandwidth = fread(fid, 1, 'single');
  if is_stim
    actual_lower_settle_bandwidth = fread(fid, 1, 'single');
  end
  actual_upper_bandwidth = fread(fid, 1, 'single');

  desired_dsp_cutoff_frequency = fread(fid, 1, 'single');
  desired_lower_bandwidth = fread(fid, 1, 'single');
  if is_stim
    desired_lower_settle_bandwidth = fread(fid, 1, 'single');
  end
  desired_upper_bandwidth = fread(fid, 1, 'single');

  % This tells us if a software 50/60 Hz notch filter was enabled during
  % the data acquisition.
  notch_filter_mode = fread(fid, 1, 'int16');
  notch_filter_frequency = 0;
  if (notch_filter_mode == 1)
    notch_filter_frequency = 50;
  elseif (notch_filter_mode == 2)
    notch_filter_frequency = 60;
  end

  desired_impedance_test_frequency = fread(fid, 1, 'single');
  actual_impedance_test_frequency = fread(fid, 1, 'single');


  % NOTE - Flags aren't saved as booleans!
  % DSP flag is an int16 and notch filter flag/mode is implied by frequency.


  % Build and save a data structure with frequency-related information.

  frequency_parameters = struct( ...
    'amplifier_sample_rate', sample_rate, ...
    'aux_input_sample_rate', sample_rate / 4, ...
    'supply_voltage_sample_rate', sample_rate / num_samples_per_data_block, ...
    'board_adc_sample_rate', sample_rate, ...
    'board_dig_in_sample_rate', sample_rate, ...
    'desired_dsp_cutoff_frequency', desired_dsp_cutoff_frequency, ...
    'actual_dsp_cutoff_frequency', actual_dsp_cutoff_frequency, ...
    'dsp_enabled', dsp_enabled, ...
    'desired_lower_bandwidth', desired_lower_bandwidth, ...
    'actual_lower_bandwidth', actual_lower_bandwidth, ...
    'desired_upper_bandwidth', desired_upper_bandwidth, ...
    'actual_upper_bandwidth', actual_upper_bandwidth, ...
    'notch_filter_frequency', notch_filter_frequency, ...
    'desired_impedance_test_frequency', desired_impedance_test_frequency, ...
    'actual_impedance_test_frequency', actual_impedance_test_frequency );

  if is_stim
    frequency_parameters.desired_lower_settle_bandwidth = ...
      desired_lower_settle_bandwidth;
    frequency_parameters.actual_lower_settle_bandwidth = ...
      actual_lower_settle_bandwidth;
  end

  metadata.frequency_parameters = frequency_parameters;


  % Read and save stimulation-related information.

  if is_stim
    amp_settle_mode = fread(fid, 1, 'int16');
    charge_recovery_mode = fread(fid, 1, 'int16');
    stim_step_size = fread(fid, 1, 'single');
    charge_recovery_current_limit = fread(fid, 1, 'single');
    charge_recovery_target_voltage = fread(fid, 1, 'single');

    stim_parameters = struct( ...
      'stim_step_size', stim_step_size, ...
      'charge_recovery_current_limit', charge_recovery_current_limit, ...
      'charge_recovery_target_voltage', charge_recovery_target_voltage, ...
      'amp_settle_mode', amp_settle_mode, ...
      'charge_recovery_mode', charge_recovery_mode );

    metadata.stim_parameters = stim_parameters;
  end


  % Read and save notes.

  notes = struct( ...
    'note1', fread_QString(fid), ...
    'note2', fread_QString(fid), ...
    'note3', fread_QString(fid) );

  metadata.notes = notes;


  % Read additional metadata.
  % NOTE - Board mode seems to only affect the board ADC voltage scale, and
  % only with RHD boards.

  num_temp_sensor_channels = 0;
  dc_amp_data_saved = 0;
  board_mode = 0;
  reference_channel = '';

  if is_stim
    dc_amp_data_saved = fread(fid, 1, 'int16');
    board_mode = fread(fid, 1, 'int16');
    reference_channel = fread_QString(fid);
  else
    % If data file is from GUI v1.1 or later, see if temperature sensor data
    % was saved.
    if ( (data_file_main_version_number == 1 ...
        && data_file_secondary_version_number >= 1) ...
      || (data_file_main_version_number > 1) )
      num_temp_sensor_channels = fread(fid, 1, 'int16');
    end

    % If data file is from GUI v1.3 or later, load board mode.
    % NOTE - This seems to only affect the board ADC voltage scale.
    if ( (data_file_main_version_number == 1 ...
        && data_file_secondary_version_number >= 3) ...
      || (data_file_main_version_number > 1) )
      board_mode = fread(fid, 1, 'int16');
    end

    % If data file is from v2.0 or later (Intan Recording Controller),
    % load name of digital reference channel.
    if (data_file_main_version_number > 1)
      reference_channel = fread_QString(fid);
    end
  end


  % Save these to the metadata structure.

  metadata.num_temp_sensor_channels = num_temp_sensor_channels;
  metadata.dc_amp_data_saved = dc_amp_data_saved;
  metadata.board_mode = board_mode;
  metadata.reference_channel = reference_channel;



  %
  % Create data structure templates and initialize data structures for
  % configuration information about the various banks' channels.

  % Define data structure for spike trigger settings.
  spike_trigger_struct = struct( ...
    'voltage_trigger_mode', {}, ...
    'voltage_threshold', {}, ...
    'digital_trigger_channel', {}, ...
    'digital_edge_polarity', {} );

  new_trigger_channel = struct(spike_trigger_struct);
  spike_triggers = struct(spike_trigger_struct);

  % Define data structure for data channels.
  channel_struct = struct( ...
    'native_channel_name', {}, ...
    'custom_channel_name', {}, ...
    'native_order', {}, ...
    'custom_order', {}, ...
    'board_stream', {}, ...
    'chip_channel', {}, ...
    'port_name', {}, ...
    'port_prefix', {}, ...
    'port_number', {}, ...
    'electrode_impedance_magnitude', {}, ...
    'electrode_impedance_phase', {} );

  new_channel = struct(channel_struct);

  % Create structure arrays for each type of data channel.
  amplifier_channels = struct(channel_struct);
  aux_input_channels = struct(channel_struct);
  supply_voltage_channels = struct(channel_struct);
  board_adc_channels = struct(channel_struct);
  board_dac_channels = struct(channel_struct);
  board_dig_in_channels = struct(channel_struct);
  board_dig_out_channels = struct(channel_struct);


  %
  % Read signal metadata from the file header.

  % NOTE - aux_input and supply_voltage are RHD-only, board_dac is RHS-only.

  amplifier_index = 1;
  aux_input_index = 1;
  supply_voltage_index = 1;
  board_adc_index = 1;
  board_dac_index = 1;
  board_dig_in_index = 1;
  board_dig_out_index = 1;

  number_of_signal_groups = fread(fid, 1, 'int16');

  for signal_group = 1:number_of_signal_groups
    signal_group_name = fread_QString(fid);
    signal_group_prefix = fread_QString(fid);
    signal_group_enabled = fread(fid, 1, 'int16');
    signal_group_num_channels = fread(fid, 1, 'int16');
    signal_group_num_amp_channels = fread(fid, 1, 'int16');

    if isok && (signal_group_num_channels > 0) && (signal_group_enabled > 0)
      new_channel(1).port_name = signal_group_name;
      new_channel(1).port_prefix = signal_group_prefix;
      new_channel(1).port_number = signal_group;
      for signal_channel = 1:signal_group_num_channels
        if isok
          new_channel(1).native_channel_name = fread_QString(fid);
          new_channel(1).custom_channel_name = fread_QString(fid);
          new_channel(1).native_order = fread(fid, 1, 'int16');
          new_channel(1).custom_order = fread(fid, 1, 'int16');
          signal_type = fread(fid, 1, 'int16');
          channel_enabled = fread(fid, 1, 'int16');
          new_channel(1).chip_channel = fread(fid, 1, 'int16');
          if is_stim
            fread(fid, 1, 'int16');  % ignore command_stream
          end
          new_channel(1).board_stream = fread(fid, 1, 'int16');
          new_trigger_channel(1).voltage_trigger_mode = fread(fid, 1, 'int16');
          new_trigger_channel(1).voltage_threshold = fread(fid, 1, 'int16');
          new_trigger_channel(1).digital_trigger_channel = ...
            fread(fid, 1, 'int16');
          new_trigger_channel(1).digital_edge_polarity = ...
            fread(fid, 1, 'int16');
          new_channel(1).electrode_impedance_magnitude = ...
            fread(fid, 1, 'single');
          new_channel(1).electrode_impedance_phase = fread(fid, 1, 'single');

          if (channel_enabled)
            switch (signal_type)
              case 0
                amplifier_channels(amplifier_index) = new_channel;
                spike_triggers(amplifier_index) = new_trigger_channel;
                amplifier_index = amplifier_index + 1;
              case 1
                % RHD only.
                aux_input_channels(aux_input_index) = new_channel;
                aux_input_index = aux_input_index + 1;
              case 2
                % RHD only.
                supply_voltage_channels(supply_voltage_index) = new_channel;
                supply_voltage_index = supply_voltage_index + 1;
              case 3
                board_adc_channels(board_adc_index) = new_channel;
                board_adc_index = board_adc_index + 1;
              case 4
                % Din for RHD, DAC for RHS.
                if is_stim
                  board_dac_channels(board_dac_index) = new_channel;
                  board_dac_index = board_dac_index + 1;
                else
                  board_dig_in_channels(board_dig_in_index) = new_channel;
                  board_dig_in_index = board_dig_in_index + 1;
                end
              case 5
                % Dout for RHD, Din for RHS.
                if is_stim
                  board_dig_in_channels(board_dig_in_index) = new_channel;
                  board_dig_in_index = board_dig_in_index + 1;
                else
                  board_dig_out_channels(board_dig_out_index) = new_channel;
                  board_dig_out_index = board_dig_out_index + 1;
                end
              case 6
                % Dout for RHS.
                board_dig_out_channels(board_dig_out_index) = new_channel;
                board_dig_out_index = board_dig_out_index + 1;
              otherwise
                isok = false;
            end
          end

        end
      end
    end

  end


  % Store the metadata.

  num_amplifier_channels = amplifier_index - 1;
  num_aux_input_channels = aux_input_index - 1;
  num_supply_voltage_channels = supply_voltage_index - 1;
  num_board_adc_channels = board_adc_index - 1;
  num_board_dac_channels = board_dac_index - 1;
  num_board_dig_in_channels = board_dig_in_index - 1;
  num_board_dig_out_channels = board_dig_out_index - 1;

  % NOTE - We don't need to store "num_X"; the length of the associated
  % metadata structure arrays give us that.
  % NOTE - There are as many spike trigger entries as amplifier entries.

  metadata.amplifier_channels = amplifier_channels;
  metadata.spike_triggers = spike_triggers;
  metadata.aux_input_channels aux_input_channels;
  metadata.supply_voltage_channels = supply_voltage_channels;
  metadata.board_adc_channels = board_adc_channels;
  metadata.board_dac_channels = board_dac_channels;
  metadata.board_dig_in_channels = board_dig_in_channels;
  metadata.board_dig_out_channels = board_dig_out_channels;

end


%
% If everything looks okay, see how much data is stored in this file.

if isok
  % timestamp data
  bytes_per_block = num_samples_per_data_block * 4;

  % Each data block contains num_samples_per_data_block amplifier samples.
  if is_stim
    % RHS: Amplifier inputs, stimulation drive output, and optionally DC info.
    if (dc_amp_data_saved ~= 0)
      bytes_per_block = bytes_per_block + ...
        num_samples_per_data_block * (2 + 2 + 2) * num_amplifier_channels;
    else
      bytes_per_block = bytes_per_block + ...
        num_samples_per_data_block * (2 + 2) * num_amplifier_channels;
    end
  else
    % RHD: Just the amplifier inputs.
    bytes_per_block = bytes_per_block + ...
      num_samples_per_data_block * 2 * num_amplifier_channels;
  end

  % Auxiliary inputs are sampled 4x slower than amplifiers
  % Only nonzero for RHD.
  bytes_per_block = bytes_per_block + ...
    (num_samples_per_data_block / 4) * 2 * num_aux_input_channels;

  % Supply voltage is sampled once per data block
  % Only nonzero for RHD.
  bytes_per_block = bytes_per_block + 1 * 2 * num_supply_voltage_channels;

  % Board analog inputs are sampled at same rate as amplifiers
  bytes_per_block = bytes_per_block + ...
    num_samples_per_data_block * 2 * num_board_adc_channels;

  % Board analog outputs are sampled at same rate as amplifiers
  % Only nonzero for RHS.
  bytes_per_block = bytes_per_block + ...
    num_samples_per_data_block * 2 * num_board_dac_channels;

  % Board digital inputs are sampled at same rate as amplifiers
  % NOTE - 16 inputs, as a packed 16-bit integer.
  if (num_board_dig_in_channels > 0)
    bytes_per_block = bytes_per_block + num_samples_per_data_block * 2;
  end

  % Board digital outputs are sampled at same rate as amplifiers
  % NOTE - 16 outputs, as a packed 16-bit integer.
  if (num_board_dig_out_channels > 0)
    bytes_per_block = bytes_per_block + num_samples_per_data_block * 2;
  end

  % Temp sensor is sampled once per data block
  % Only nonzero for RHD.
  if (num_temp_sensor_channels > 0)
    bytes_per_block = bytes_per_block + 1 * 2 * num_temp_sensor_channels;
  end


  % How many data blocks remain in this file?

  header_bytes = ftell(fid);
  bytes_remaining = filesize - header_bytes;
  num_data_blocks = bytes_remaining / bytes_per_block;


  % Store metadata for monolithic data.

  metadata.header_bytes = header_bytes;
  metadata.num_data_blocks = num_data_blocks;
  metadata.bytes_per_block = bytes_per_block;
end


% If everything is _not_ okay, squash the output.

if ~isok
  metadata = struct([]);
end

% Close the data file.
if file_is_open
  fclose(fid);
end


% Done.

end


%
% Helper Functions


% a = read_QString(fid)
%
% Read Qt style QString.  The first 32-bit unsigned number indicates
% the length of the string (in bytes).  If this number equals 0xFFFFFFFF,
% the string is null.

function a = fread_QString(fid)

  a = '';
  length = fread(fid, 1, 'uint32');
  if length ~= hex2num('ffffffff')
    % convert length from bytes to 16-bit Unicode words
    length = length / 2;

    for i=1:length
      a(i) = fread(fid, 1, 'uint16');
    end
  end

end


%
% This is the end of the file.
