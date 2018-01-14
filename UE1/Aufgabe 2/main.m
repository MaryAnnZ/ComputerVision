%read input image
img = imread('input/future.jpg');
img = im2double(img);
img(:,:,1) = mat2gray(img(:,:,1));
img(:,:,2) = mat2gray(img(:,:,2));
img(:,:,3) = mat2gray(img(:,:,3));

imshow(img)

k = 4; %must be >1
debug = 0; % 0 or 1
random = 0;

%calculate k-Means clustering
[color, spatial] = doKMeans(img, k, debug, random);

%show results
subplot(1,2,1), imshow(color)
subplot(1,2,2), imshow(spatial)

%random vs. pseudo random cluster
%falls weniger cluster als k ?
% Frage: fehler wegen sehr hohem k


