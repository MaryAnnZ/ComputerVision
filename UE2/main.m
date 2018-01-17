%read input image
path = 'input/';
name = 'campus';
format = '.jpg';

% Load images.
buildingDir = fullfile(toolboxdir('vision'), 'visiondata', 'building');
buildingScene = imageDatastore('input/campus');

% Display images to be stitched
montage(buildingScene.Files)

% Read the first image from the image set.
I = readimage(buildingScene, 1);

% Initialize features for I(1)
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

% Initialize all the transforms to the identity matrix. Note that the
% projective transform is used here because the building images are fairly
% close to the camera. Had the scene been captured from a further distance,
% an affine transform would suffice.
numImages = numel(buildingScene.Files);
tforms(numImages) = projective2d(eye(3));

% Iterate over remaining image pairs
for n = 2:numImages

    % Store points and features for I(n-1).
    pointsPrevious = points;
    featuresPrevious = features;

    % Read I(n).
    I = readimage(buildingScene, n);

    % Detect and extract SURF features for I(n).
    grayImage = rgb2gray(I);
    points = detectSURFFeatures(grayImage);
    [features, points] = extractFeatures(grayImage, points);

    % Find correspondences between I(n) and I(n-1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);

    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);

    % Estimate the transformation between I(n) and I(n-1).
    tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

    % Compute T(n) * T(n-1) * ... * T(1)
    tforms(n).T = tforms(n).T * tforms(n-1).T;
end

imageSize = size(I);  % all the images are the same size

% Compute the output limits  for each transform
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

%Next, compute the average X limits for each transforms and 
%find the image that is in the center. Only the X limits are 
%used here because the scene is known to be horizontal. 
%If another set of images are used, both the X and
%Y limits may need to be used to find the center image.
avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);

%Finally, apply the center image's inverse transform to all the others.

Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = tforms(i).T * Tinv.T;
end


for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', I);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:numImages

    I = readimage(buildingScene, i);

    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);

    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end

figure
imshow(panorama)
% rawImg1 = imread(strcat(strcat(path,strcat(name,int2str(1),format))));
% rawImg2 = imread(strcat(strcat(path,strcat(name,int2str(2),format))));
% rawImg3 = imread(strcat(strcat(path,strcat(name,int2str(3),format))));    
% rawImg4 = imread(strcat(strcat(path,strcat(name,int2str(4),format))));
% rawImg5 = imread(strcat(strcat(path,strcat(name,int2str(5),format))));
% 
% [homography1to2 t1to2] = doHomography(rawImg1,rawImg2);
% [homography2to3 t2to3] = doHomography(rawImg2,rawImg3);
% %[homography3to4 t3to4] = doHomography(rawImg3,rawImg4);
% %[homography4to5 t4to5] = doHomography(rawImg4,rawImg5);
% 
% homography2to3.T = homography2to3.T * homography1to2.T;
% 
% 
% imageSize = size(rawImg1);
% 
% [xLim(1, :), yLim(1, :)] = outputLimits(homography1to3, [1 imageSize(2)], [1 imageSize(1)]);
% [xLim(2, :), yLim(2, :)] = outputLimits(homography2to3, [1 imageSize(2)], [1 imageSize(1)]);
% [xLim(3, :), yLim(3, :)] = outputLimits(homography4to3, [1 imageSize(2)], [1 imageSize(1)]);
% [xLim(4, :), yLim(4, :)] = outputLimits(homography5to3, [1 imageSize(2)], [1 imageSize(1)]);
% 
% % Find the minimum and maximum output limits
% xMin = min([1; xLim(:)]);
% xMax = max([imageSize(2); xLim(:)]);
% 
% yMin = min([1; yLim(:)]);
% yMax = max([imageSize(1); yLim(:)]);
% 
% width  = round(xMax - xMin)
% height = round(yMax - yMin)
% 
% transformedLeftImage = imwarp(im2single(rgb2gray(rawImg1)),homography1to2,'OutputView',imref2d(size(rawImg2)));
% 
% imshow(transformedLeftImage);

% %calculate k-Means clustering
% panorama = doPanorama(path, name, noOfImages, turns);
% 
% 
% 
% 
% transformedImages = [transformedImages transformedLeftImage];

%%%%%LATER
%%%For report: show with vl_plotframe

%subplot(1,2,1), imshow(imgLeft)
%subplot(1,2,2), imshow(imgRight)


%imshow(transformedImages);


% %show results
% subplot(1,2,1), imshow(color)
% subplot(1,2,2), imshow(spatial)

%random vs. pseudo random cluster
%falls weniger cluster als k ?
% Frage: fehler wegen sehr hohem k


