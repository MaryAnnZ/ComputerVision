%read input image
path = 'input/';
name = 'campus';
format = '.jpg';


rawImgLeft = imread(strcat(strcat(path,strcat(name,int2str(1),format))));
rawImgRight = imread(strcat(strcat(path,strcat(name,int2str(2),format))));
    

[first T] = doHomography(rawImgLeft,rawImgRight);

transformedLeftImage = imwarp(im2single(rgb2gray(rawImgLeft)),first,'OutputView',imref2d(size(rawImgRight)));

imshow(transformedLeftImage);

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


