close all

I1 = im2double(imread('input/butterfly.jpg'));
I2 = im2double(rgb2gray(imread('input/ownimg.jpg')));
thres = 0.15;
% values recommended by Angabe
sigma = 2;
k = 1.25; %aka scale
levels = 10;

scalespace1 = zeros(size(I1,1), size(I1,2), levels);
scalespace2 = zeros(size(I2,1), size(I2,2), levels);

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
    scalespace1(:,:,i) = imfilter(I1, currentFilter, 'same', 'replicate');
    scalespace2(:,:,i) = imfilter(I2, currentFilter, 'same', 'replicate');
    
    % save and update sigma
    allSigmas = cat(1, allSigmas, sigma);
    sigma = sigma * k;
    
    %figure, imshow(scalespace1(:,:,i));
    %figure, imshow(scalespace2(:,:,i));
end

% convert to absolute values
scalespace1 = abs(scalespace1);
scalespace2 = abs(scalespace2);

% apply threshold
thresFlag1 = scalespace1 > thres;
thresFlag2 = scalespace2 > thres;
scalespace1 = thresFlag1 .* scalespace1;
scalespace2 = thresFlag2 .* scalespace2;

% maxima detection
max1 = imregionalmax(scalespace1);
max2 = imregionalmax(scalespace2);

circleRows1 = []; circleCols1 = []; circleRads1 = [];
circleRows2 = []; circleCols2 = []; circleRads2 = [];

for i=1:levels
    [row1, col1] = find(max1(:,:,i)); % find all ones in logical img
    circleRows1 = cat(1, circleRows1, row1); % add maxima rows to row coordinate vector
    circleCols1 = cat(1, circleCols1, col1); % add maxima cols to col coordinate vector
    circleRads1 = cat(1, circleRads1, repmat(allSigmas(i) * 2^(1/2), length(col1), 1));

    [row2, col2] = find(max2(:,:,i)); % find all ones in logical img
    circleRows2 = cat(1, circleRows2, row2); % add maxima rows to row coordinate vector
    circleCols2 = cat(1, circleCols2, col2); % add maxima cols to col coordinate vector
    circleRads2 = cat(1, circleRads2, repmat(allSigmas(i) * 2^(1/2), length(col2), 1));
end

show_all_circles(I1, circleCols1, circleRows1, circleRads1);
%show_all_circles(I2, circleCols2, circleRows2, circleRads2);
