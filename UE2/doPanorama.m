%CV UE2, Aufgabe 4
%IN GENERAL:
%1. Find interest points in both images.
%2. Describe the local appearance of interest points.
%3. Get a set of putative matches between the local
%   descriptors of the two images.
%4. Perform RANSAC to estimate the correct transformation 
%   in the presence of false matches.
%%%%%%%%%%%%%

%read input image
numberImages = 5;

path = 'input/';
format = '.jpg';
name = 'campus';

int = 1;
for i = numberImages-1
    
    rawImgLeft = imread(strcat(strcat(path,strcat(name,int2str(int),format))));
    rawImgRight = imread(strcat(strcat(path,strcat(name,int2str(int+1),format))));
    
    imgLeft = single(rgb2gray(rawImgLeft));
    imgRight = single(rgb2gray(rawImgRight));
        
    %Each column of F is a feature frame and has the format [X;Y;S;TH], 
    %where X,Y is the center of the frame, S is the scale and TH is
    %the orientation (in radians).
    %d = Each column of D is the descriptor of the corresponding frame in F. A
    %descriptor is a 128-dimensional vector of class UINT8.

    [Fleft, Dleft] = vl_sift (imgLeft);
    [Fright, Dright] = vl_sift (imgRight);
    
    %matches the two sets of SIFT descriptors
    [matches, score] = vl_ubcmatch(Dleft, Dright);
    
    %%plot the images with a connecting line for every feature point
    %match_plot(imgLeft,imgRight, Fleft(1:2,matches(1,:))',Fright(1:2,matches(2,:))');
    
    bestHomography = 0;
    maxInliners = 0;
    bestInlinersCoordinates = 0;
    
    turns = 100;
    
    while (turns>=0) 
        %Choose random 4 matches
        index = randsample(size(matches,2),4);
    
        randomCoordinatesLeft = [Fleft(1,matches(1,index(1))) Fleft(2,matches(1,index(1)));
                                 Fleft(1,matches(1,index(2))) Fleft(2,matches(1,index(2)));
                                 Fleft(1,matches(1,index(3))) Fleft(2,matches(1,index(3)));
                                 Fleft(1,matches(1,index(4))) Fleft(2,matches(1,index(4)));];
                            
        randomCoordinatesRight = [Fright(1,matches(2,index(1))) Fright(2,matches(2,index(1)));
                                  Fright(1,matches(2,index(2))) Fright(2,matches(2,index(2)));
                                  Fright(1,matches(2,index(3))) Fright(2,matches(2,index(3)));
                                  Fright(1,matches(2,index(4))) Fright(2,matches(2,index(4)));];
                            
        try 
            %estimage homography between points
            
            %movingcoordinates = leftimage Points
            %fixedPoints = rightimage Points
            currentHomography  = fitgeotrans(randomCoordinatesLeft,randomCoordinatesRight,'projective');
        catch ME
            %point pairs are not chosen properly (e.g. three of them lie on the
            %same line)
            
            %error = 'hi'
            break;
        end
        
        [xLeftTrans,yLeftTrans] = transformPointsForward(currentHomography, Fleft(1,matches(1,:)),Fleft(2,matches(1,:)));
    
        LeftTrans = [xLeftTrans(:) yLeftTrans(:)]';
        Right = [Fright(1,matches(1,:))' Fright(2,matches(1,:))']';
        
        distance = sqrt(sum((Right - LeftTrans).^2));
        
        inlinerCoordinates = zeros(1,1);
        first = 1;
        
        numInliners = 0;
        for i = 1:size(distance,2)
            if (distance(i)<5)
                numInliners = numInliners+1;
                if first==1
                    inlinerCoordinates = i;
                    first = 0;
                else
                    newRow = i;
                    inlinerCoordinates = [inlinerCoordinates ; newRow];
                end     
            end
        end
        
        
    
        if (numInliners> maxInliners)
            maxInliners = numInliners;
            bestHomography = currentHomography;
            bestInlinersCoordinates = inlinerCoordinates;
        end
               
        % ..> determine # of inliers
        % if (bestHomography<currentHomography
        %       bestHomography = currentHomography   
        turns = turns-1;
    end
        
    maxInliners
    bestInlinersCoordinates  
    
    
    
    
    %%%%%LATER
    %%%For report: show with vl_plotframe
    
    %subplot(1,2,1), imshow(imgLeft)
    %subplot(1,2,2), imshow(imgRight)
    int = int+1;
end




%1) Sift
%Convert to greyscale
%use vl_sift for feature extraction
%match descriptors with vl_ubcmatch 
% --> plot matches with match_plot
%apply RAMSAC for outliners
% --> estimate homography 1 and 2 image


%overlay the features using vl_plotframe

%take the homography with maximum # of inliners!

%transform the first image into the second 
% with function inwarp 