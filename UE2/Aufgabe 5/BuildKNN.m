function [ training, group ] = BuildKNN( folder, C )
%BUILDKNN Summary of this function goes here
%   This time, we build a matrix with really densely SIFTed SIFT points
DEBUG = false;
disp('building KNN');

numClusters = size(C, 2); %we have this many clusters

% collect output data in here
training = [];
group = [];

foldercontents = dir(folder); %content of test/train folders, i.e. subfolders

% dir() returns . and .. as the first 2 entries, so we start at 3
for i=3:length(foldercontents)
    if foldercontents(i).isdir % only want the images in the subdirs
        disp(['current folder ', foldercontents(i).name]);
        setcontents = dir([folder, '/', foldercontents(i).name]);
        
        for file = 3:length(setcontents) % iterate over the pictures sorted by label, e.g. bedroom etc.
            imageLocation = [folder, '/', foldercontents(i).name, '/', setcontents(file).name];
            sift = doSIFT(imageLocation);
            
            % looks up, to which cluster in C (centroids of vocabulary) each
            % SIFT feature of this image belongs to
            indices = knnsearch(C', sift'); 
            indices = indices';
            
            hist = buildHist(indices, numClusters); %erstellt das Histogramm, darin befinden sich die indices der "Woerter"
            %normiern von den "bins" damit sie vergleichbar werden
            hist = normalise(hist);
            training = cat(1, training, hist);% pro zeile das histogramm der dSIFT zuordnungen anhand von C
            group = strvcat(group, foldercontents(i).name); % pro zeile das dazugehörige "class label"
            
            % break if DEBUG
            if file >= 4 && DEBUG == true
                break;
            end
        end
    end
end



end

% does dSIFT on ine image at a time
function [siftdata] = doSIFT(image)
    I = imread(image);
    % check if greyscale, if not convert to greyscale
    if size(I, 3) == 3
        I = rgb2gray(I);
    end
    % convert to single for dSIFT
    I = im2single(I);
        
    [frames, descr] = vl_dsift(I, 'Fast', 'Step', 2);
    
    siftdata = descr;
end

function [hist] = buildHist(x, range)
    hist = histc(x, 1:range);
end

function [normalised] = normalise(vec)
    normalised = (vec - min(vec)) / ( max(vec) - min(vec) );
end