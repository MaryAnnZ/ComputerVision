%CV UE2, Aufgabe 4
%IN GENERAL:
%1. Find interest points in both images.
%2. Describe the local appearance of interest points.
%3. Get a set of putative matches between the local
%   descriptors of the two images.
%4. Perform RANSAC to estimate the correct transformation 
%   in the presence of false matches.
%%%%%%%%%%%%%

%1) Sift
%Convert to greyscale
%use vl_sift for feature extraction
%match descriptors with vl_ubcmatch 
% --> plot matches with match_plot
%apply RAMSAC for outliners
% --> estimate homography 1 and 2 image

% bestHomography = 0;

% for n = 1000 times:
% ..> randomly choose four matches (4 points of first and corresponding on
% the 2. (function randsample)
% ..> estimate homography with function fitgeotrans
%     TRY CATCH!
% ..> transform all other points in the first image with
%     function transformPointsForward
% ..> determine # of inliers
% if (bestHomography<currentHomography
%       bestHomography = currentHomography

%overlay the features using vl_plotframe

%take the homography with maximum # of inliners!

%transform the first image into the second 
% with function inwarp 