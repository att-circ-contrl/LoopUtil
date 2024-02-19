function [ xseries yseries ] = nlProc_projectGraphTSNE( ...
  weightsvstime, firstindices, secondindices, xguess, yguess, smoothwindow )

% function [ xseries yseries ] = nlProc_projectGraphTSNE( ...
%   weightsvstime, firstindices, secondindices, xguess, yguess, smoothwindow )
%
% This uses t-SNE projection to arrange vertices of a graph in 2D space.
% If given weights that evolve over time, it'll produce a projection that
% evolves over time.
%
% This was written to work with cross-correlation matrices, but should work
% with any kind of similarity metric normalized to 0..1.
%
% "weightsvstime" is a matrix indexed by (firstidx,secondidx,tidx) with
%   connection weights (in the range 0..1).
% "firstindices" is a vector mapping first index values to vertex numbers.
% "secondindices" is a vector mapping second index values to vertex numbers.
% "xguess" is a vector containing the initial X coordinates of each vertex.
%   This will be perturbed before use.
% "yguess" is a vector containing the initial Y coordinates of each vertex.
%   This will be perturbed before use.
% "smoothwindow" is the number of time steps over which to perform smoothing.
%   This should be at least 6. If it's too small, or NaN, or [], no smoothing
%   is performed.
%
% "xseries" is a vector indexed by (tidx,vertidx) containing projected vertex
%   X coordinates evolving over time.
% "yseries" is a vector indexed by (tidx,vertidx) containing projected vertex
%   Y coordinates evolving over time.


% Get metadata.

firstcount = size(weightsvstime,1);
secondcount = size(weightsvstime,2);

timecount = size(weightsvstime,3);

vertcount = length(xguess);


% Force sanity.

nanmask = isnan(weightsvstime);

weightsvstime = min(weightsvstime,1);
weightsvstime = max(weightsvstime,0);

weightsvstime(nanmask) = NaN;


% Initialize output.
xseries = zeros(timecount,vertcount);
yseries = zeros(timecount,vertcount);



%
% Get a projection that evolves over time.

thisx = xguess;
thisy = yguess;

desiredmag = max(abs( thisx + i * thisy ));

for tidx = 1:timecount

  oldx = thisx;
  oldy = thisy;

  weightslice = weightsvstime(:,:,tidx);

  % Get a t-SNE projection using the previous timestep as the initial state.

  [ thisx thisy ] = helper_getNewLocations( ...
    weightslice, firstindices, secondindices, thisx, thisy );


  % Remove drift.

  thisx = thisx - mean(thisx);
  thisy = thisy - mean(thisy);


  % Remove rotation and mirroring.
  % NOTE - this can still drift, since it's done frame by frame.

  % Mirrored.
  [ err2 flipx flipy ] = helper_rotateToFit( - thisx, thisy, oldx, oldy );

  % Non-mirrored (default).
  [ err1 thisx thisy ] = helper_rotateToFit( thisx, thisy, oldx, oldy );

  if err2 < err1
    thisx = flipx;
    thisy = flipy;
  end


  % Save a scaled version of the projection (same size as the user's guess).

  thismag = max(abs( thisx + i * thisy ));
  thismag = max(1e-20, thismag);

  xseries(tidx,:) = thisx * desiredmag / thismag;
  yseries(tidx,:) = thisy * desiredmag / thismag;

end


%
% Perform smoothing, if requested.

if (~isempty(smoothwindow)) && (~isnan(smoothwindow)) ...
  && (round(smoothwindow) > 5)

  halfwindow = round(smoothwindow) / 2;
  halfwindow = round(halfwindow + 0.4);

  if timecount >= (halfwindow + halfwindow + 1)

    smoothtime = 1:timecount;

    threshperc = 25;
    threshmult = 2;

    for vidx = 1:vertcount
      % Fetch this vertex's series.
      thisx = xseries(:,vidx);
      thisy = yseries(:,vidx);


      % First pass: Outlier rejection.

      thisx = nlProc_squashOutliersSlidingWindow( ...
        smoothtime, thisx, halfwindow, threshperc, threshmult );
      thisy = nlProc_squashOutliersSlidingWindow( ...
        smoothtime, thisy, halfwindow, threshperc, threshmult );

      thisx = nlProc_fillNaN(thisx);
      thisy = nlProc_fillNaN(thisy);


      % Second pass: Smoothing.

      thisx = movmean(thisx, halfwindow);
      thisx = movmean(thisx, halfwindow);

      thisy = movmean(thisy, halfwindow);
      thisy = movmean(thisy, halfwindow);


      % Re-save this vertex's series.
      xseries(:,vidx) = thisx;
      yseries(:,vidx) = thisy;
    end

  end

end


% Done.
end



%
% Helper Functions


% This converts weights (0..1) into distances and performs a t-SNE
% projection, using previous coordinates as seed values.
%
% If the previous coordinate vectors are [], no seed value is used.
%
% "weightmatrix" is indexed by (firstidx,secondidx) and is (0..1).
% "firstindices" converts firstidx into pointidx.
% "secondindices" converts secondidx into pointidx.
% "oldx" and "oldy" are indexed by (pointidx).

function [ newx newy ] = helper_getNewLocations( ...
  weightmatrix, firstindices, secondindices, oldx, oldy )

  %
  % Build a symmetrical full-sized weight matrix.

  firstcount = length(firstindices);
  secondcount = length(secondindices);
  allcount = length(oldx);

  allmatrix = zeros(allcount,allcount);

  % FIXME - Blithely assume that either there are no paired entries in
  % weightmatrix, or that paired elements are the same, or that one is NaN.
  for firstidx = 1:firstcount
    allfirst = firstindices(firstidx);
    for secondidx = 1:secondcount
      allsecond = secondindices(secondidx);
      thisval = weightmatrix(firstidx,secondidx);
      if ~isnan(thisval)
        allmatrix(allfirst,allsecond) = thisval;
        allmatrix(allsecond,allfirst) = thisval;
      end
    end
  end

  % Force a weight range of 0..1.
  allmatrix = min(allmatrix, 1);
  allmatrix = max(allmatrix, 0);


  %
  % Transform into a higher-dimensional space with the desired distances.

  % NOTE - We're cheating with distances, and using the t-SNE option that
  % uses correlation as distance.

  % We can't turn the weight matrix into distances in Euclidean space, but
  % we _can_ generate N vectors with specified correlations.

  % We need N (N-1) / 2 orthogonal basis vectors. Use sine waves.
  % We need at least twice that many samples to capture harmonics; use more.

  % We need a lookup table to convert allmatrix indices into basis indices.
  basiscount = 0;
  basisidxlut = zeros(allcount,allcount);
  for firstidx = 1:allcount
    for secondidx = (firstidx+1):allcount
      basiscount = basiscount + 1;
      basisidxlut(firstidx,secondidx) = basiscount;
      basisidxlut(secondidx,firstidx) = basiscount;
    end
  end

  basislength = basiscount * 4;
  thetavec = 1:basislength;
  thetavec = 2 * pi * (thetavec - 1) / basislength;

  basistable = zeros(basiscount,basislength);
  for bidx = 1:basiscount
    % Add a shift so that the first sample isn't always 0 or always 1.
    basistable(bidx,:) = sin(bidx * (thetavec + 0.1));
  end

  % Normalize to a standard deviation of 1 (it's already zero-mean).
  basistable = basistable * sqrt(2);

  % Build the input vectors. Use the square roots of the weights as
  % coefficients (since we're multiplying samples from two inputs).

  highvecs = zeros(allcount,basislength);

  for firstidx = 1:allcount
    thisvec = zeros(1,basislength);
    for secondidx = 1:allcount
      if firstidx ~= secondidx
        bidx = basisidxlut(firstidx,secondidx);
        thisvec = thisvec ...
          + sqrt( allmatrix(firstidx,secondidx) ) * basistable(bidx,:);
      end
    end
    highvecs(firstidx,:) = thisvec;
  end


  %
  % Perform t-SNE on the higher-dimensional vectors, with (1 - correlation)
  % as the distance metric.

  if isempty(oldx) || isempty(oldy)

    % Get a new projection.
    newcoords = tsne( highvecs, 'Numdimensions', 2, ...
      'Distance', 'correlation' );

    newx = newcoords(:,1);
    newy = newcoords(:,2);

  else

    % Initialize to preserve row/columnness of the output.
    newx = oldx;
    newy = oldy;

    % Build the initial coordinate matrix.
    oldcoords = zeros(allcount,2);
    oldcoords(:,1) = oldx;
    oldcoords(:,2) = oldy;

    % Optimize the projection.
    newcoords = tsne( highvecs, 'Numdimensions', 2, 'InitialY', oldcoords, ...
      'Distance', 'correlation' );

    newx(:) = newcoords(:,1);
    newy(:) = newcoords(:,2);

  end

end



% This rotates oldx and oldy to best match refx and refy, computing error.

function [ err newx newy ] = helper_rotateToFit( oldx, oldy, refx, refy )

  % We're minimizing the squared distance between rotated and reference
  % points.

  x1y0 = sum( oldx .* refy );
  x0y1 = sum( refx .* oldy );

  x0x1 = sum( oldx .* refx );
  y0y1 = sum( oldy .* refy );

  theta = atan( (x1y0 - x0y1) / (x0x1 + y0y1) );

  % Default to the -pi/2..+pi/2 case.

  newx = oldx * cos(theta) - oldy * sin(theta);
  newy = oldx * sin(theta) + oldy * cos(theta);

  diffx = newx - refx;
  diffy = newy - refy;
  err = sum(diffx .* diffx) + sum(diffy .* diffy);

  % Test the 180 degree rotated case.

  flipx = -newx;
  flipy = -newy;

  diffx = flipx - refx;
  diffy = flipy - refy;
  fliperr = sum(diffx .* diffx) + sum(diffy .* diffy);

  if fliperr < err
    newx = flipx;
    newy = flipy;
    err = fliperr;
  end

end


%
% This is the end of the file.
