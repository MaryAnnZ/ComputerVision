function [ C ] = BuildVocabulary( folder, num_clusters )
%BUILDVOCABULARY Summary of this function goes here
%   Detailed explanation goes here

disp('doing dSIFT');
% collects all SIFT data
allfeatures = [];

foldercontents = dir(folder); %content of test/train folders, i.e. subfolders

% dir() returns . and .. as the first 2 entries, so we start at 3
for i=3:length(foldercontents)
    if foldercontents(i).isdir % only want the images in the subdirs
        disp(['current folder ', foldercontents(i).name]);
        setcontents = dir([folder, '/', foldercontents(i).name]);
        
        for file = 3:length(setcontents)
            imageLocation = [folder, '/', foldercontents(i).name, '/', setcontents(file).name];
            allfeatures = cat(2, allfeatures, doSIFT(imageLocation));
        end
    end
end

% K-Means clustering
disp('doing Kmeans');
allfeatures = im2double(allfeatures);
[C, A] = vl_kmeans(allfeatures, num_clusters);

end

% does dSIFT on ine image at a time
function [siftdata] = doSIFT(image)
    %disp(['doing SIFT on ', image]);
    I = imread(image);
    
    % check if greyscale, if not convert to greyscale
    if size(I, 3) == 3
        I = rgb2gray(I);
    end
    % convert to single for vl_dsift use
    I = im2single(I);
    
    %determine a good step size
    Ilen = length(I);
    step = floor((Ilen/10)/2); % ist denke das ist eine akzeptable Heuristik für step-size
    
    % apply dSIFT with a wide step size and BE FAST
    [frames, descr] = vl_dsift(I, 'Step', step, 'Fast');
    
    % take 100 of the SIFT descriptors
    %siftdata = descr(:,1:100);
    siftdata = descr(:, randsample(size(descr, 2), 100));
end