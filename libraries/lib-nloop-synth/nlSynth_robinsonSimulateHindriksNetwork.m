function [ firingrates potentials ] = ...
  nlSynth_robinsonSimulateHindriksNetwork( duration, timestep, ...
    modelparams, intcouplings, popcount, cortexmixing, cortexdelays_ms )

% function [ firingrates potentials ] = ...
%   nlSynth_robinsonSimulateHindriksNetwork( duration, timestep, ...
%     modelparams, intcouplings, popcount, cortexmixing, cortexdelays )
%
% This simulates cortex and thalamus neural activity, using the model from
% Robinson 2002 with augmented input per Freyer 2011 and Hindriks 2023:
%
% https://journals.aps.org/pre/abstract/10.1103/PhysRevE.65.041924
% https://www.jneurosci.org/content/31/17/6353.short
% https://www.nature.com/articles/s42003-023-04648-x
%
% This simulates N populations of excitatory and inhibitory neurons in the
% cortex, and N populations of neurons in the specific and reticular nuclei
% in the thalamus (per Freyer 2011). Excitatory neuron populations in the
% cortex interact with each other, per Hindriks 2023.
%
% NOTE - This uses the forward Euler method for evolving system state.
% This is numerically stable if and only if the time step is much smaller
% than the time scales of any system dynamics. Make this much smaller than
% you think you need to.
%
% "duration" is the number of seconds to simulate.
% "timestep" is the amount of time to advance the simulation during each
%   sample, in seconds. NOTE - This must be much smaller than system
%   dynamics timescales!
% "modelparams" is a structure specifying model tuning parameters, per
%   MODELPARAMSROBINSON.txt.
% "intcouplings" is a 4x4 matrix indexed by (destination,source) that
%   provides the coupling weights (in mV*s) between excitatory cortex
%   neurons (1), inhibitory cortex neurons (2), specific nucleus neurons (3),
%   and reticular neurons (4). Typical coupling range from -2 to +2.
% "popcount" is the number of neural populations to simulate (Npop).
% "cortexmixing" is a Npop x Npop matrix indexed by (destination,source)
%   that specifies the internal communication mixing of excitatory neurons
%   in the cortex. After mixing, these then get weighted by (scalar)
%   modelparams.mixturecoupling before integration as neural inputs. Set
%   this to [] to omit internal cortex communication/mixing.
% "cortexdelays_ms" is a Npop x Npop matrix indexed by (destination,source)
%   that specifies the internal communication delays of excitatory neurons
%   in the cortex, in milliseconds. Set this to [] to omit internal cortex
%   communication/mixing.
%
% "firingrates" is a 4 x Npop x Nsamples matrix containing firing rates
%   for excitatory cortex neurons (1), inhibitory cortex neurons (2),
%   specific nucleus neurons (3), and reticular neurons (4). The excitatory
%   cortex neuron firing rates are gamma-damped, per Robinson 2002.
% "potentials" is a 4 x Npop x Nsamples matrix containing the cell-body
%   potentials of each type of neuron. This is primarily intended for
%   debugging. For all neurons _except_ the excitatory cortex neurons, the
%   firing rates should be nlSynth_robinsonGetSigmoid( potentials ). The
%   excitatory cortex neuron rates are gamma-damped, per Robinson 2002.


%
% Magic values.

startup_secs = 2.0;

regioncount = 4;
regionidxexcitatory = 1;
regionidxinhibitory = 2;
regionidxspecific = 3;
regionidxreticular = 4;

extcount = 2;
extidxnoise = 1;
extidxcortex = 2;



%
% Derived values.

want_mixing = (~isempty(cortexmixing)) && (~isempty(cortexdelays_ms));

extcouplings = zeros(regioncount,extcount);
extcouplings(regionidxspecific,extidxnoise) = modelparams.noisecoupling;
if want_mixing
  extcouplings(regionidxexcitatory,extidxcortex) = ...
    modelparams.mixturecoupling;
end



%
% Get various time spans in samples.
% Make sure to divide seconds by seconds and milliseconds by milliseconds.

timestep_ms = 1000 * timestep;

padsamps = round(startup_secs / timestep);
padsamps = max(1,padsamps);

sampcount = round(duration / timestep);
sampcount = max(1,sampcount) + padsamps;

cortexdelays_samp = [];
if want_mixing
  cortexdelays_samp = round(cortexdelays_ms / timestep_ms);
end

halfdelay_samp = round(modelparams.halfdelay_ms / timestep_ms);



%
% Run the simulation.

% Per Hindriks 2023, state is initialized to zero. We start simulating
% late enough that all delayed copies are pulled from valid loations.
% Simulation runs for a while (typically 2 seconds) to stabilize before we
% treat its contents as valid.

potentials = zeros(regioncount, popcount, sampcount);
velocities = zeros(regioncount, popcount, sampcount);
cortexrates = zeros(popcount,sampcount);
cortexvelocities = zeros(popcount,sampcount);

% We don't keep a history for the noise and cortex mixing connections.
extrates = zeros(extcount, popcount);

% Figure out what the maximum internal delay is. This tells us where to
% start the simulation.
startsamp = 0;
if want_mixing
  startsamp = max(max(cortexdelays_samp));
end
startsamp = max(startsamp, halfdelay_samp);
% Matlab starts counting samples at 1.
startsamp = 1 + startsamp;


% Fetch various parameters for convenience.
noisemean = modelparams.noisemean;
noiseaddsigma = modelparams.noisesigma;
noisemultsigma = noiseaddsigma * modelparams.noisemultfactor;


% Walk through this sample by sample.
% This is slow (Matlab can't implement it as vector operations), but is
% much simpler than setting up and solving finite difference matrices.

for sampidx = startsamp:(sampcount-1)

  % Fetch present and loop-delayed state.
  % Use "reshape" rather than "squeeze" in case popcount is 1.

  thispotential = reshape( potentials(:,:,sampidx), regioncount, popcount );
  thisvelocity = reshape( velocities(:,:,sampidx), regioncount, popcount );
  thiscortexrate = reshape( cortexrates(:,sampidx), 1, regioncount );
  thiscortexvel = reshape( cortexvelocities(:,sampidx), 1, regioncount );

  statepresent = struct( 'potentials', thispotential, ...
    'velocities', thisvelocity, 'cortexrates', thiscortexrate, ...
    'cortexvelocities', thiscortexvel );

  thispotential = reshape( potentials(:,:,(sampidx-halfdelay_samp)), ...
    regioncount, popcount );
  thisvelocity = reshape( velocities(:,:,(sampidx-halfdelay_samp)), ...
    regioncount, popcount );
  thiscortexrate = reshape( cortexrates(:,(sampidx-halfdelay_samp)), ...
    1, regioncount );
  thiscortexvel = reshape( cortexvelocities(:,(sampidx-halfdelay_samp)), ...
    1, regioncount );

  statepast = struct( 'potentials', thispotential, ...
    'velocities', thisvelocity, 'cortexrates', thiscortexrate, ...
    'cortexvelocities', thiscortexvel );


  % Build the delayed mixed cortex inputs.

  extrates(extidxcortex,:) = 0;

  if want_mixing
    % We're pulling from different time samples, so we have to iterate this
    % instead of using a matrix multiplication.
    for dstidx = 1:popcount
      thisdestrate = 0;

      for srcidx = 1:popcount
        thisdelay = cortexdelays_samp(dstidx,srcidx);
        thisweight = cortexmixing(dstidx,srcidx);
        thisdestrate = thisdestrate + ...
          thisweight * cortexrates(srcidx,(sampidx-thisdelay));
      end

      extrates(extidxcortex,dstidx) = thisdestrate;
    end
  end


  % Build the noise input.

  % NOTE - This is scaled by 1/sqrt(timestep).
  % We're multiplying by (timestep) during integration, so the actual
  % coefficient ends up being sqrt(timestep) rather than 1/sqrt(timestep).

  % This was done in the code used for Hindriks 2023. The idea is that if
  % each sample is an independent draw, lumping N samples together increases
  % the standard deviation by sqrt(N). This factor normalizes that, so that
  % for a fixed time interval (such as 1 second) we'll always compute the
  % same standard deviation regardless of step size.

  % We're using mean + additive + multiplicative noise, per references.
  % Since this is an input to the thalamus from the cortex, it's delayed.
  thisnoise = noisemean + noiseaddsigma * randn(1,popcount) ...
    + noisemultsigma * randn(1,popcount) .* statepast.cortexrates;

  thisnoise = thisnoise * sqrt(timestep);

  extrates(extidxnoise,:) = thisnoise;


  % Simulate this time step and save the results.

  statefuture = nlSynth_robinsonStepCortexThalamus( modelparams, timestep, ...
    statepresent, statepast, intcouplings, extrates, extcouplings );

  potentials(:,:,sampidx+1) = statefuture.potentials;
  velocities(:,:,sampidx+1) = statefuture.velocities;
  cortexrates(:,sampidx+1) = statefuture.cortexrates;
  cortexvelocities(:,sampidx+1) = statefuture.cortexvelocities;

end



%
% Package the results.

% Get firing rates.
firingrates = nlSynth_robinsonGetSigmoid( potetnials, ...
  modelparams.qmax, modelparams.threshlevel, modelparams.threshsigma );

% Special-case the gamma-damped excitatory cortex rates.
firingrates(regionidxexcitatory,:,:) = cortexrates;

% Crop to remove the startup region.
potentials = potentials(:,:,(1+padsamps):sampcount);
firingrates = firingrates(:,:,(1+padsamps):sampcount);



% Done.
end


%
% This is the end of the file.
