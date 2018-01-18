function [homography] = doHomography(rawImageLeft, rawImageRight, debug)
% imageLeft and imageRight as RGB

% return best homography as projective2D between left and right image
imgLeft = im2single(rgb2gray(rawImageLeft));
imgRight = im2single(rgb2gray(rawImageRight));

%%%%1. Find interest points in both images.
%F = feature frame, [X;Y;S;TH],
%    X,Y = center of the frame, S = scale and TH = the orientation (in radians).
%D = descriptor of the corresponding frame in F. (UINT8, 128-dimensional vector)
[Fleft, Dleft] = vl_sift (imgLeft);
[Fright, Dright] = vl_sift (imgRight);

%%%%2. Get a set of putative matches between the local descriptors of the two images.
% matches saves indices in F (sift output) with best feature point matching
% first row is left images, second is right image
[matches, score] = vl_ubcmatch(Dleft, Dright);

if debug
    %% plot matches and feature points
    imgOutputLeft = rgb2gray(im2double(rawImageLeft));
    
    figure(1) ;
    imagesc(imgOutputLeft);
    
    colormap(gray);
    hold on;
    h1 = vl_plotframe(Fleft(:,:)) ;
    h2 = vl_plotframe(Fleft(:,:)) ;
    set(h1,'color','k','linewidth',3) ;
    set(h2,'color','y','linewidth',2) ;
    
    axis image off;
    
    %plot the images with a connecting line for every feature point
    match_plot(imgLeft,imgRight, Fleft(1:2,matches(1,:))',Fright(1:2,matches(2,:))');
    
end



%%%%%4. Perform RANSAC to estimate the correct transformation in the presence
%   of false matches. save best homograpy, indices of best inliners
%   (indices of sift feature array)
bestHomography = 0;
maxInliners = 0;
bestInlinersIndices = 0;

turns = 1000;
while (turns>=0)
    %Choose random 4 matches
    index = randsample(size(matches,2),4);
    %get coordinates of the 4 random samples
    randomCoordinatesLeft = [Fleft(1,matches(1,index(:)))' Fleft(2,matches(1,index(:)))'];
    randomCoordinatesRight = [Fright(1,matches(2,index(:)))' Fright(2,matches(2,index(:)))'];
    
    try
        %estimage homography between random points
        
        %movingcoordinates = leftimage Points
        %fixedPoints = rightimage Points
        currentHomography  = fitgeotrans(randomCoordinatesLeft,randomCoordinatesRight,'projective');
    catch ME
        %point pairs are not chosen properly (e.g. three of them lie on the
        %same line
        error = 'hi';
        continue;
    end
    
    %Transform all other points of putative matches in the first image
    [xLeftTrans,yLeftTrans] = transformPointsForward(currentHomography, Fleft(1,matches(1,:)),Fleft(2,matches(1,:)));
    
    %calculate distance between transformate sift points in left and normal
    %in right (euclidean)
    LeftTrans = [xLeftTrans(:) yLeftTrans(:)]';
    Right =     [Fright(1,matches(2,:))' Fright(2,matches(2,:))']';
    
    distance = sqrt(sum((Right - LeftTrans).^2));
    
    %save indices of sift points with best inliner
    inlinerCoordinates = zeros(1,1);
    first = 1;
    numInliners = 0;
    for i = 1:1:size(distance,2)
        if (distance(i)<double(5))
            numInliners = numInliners+1;
            if first==1
                %save inliner, because it is a good one
                inlinerCoordinates = i;
                first = 0;
            else
                newRow = i;
                %save inliner, because it is a good one
                inlinerCoordinates = [inlinerCoordinates ; newRow];
            end
        end
    end
    
    
    %save the inliner coordinates and homography with the most inliners!
    if (numInliners> maxInliners)
        maxInliners = numInliners;
        bestHomography = currentHomography;
        bestInlinersIndices = inlinerCoordinates;
    end
    
    % ..> determine # of inliers
    % if (bestHomography<currentHomography
    %       bestHomography = currentHomography
    turns = turns-1;
end



%%%%% B.4 --> . Reestimate the homography with all inliers to obtain a more
%%%%%           accurate result.
VeryBestInlinerHomography = 0;

%estimage homography between inliner matches
inlinersCoordinatesLeft =  [Fleft(1,matches(1,bestInlinersIndices(:)))'  Fleft(2,matches(1,bestInlinersIndices(:)))'];
inlinersCoordinatesRight = [Fright(1,matches(2,bestInlinersIndices(:)))' Fright(2,matches(2,bestInlinersIndices(:)))'];

try
    %movingcoordinates = leftimage Points
    %fixedPoints = rightimage Points
    VeryBestInlinerHomography  = fitgeotrans(inlinersCoordinatesLeft,inlinersCoordinatesRight,'projective');
    
catch ME
    %point pairs are not chosen properly (e.g. three of them lie on the
    %same line)
    error = 'hi'
end

%%%%%%%%%%%%%%%%%%%%%%
if debug
    %Plot the matches of the inliers after step 4
    match_plot(imgLeft,imgRight, inlinersCoordinatesLeft,inlinersCoordinatesRight);
end


homography = VeryBestInlinerHomography;

end