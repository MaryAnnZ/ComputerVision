function [result3D, result5D] = doKMeans(img, k, debug, random)
% Do k-Means clustering
% img   --> normalized input image with double values (0-1)
% k     --> numbers of clusters
% debug --> show initial cluster centroids and clustering progress

% result3D  --> use color information only
% result5D  --> additionally to color, use spatial information

%calculate default centroids
x=size(img, 2);
y=size(img, 1);
centroids = zeros(2, k);

if (random)
    % %%Code for random cluster points
    for i=1:size(centroids, 2)
        centroids(1, i) = randi([4, x-4]);
        centroids(2, i) = randi([4, y-4]);
    end
else
    %%Code for pseudo random points
    %%Set horizontal clusters, fixed distance
    if (x >= y) % horizontal
        centroidsX = round(x/(k+1));
        centroidsY = round(y/2);
        for i=1:size(centroids, 2)
            centroids(1, i) = centroidsX * i;
            centroids(2, i) = centroidsY;
        end
    else %vertical
        centroidsY = round(y/(k+1));
        centroidsX = round(x/2);
        for i=1:size(centroids, 2)
            centroids(1, i) = centroidsX;
            centroids(2, i) = centroidsY * i;
        end
    end
end



%% Initialise classification matrix with default cluster position
%% classification --> values from 1..k, indicate class of current pixel
%% Assign all data points to their nearest cluster centroids
%% Initial sum of the squares of the distances as metric
classificationColor = zeros(y, x);
maximumDist = sqrt(power(x, 2) + power(y, 2));

for i=1:x
    for j=1:y
        classificationColor(j,i) = maximumDist;
        class = -1;
        for m=1:size(centroids, 2)
            %calculate distance value from current pixel to current
            %cluster centroid
            xVal = i-centroids(1, m);
            yVal = j-centroids(2, m);
            xQuad = power(xVal, 2);
            yQuad = power(yVal, 2);
            distance = sqrt( xQuad + yQuad);
            if distance < classificationColor(j,i)
                classificationColor(j, i) = distance;
                class = m;
            end
        end
        classificationColor(j, i) = class;
    end
end

% dataPointColor = R,G,B, number of pixels in class
% dataPointSpatial = R,G,B, x and y coordinate, numbers of pixel in class
% clustermittelpunkte 3D/5D
dataPointColor = zeros(4, k);
dataPointSpatial = zeros(6, k);

%error (sum of distances) per cluster 3D/5D
oldErrorColor = zeros(1, k);
errorColor = oldErrorColor;

oldErrorSpatial = zeros(1, k);
errorSpatial = oldErrorSpatial;

%helper variable for classification 3D/5D
oldClassificationColor = zeros(y, x);
oldClassificationSpatial = zeros(y, x);

classificationSpatial = classificationColor;

%%variables for loop termination
th = 0.1;
loopsLeft = 0;
loopCounter = 100;

spatialColorThresholdReached = false;
colorThresholdReached = false;

while (~spatialColorThresholdReached && ~colorThresholdReached)
    loopsLeft = loopsLeft +1;
    
    %errorberechnung
    oldErrorColor = errorColor;
    oldClassification = classificationColor;
    dataPointColor = zeros(4, k); %RGB werte und anzahl einträge in klasse
    errorColor = zeros(1, k);
    
    % the same for 5D
    oldErrorSpatial = errorSpatial;
    oldclassificationSpatial = classificationSpatial;
    dataPointSpatial = zeros(6, k);
    errorSpatial = zeros(1, k);
    
    %assigned to that cluster
    for i=1:x
        for j=1:y
            %%add original color/position per pixel depending on classification
            dataPointColor(1, classificationColor(j, i)) = dataPointColor(1, classificationColor(j, i)) + img(j, i, 1);
            dataPointColor(2, classificationColor(j, i)) = dataPointColor(2, classificationColor(j, i)) + img(j, i, 2);
            dataPointColor(3, classificationColor(j, i)) = dataPointColor(3, classificationColor(j, i)) + img(j, i, 3);
            dataPointColor(4, classificationColor(j, i)) = dataPointColor(4, classificationColor(j, i)) + 1;
            
            %normalize the spatial positions!
            dataPointSpatial(1, classificationSpatial(j, i)) = dataPointSpatial(1, classificationSpatial(j, i)) + img(j, i, 1);
            dataPointSpatial(2, classificationSpatial(j, i)) = dataPointSpatial(2, classificationSpatial(j, i)) + img(j, i, 2);
            dataPointSpatial(3, classificationSpatial(j, i)) = dataPointSpatial(3, classificationSpatial(j, i)) + img(j, i, 3);
            dataPointSpatial(4, classificationSpatial(j, i)) = dataPointSpatial(4, classificationSpatial(j, i)) + i/x;
            dataPointSpatial(5, classificationSpatial(j, i)) = dataPointSpatial(5, classificationSpatial(j, i)) + j/y;
            dataPointSpatial(6, classificationSpatial(j, i)) = dataPointSpatial(6, classificationSpatial(j, i)) + 1;
        end
    end
    
    %Assign to new Clusters as the mean of all data points
    for i=1:k
        %4. entry is average color
        dataPointColor(1, i) = (dataPointColor(1, i) / dataPointColor(4, i));
        dataPointColor(2, i) = (dataPointColor(2, i) / dataPointColor(4, i));
        dataPointColor(3, i) = (dataPointColor(3, i) / dataPointColor(4, i));
        
        %4. entry is average position
        dataPointSpatial(1, i) = (dataPointSpatial(1, i) / dataPointSpatial(6, i));
        dataPointSpatial(2, i) = (dataPointSpatial(2, i) / dataPointSpatial(6, i));
        dataPointSpatial(3, i) = (dataPointSpatial(3, i) / dataPointSpatial(6, i));
        dataPointSpatial(4, i) = (dataPointSpatial(4, i) / dataPointSpatial(6, i));
        dataPointSpatial(5, i) = (dataPointSpatial(5, i) / dataPointSpatial(6, i));
    end
    
    
    
    %reclassification: calculated for every pixel new nearest class
    debugCount=0;
    for i=1:x
        for j=1:y
            classColor = -1;
            classSpatial = -1;
            debugCount = debugCount+1;
            
            currentDistColor = -1;
            currentDistSpatial = -1;
            for m=1:size(dataPointColor, 2)
                xDist = power((img(j, i, 1) - dataPointColor(1, m)), 2);
                yDist = power((img(j, i, 2) - dataPointColor(2, m)), 2);
                zDist = power((img(j, i, 3) - dataPointColor(3, m)), 2);
                dist = sqrt(xDist+yDist+zDist);
                if classColor == -1
                    classColor = m;
                    currentDistColor = dist;
                else
                    if dist<currentDistColor
                        currentDistColor = dist;
                        classColor = m;
                    end
                end
                
                xDistSpatialColor = power((img(j, i, 1) - dataPointSpatial(1, m)), 2);
                yDistSpatialColor = power((img(j, i, 2) - dataPointSpatial(2, m)), 2);
                zDistSpatialColor = power((img(j, i, 3) - dataPointSpatial(3, m)), 2);
                %normalize the position!
                uDistSpatialColor = power(((i/x) - dataPointSpatial(4, m)), 2);
                vDistSpatialColor = power(((j/y) - dataPointSpatial(5, m)), 2);
                distSpatialColor = sqrt(xDistSpatialColor+yDistSpatialColor+zDistSpatialColor+uDistSpatialColor+vDistSpatialColor);
                if classSpatial == -1
                    classSpatial = m;
                    currentDistSpatial = distSpatialColor;
                else
                    if distSpatialColor<currentDistSpatial
                        currentDistSpatial = distSpatialColor;
                        classSpatial = m;
                    end
                end
                
                
            end
            classificationColor(j, i) = classColor;
            classificationSpatial(j, i) = classSpatial;
            
            %%Debug output -- show classification progress
            if (debug && mod(debugCount,20000)==0)
                imshow(mat2gray(classificationColor));
            end
            
            %%add calculated distance of pixel to cluster centroid to
            %%average distance for error calculation
            errorColor(1, classColor) = errorColor(1, classColor) + currentDistColor;
            errorSpatial(1, classSpatial) = errorSpatial(1, classSpatial) + currentDistSpatial;
        end
    end
    
    
    %Compute the ratio between the old and the new J.
    %If the ratio lies under a given threshold
    if (loopsLeft>1)
        JColor = 1-(sum(errorColor)/sum(oldErrorColor));
        if (JColor < th)
            % the error is small enough, end loop
            disp('Threshold reached with 3D data points');
            colorThresholdReached = true;
        end
        JSpatial = 1- (sum(errorSpatial)/sum(oldErrorSpatial));
        if (JSpatial < th)
            % the error is small enough, end loop
            disp('Threshold with 5D data points');
            spatialColorThresholdReached = true;
        end
    end
    
    if (loopsLeft>loopCounter)
        % loop limit is reached, end loop
        disp('Counter timed out');
        break;
    end
end

%color the image
output3D = zeros(size(img));
output5D = zeros(size(img));
for i=1:x
    for j=1:y
        output3D(j, i, 1) = dataPointColor(1, classificationColor(j, i));
        output3D(j, i, 2) = dataPointColor(2, classificationColor(j, i));
        output3D(j, i, 3) = dataPointColor(3, classificationColor(j, i));
        
        output5D(j, i, 1) = dataPointSpatial(1, classificationSpatial(j, i));
        output5D(j, i, 2) = dataPointSpatial(2, classificationSpatial(j, i));
        output5D(j, i, 3) = dataPointSpatial(3, classificationSpatial(j, i));
    end
end

if (debug)
    %draw initial centroid
    for i=1:size(centroids, 2)
        output3D(centroids(2, i)-3:1:centroids(2, i)+3,centroids(1, i)-3:1:centroids(1, i)+3,1:3)= 1;
        output5D(centroids(2, i)-3:1:centroids(2, i)+3,centroids(1, i)-3:1:centroids(1, i)+3,1:3)= 1;
    end
end

result5D = output5D;
result3D = output3D;
end






