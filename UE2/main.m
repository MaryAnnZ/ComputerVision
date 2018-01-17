%read input image
path = 'input/';
name = 'campus';
format = '.jpg';


rawImg1 = imread(strcat(strcat(path,strcat(name,int2str(1),format))));
rawImg2 = imread(strcat(strcat(path,strcat(name,int2str(2),format))));
rawImg3 = imread(strcat(strcat(path,strcat(name,int2str(3),format))));    
rawImg4 = imread(strcat(strcat(path,strcat(name,int2str(4),format))));
rawImg5 = imread(strcat(strcat(path,strcat(name,int2str(5),format))));

[homography1to2 t1to2] = doHomography(rawImg1,rawImg2);
[homography2to3 t2to3]= doHomography(rawImg2,rawImg3);
[homography4to3 t4to3]= doHomography(rawImg4,rawImg3);
[homography5to4 t5to4]= doHomography(rawImg5,rawImg4);

homography1to3 = homography2to3.T * homography1to2.T;
homography5to3 = homography4to3.T * homography5to4.T;

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


