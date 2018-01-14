%read input image
path = 'input/';
name = 'campus';
noOfImages = 5;

turns = 1;

%calculate k-Means clustering
panorama = doPanorama(path, name, noOfImages, turns);

%show results
subplot(1,2,1), imshow(color)
subplot(1,2,2), imshow(spatial)

%random vs. pseudo random cluster
%falls weniger cluster als k ?
% Frage: fehler wegen sehr hohem k


