function [ ] = blobdetect(imgpath, sigma, scaleFactor, levels, thres )
%BLOBDETECT Summary of this function goes here
%   Detailed explanation goes here

I = imread(imgpath);
if size(I,3) == 3
    I = rgb2gray(I);
end
I = im2double(I);

scalespace = zeros(size(I,1), size(I,2), levels);

allSigmas = []; % saving all sigma sizes for later use in show_all_circles

for i = 1:levels
    % create filter for current pass
    currentFilterSize = 2*floor(3*sigma)+1;
    currentFilter = fspecial('log', currentFilterSize, sigma);
    
    % scale-normalisation of the filter (i.e. on values in filter)
    if i ~= 1
        currentFilter = currentFilter .* sigma^2;
    end
    
    % convolution
    scalespace(:,:,i) = imfilter(I, currentFilter, 'same', 'replicate');
    
    % save and update sigma
    allSigmas = cat(1, allSigmas, sigma);
    sigma = sigma * scaleFactor;
    
    %figure, imshow(scalespace(:,:,i)); %DEBUG
end

% convert to absolute values
scalespace = abs(scalespace);

% apply threshold
thresFlag = scalespace > thres;
scalespace = thresFlag .* scalespace;

% maxima detection
max = imregionalmax(scalespace);

circleRows = []; circleCols = []; circleRads = [];

for i=1:levels
    [row, col] = find(max(:,:,i)); % find all ones in logical img
    circleRows = cat(1, circleRows, row); % add maxima rows to row coordinate vector
    circleCols = cat(1, circleCols, col); % add maxima cols to col coordinate vector
    circleRads = cat(1, circleRads, repmat(allSigmas(i) * 2^(1/2), length(col), 1));
end

figure, show_all_circles(I, circleCols, circleRows, circleRads);

% Report dingsi
keypointIndex = 51;
keypoint = [circleRows(keypointIndex), circleCols(keypointIndex)];
bla = scalespace(keypoint(1), keypoint(2), :);
bla = squeeze(bla);
figure, plot(1:levels, bla);
title(imgpath);

end

