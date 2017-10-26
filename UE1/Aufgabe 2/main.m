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

img = imread('input/future.jpg');
img = im2double(img);

k = 5;

%get default centroids
x=size(img, 2);
y=size(img, 1);
centroids = zeros(2, k);

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
centroids
classification = zeros(size(img, 1), size(img, 2));
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
colorCentroids = zeros(4, k);
errorColor = zeros(1, k);
oldErrorColor = zeros(1, k);
oldClassification = zeros(size(img, 1), size(img, 2));
th = 0.1;
count = 0;
loopCounter = 100;

while (true)
    count = count +1;
    oldErrorColor = errorColor;
    oldClassification = classification;
    colorCentroids = zeros(4, k);
    errorColor = zeros(1, k);
%find new centroids
    for i=1:size(classification, 2)
       for j=1:size(classification, 1)
           colorCentroids(1, classification(j, i)) = colorCentroids(1, classification(j, i)) + img(j, i, 1);
           colorCentroids(2, classification(j, i)) = colorCentroids(2, classification(j, i)) + img(j, i, 2);
           colorCentroids(3, classification(j, i)) = colorCentroids(3, classification(j, i)) + img(j, i, 3);
           colorCentroids(4, classification(j, i)) = colorCentroids(4, classification(j, i)) + 1;
       end
    end
    %these are the new centroids
    for i=1:size(colorCentroids, 2)
       colorCentroids(1, i) = round(colorCentroids(1, i) / colorCentroids(4, i));
       colorCentroids(2, i) = round(colorCentroids(2, i) / colorCentroids(4, i));
       colorCentroids(3, i) = round(colorCentroids(3, i) / colorCentroids(4, i));
    end
%reclassification
    for i=1:size(img, 2)
        for j=1:size(img, 1)
            class = -1;
            currentDist = -1;
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
            end
            classification(j, i) = class;
            errorColor(1, class) = errorColor(1, class) + currentDist;
        end
    end
    testImg = zeros(size(img));
% for i=1:size(img, 2)
%    for j=1:size(img, 1) 
%       testImg(j, i, 1) = colorCentroids(1, classification(j, i));
%       testImg(j, i, 2) = colorCentroids(2, classification(j, i));
%       testImg(j, i, 3) = colorCentroids(3, classification(j, i));
%    end
% end

% figure, imshow(testImg);
%check error
%     if (sum(oldErrorColor)-sum(errorColor) <= 0) % there is no convergence
%        classification = oldClassification;
%        disp('the error gets bigger');
%        break;
%     end
    if (sum(errorColor)/size(errorColor, 2) < th) % the error is small enough
        disp('Threshold reached');
        break;
    end
    if (count>loopCounter) % there is no more time for it
        disp('Counter timed out');
       break; 
    end
end

%color the image
testImg = zeros(size(img));
for i=1:size(img, 2)
   for j=1:size(img, 1) 
      testImg(j, i, 1) = colorCentroids(1, classification(j, i));
      testImg(j, i, 2) = colorCentroids(2, classification(j, i));
      testImg(j, i, 3) = colorCentroids(3, classification(j, i));
   end
end

imshow(testImg);

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