%TODO
%
%
% Funktion schreiben (mehrere k-s einsetzen >=  2, inputbild, th)
% 
% 3D/5D Merkmale berechnen
% und normalisieren
% 
% Platzieren von k Centroids (pseudorandom Methode)
% Pixel zuteilen (Räumliche Distanz)

% Ab hier alles doppelt machen wegen 3D und 5D
% arry von olvarianz (k)
% array newVarianz (k)
% 
% Schleife (weniger als 100)
%     Scleife jede Klasse
%         Durchschnitt von Merkmalen jeder Klasse berechnen -> neue Centorids
%         end
%     array TmpVar (Cluster lang)
%     Schleife jede Pixel    
%         Pixel zuteilen (kleinste Differenz zwischen des Merkmales und Centroid)
%         tmpVar.push_back(currVar)
%         end
%      newVarianz updaten (alle Values von tmpVar/Länge)   
%      currentVarianz zusammenrechnen   
%     terminieren wenn Änderung zwischen oldVarianz und newVarianz < th
%     end
%     
%     
% Bild schoen einfärben (nach centroid)

img = imread('input/mm_small.jpg');
img = im2double(img);
img(:,:,1) = mat2gray(img(:,:,1));
img(:,:,2) = mat2gray(img(:,:,2));
img(:,:,3) = mat2gray(img(:,:,3));

imshow(img)

k = 10;

%get default centroids
%Choose random starting values for the centroids
x=size(img, 2);
y=size(img, 1);
centroids = zeros(2, k);

% for i=1:size(centroids, 2)
%         centroids(1, i) = randi([1, x]);
%         centroids(2, i) = randi([1, y]);
% end

%centroids


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

classification = zeros(y, x);
maximumDist = sqrt(power(x, 2) + power(y, 2));

for i=1:size(classification, 2)
   for j=1:size(classification, 1)
     classification(j,i) = maximumDist;
     class = -1;
     for m=1:size(centroids, 2)
       xVal = i-centroids(1, m);
       yVal = j-centroids(2, m);
       xQuad = power(xVal, 2);
       yQuad = power(yVal, 2);
       distance = sqrt( xQuad + yQuad);
       if distance < classification(j,i)
           classification(j, i) = distance;
           class = m;
       end
     end
     classification(j, i) = class;
   end
end

% R
% G
% B
% # pixel
% clustermittelpunkte 3D/5D
colorCentroids = zeros(4, k);
spatialColorCentroids = zeros(6, k);

%error für jeden cluster? 3D/5D
errorColor = zeros(1, k);
errorSpatialColor = zeros(1, k);

oldErrorColor = zeros(1, k);
oldErrorSpatialColor = zeros(1, k);
oldClassification = zeros(y, x);
oldClassificationSpatialColor = zeros(y, x);
classificationSpatialColor = classification;
th = 0.1;
count = 0;
loopCounter = 10;

spatialColor = true;
color = true;

while (spatialColor || color)
    count = count +1;
    %errorberechnung
    oldErrorColor = errorColor;
    oldClassification = classification;
    colorCentroids = zeros(4, k); %RGB werte und anzahl einträge in klasse
    errorColor = zeros(1, k);
    
    % the same for 5D
    oldErrorSpatialColor = errorSpatialColor;
    oldClassificationSpatialColor = classificationSpatialColor;
    spatialColorCentroids = zeros(6, k);
    errorSpatialColor = zeros(1, k);
    
    %find new centroids
    %classification and classificationSpatialColor are the same so the same
    %indexing can be used
    for i=1:size(classification, 2)
       for j=1:size(classification, 1)
           %iteration durch alle klassen
           %classification= pixelweise, welcher pixel zu welcher klasse
           colorCentroids(1, classification(j, i)) = colorCentroids(1, classification(j, i)) + img(j, i, 1);
           colorCentroids(2, classification(j, i)) = colorCentroids(2, classification(j, i)) + img(j, i, 2);
           colorCentroids(3, classification(j, i)) = colorCentroids(3, classification(j, i)) + img(j, i, 3);
           colorCentroids(4, classification(j, i)) = colorCentroids(4, classification(j, i)) + 1;
       
           spatialColorCentroids(1, classificationSpatialColor(j, i)) = spatialColorCentroids(1, classificationSpatialColor(j, i)) + img(j, i, 1);
           spatialColorCentroids(2, classificationSpatialColor(j, i)) = spatialColorCentroids(2, classificationSpatialColor(j, i)) + img(j, i, 2);
           spatialColorCentroids(3, classificationSpatialColor(j, i)) = spatialColorCentroids(3, classificationSpatialColor(j, i)) + img(j, i, 3);
           spatialColorCentroids(4, classificationSpatialColor(j, i)) = spatialColorCentroids(4, classificationSpatialColor(j, i)) + i/x;
           spatialColorCentroids(5, classificationSpatialColor(j, i)) = spatialColorCentroids(5, classificationSpatialColor(j, i)) + j/y;
           spatialColorCentroids(6, classificationSpatialColor(j, i)) = spatialColorCentroids(6, classificationSpatialColor(j, i)) + 1;
       end
    end
    
    
    %these are the new centroids
    for i=1:size(colorCentroids, 2)
        %mit dem vierten glied dividieren (durchschnittsfarbe/position
        %berechnen)
       colorCentroids(1, i) = (colorCentroids(1, i) / colorCentroids(4, i));
       colorCentroids(2, i) = (colorCentroids(2, i) / colorCentroids(4, i));
       colorCentroids(3, i) = (colorCentroids(3, i) / colorCentroids(4, i));
       
       spatialColorCentroids(1, i) = (spatialColorCentroids(1, i) / spatialColorCentroids(6, i));
       spatialColorCentroids(2, i) = (spatialColorCentroids(2, i) / spatialColorCentroids(6, i));
       spatialColorCentroids(3, i) = (spatialColorCentroids(3, i) / spatialColorCentroids(6, i));
       spatialColorCentroids(4, i) = (spatialColorCentroids(4, i) / spatialColorCentroids(6, i));
       spatialColorCentroids(5, i) = (spatialColorCentroids(5, i) / spatialColorCentroids(6, i));
    end
    
    
    
%reclassification
asdasd=0;
    for i=1:size(img, 2)
        for j=1:size(img, 1)
            asdasd=asdasd+1;
            class = -1;
            classSpatialColor = -1;
            currentDist = -1;
            currentDistSpatialColor = -1;
            for m=1:size(colorCentroids, 2)
                xDist = power((img(j, i, 1) - colorCentroids(1, m)), 2);
                yDist = power((img(j, i, 2) - colorCentroids(2, m)), 2);
                zDist = power((img(j, i, 3) - colorCentroids(3, m)), 2);
                dist = sqrt(xDist+yDist+zDist);
                if class == -1
                    class = m;
                    currentDist = dist;
                else
                   if dist<currentDist
                      currentDist = dist;
                      class = m;
                   end
                end
                
                xDistSpatialColor = power((img(j, i, 1) - spatialColorCentroids(1, m)), 2);
                yDistSpatialColor = power((img(j, i, 2) - spatialColorCentroids(2, m)), 2);
                zDistSpatialColor = power((img(j, i, 3) - spatialColorCentroids(3, m)), 2);
                uDistSpatialColor = power((i - spatialColorCentroids(4, m)), 2);
                vDistSpatialColor = power((j - spatialColorCentroids(5, m)), 2);
                distSpatialColor = sqrt(xDistSpatialColor+yDistSpatialColor+zDistSpatialColor+uDistSpatialColor+vDistSpatialColor);
                if classSpatialColor == -1
                    classSpatialColor = m;
                    currentDistSpatialColor = distSpatialColor;
                else
                   if distSpatialColor<currentDistSpatialColor
                      currentDistSpatialColor = distSpatialColor;
                      classSpatialColor = m;
                   end
                end
                
                
            end
            classification(j, i) = class;      
            
           
            if (mod(asdasd,20000)==0)
                 imshow(mat2gray(classification));
                asdasd = asdasd;
            end
            
            
            classificationSpatialColor(j, i) = classSpatialColor;
            errorColor(1, class) = errorColor(1, class) + currentDist;
            errorSpatialColor(1, classSpatialColor) = errorSpatialColor(1, classSpatialColor) + currentDistSpatialColor;
        end
    end
%     testImg = zeros(size(img));
% for i=1:size(img, 2)
%    for j=1:size(img, 1) 
%       testImg(j, i, 1) = colorCentroids(1, classification(j, i));
%       testImg(j, i, 2) = colorCentroids(2, classification(j, i));
%       testImg(j, i, 3) = colorCentroids(3, classification(j, i));
%    end
% end
% 
% figure, imshow(testImg);
%check error
%     if (sum(oldErrorColor)-sum(errorColor) <= 0) % there is no convergence
%        classification = oldClassification;
%        disp('the error gets bigger');
%        break;
%     end
    if (sum(errorColor)/size(errorColor, 2) < th) % the error is small enough
        disp('Threshold reached color');
        color = false;
    end
    if (sum(errorSpatialColor)/size(errorSpatialColor, 2) < th) % the error is small enough
        disp('Threshold reached spatial color');
        spatialColor = false;
    end
    if (count>loopCounter) % there is no more time for it
        disp('Counter timed out');
       break; 
    end
end

%color the image
testImg = zeros(size(img));
for i=1:x
   for j=1:y
      testImg(j, i, 1) = colorCentroids(1, classification(j, i));
      testImg(j, i, 2) = colorCentroids(2, classification(j, i));
      testImg(j, i, 3) = colorCentroids(3, classification(j, i));
   end
end

testImgSpatialColor = zeros(size(img));
for i=1:size(img, 2)
   for j=1:size(img, 1) 
      testImgSpatialColor(j, i, 1) = spatialColorCentroids(1, classificationSpatialColor(j, i));
      testImgSpatialColor(j, i, 2) = spatialColorCentroids(2, classificationSpatialColor(j, i));
      testImgSpatialColor(j, i, 3) = spatialColorCentroids(3, classificationSpatialColor(j, i));
   end
end

figure, imshow(testImg);
figure, imshow(testImgSpatialColor);

% 
%            if count == 1
%            if i==1
%               if j == 1
%               colorCentroids(1, classification(j, i)) = colorCentroids(1, classification(j, i)) + img(j, i, 1)
%            colorCentroids(2, classification(j, i)) = colorCentroids(2, classification(j, i)) + img(j, i, 2)
%            colorCentroids(3, classification(j, i)) = colorCentroids(3, classification(j, i)) + img(j, i, 3)
%            colorCentroids(4, classification(j, i)) = colorCentroids(4, classification(j, i)) + 1
%        
%               end 
%            end
%            end