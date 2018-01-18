%Reference for codebasis for image stitching: 
%https://de.mathworks.com/help/vision/examples/feature-based-panoramic-image-stitching.html

% Load images.
buildingDir = fullfile(toolboxdir('vision'), 'visiondata', 'building');
buildingScene = imageDatastore('input/campus');

% Read the first image from the image set.
I = readimage(buildingScene, 1);
%initialize the image size
imageSize = size(I); 

% amount of images
numImages = numel(buildingScene.Files);
% homographies between the images
tforms(numImages) = projective2d(eye(3));
% predecessor image
refI = I;
% Iterate over image pairs
for n = 2:numImages
    % Read next image
    I = readimage(buildingScene, n);
    %update size if curren image is bigger
    if size(I, 1) > imageSize(1, 1)
        imageSize(1, 1) = size(I, 1);
    end
    if size(I, 2) > imageSize(1, 2)
        imageSize(1, 2) = size(I, 2);
    end
    if size(I, 3) > imageSize(1, 3)
        imageSize(1, 3) = size(I, 3);
    end
    % Estimate the transformation between current image and predecessor
    [tforms(n)] = doHomography(I, refI, false);
    % Compute the transformation between vurrent image and predecessor
    tforms(n).T = tforms(n).T * tforms(n-1).T;
    %update predecessor image
    if  n<numImages
        refI = I;
    end
end

% Compute the corners of every image after the tarnsformation
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

%pick the middle image as center for the panorama
avgXLim = mean(xlim, 2);
[~, idx] = sort(avgXLim);
centerIdx = floor((numel(tforms)+1)/2);
centerImageIdx = idx(centerIdx);

%apply the center image's inverse transform to all the others.
Tinv = invert(tforms(centerImageIdx));
%update the transformation according to the central image
for i = 1:numel(tforms)
    tforms(i).T = tforms(i).T * Tinv.T;
end

% Compute the corners of every image after the tarnsformation, to determine
% the size of the panorama
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
%with feathering
panorama = zeros([height width 3], 'like', I);
%without feathering
panoramaWithoutF = zeros([height width 3], 'like', I);

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

%container for all transformed images and its alpha maps
warpedImages = zeros(numImages, height, width, 3);
warpedAlphas = zeros(numImages, height, width);
% warp images + create panorama without blending
for i = 1:numImages
    %read original image
    I = readimage(buildingScene, i);
    %create alpha map
    alpha = zeros(size(I, 1), size(I, 2));
    %border is 1
    alpha(1, :) = 1;
    alpha(:, 1) = 1;
    alpha(size(alpha, 1), :) = 1;
    alpha(:, size(alpha, 2)) = 1;
    %Euclidean distance
    alpha = bwdist(alpha);
    %normalize
    alpha = (alpha - min(min(alpha)))/(max(max(alpha)) - min(min(alpha)));
    
    % transform the image and the alpha map
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
    warpedAlpha = imwarp(alpha, tforms(i), 'OutputView', panoramaView);
    %save image and the apha map
    warpedImages(i, :, :, :) = warpedImage;
    warpedAlphas(i, :, :) = warpedAlpha;
    
    % create panorama without feathering
    warpedImageWithoutF = warpedImage;
    for y = 1:size(panoramaWithoutF, 1)
       for x = 1:size(panoramaWithoutF, 2)
          %if the value in the panorama is already set, set this pixel in the image 0 
          if panoramaWithoutF(y, x, 1) > 0 | panoramaWithoutF(y, x, 2) > 0 | panoramaWithoutF(y, x, 3) > 0 
            warpedImageWithoutF(y, x, :) = 0;
          end
       end
    end
    panoramaWithoutF = panoramaWithoutF + warpedImageWithoutF;
end
%create panorama with alpha blending
 for y = 1:size(panorama, 1)
       for x = 1:size(panorama, 2)
           alphaSum = 0;
           r = 0;
           b = 0;
           g = 0;
           %get the RGB values and the alpha values of all transformed
           %images (sum (RGBi * alphai)/sum alphai)
           for i = 1:numImages
               alphaSum = alphaSum + warpedAlphas(i, y, x);
               r = r + (warpedImages(i, y, x, 1) * warpedAlphas(i, y, x));
               g = g + (warpedImages(i, y, x, 2) * warpedAlphas(i, y, x));
               b = b + (warpedImages(i, y, x, 3) * warpedAlphas(i, y, x));
           end
           r = r / alphaSum;
           g = g / alphaSum;
           b = b / alphaSum;
           panorama(y, x, 1) = r;
           panorama(y, x, 2) = g;
           panorama(y, x, 3) = b;
       end
 end


figure, imshow(panoramaWithoutF);
figure, imshow(panorama);
