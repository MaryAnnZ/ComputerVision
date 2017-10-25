% TODO
% % 1a
% erstelle scale space (levels tief)
% erstelle LoG filter (fspecial) mit currentSigma
% 
% % 1b
% Schleife (über #levels in scale space) 
%     conv image with filter
%     save LoG response
%     update LoG filter
%     scale picture
% end
% 
% %2
% suche in der 8er Neighborhood + oben + unten

% values recommended by Angabe
sigma = 2;
k = 1.25; %aka scale
levels = 10;
I1 = imread('input/butterfly.jpg');
I2 = imread('input/ownimg.jpg');

scalespace1 = zeros(size(I1,1), size(I1,2), levels);
scalespace2 = zeros(size(I2,1), size(I2,2), levels);

for i = 1:10
    i
end



% todo Frage: scalespace interpolieren zwischen den Scales): index mal
% scale + aufrunden

