function [ training, group ] = BuildKNN( folder, C )
%BUILDKNN Summary of this function goes here
%   This time, we build a matrix with really densely SIFTed SIFT points

disp('building KNN');

numClusters = size(C, 2);

% collect output data
training = [];
group = [];

foldercontents = dir(folder); %content of test/train folders, i.e. subfolders

% dir() returns . and .. as the first 2 entries, so we start at 3
for i=3:length(foldercontents)
    if foldercontents(i).isdir % only want the images in the subdirs
        disp(['current folder ', foldercontents(i).name]);
        setcontents = dir([folder, '/', foldercontents(i).name]);
        
        for file = 3:length(setcontents)
            imageLocation = [folder, '/', foldercontents(i).name, '/', setcontents(file).name];
            sift = doSIFT(imageLocation);
            
            indices = knnsearch(C', sift');
            indices = indices';
            
            hist = buildHist(indices, numClusters); %erstellt das Histogramm
            %normiern von den "bins" damit sie vergleichbar werden
            hist = normalise(hist);
            training = cat(1, training, hist);% pro zeile das histogramm der dSIFT zuordnungen anhand von C
            group = strvcat(group, foldercontents(i).name); % pro zeile das dazugehörige "class label"
                        
        end
    end
end



end

% does dSIFT on ine image at a time
function [siftdata] = doSIFT(image)
    I = imread(image);
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