close all

thres = 0.15;
% values recommended by Angabe
sigma = 2;
k = 1.25; %aka scale
levels = 10;

blobdetect('input/butterfly.jpg', sigma, k, levels, thres);
blobdetect('input/butterfly_halfsize.jpg', sigma, k, levels, thres);

blobdetect('input/ownimg.jpg', sigma, k, levels, thres);
blobdetect('input/ownimg_halfsize.jpg', sigma, k, levels, thres);
