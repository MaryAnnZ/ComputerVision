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
I2 = rgb2gray(imread('input/ownimg.jpg'));

scalespace1 = zeros(size(I1,1), size(I1,2), levels);
scalespace2 = zeros(size(I2,1), size(I2,2), levels);

for i = 1:levels
    % create filter for current pass
    currentFilterSize = 2*floor(3*sigma)+1;
    currentFilter = fspecial('log', currentFilterSize, sigma);
    
    % scale-normalisation of the filter (i.e. on values in filter)
    if i ~= 1
        currentFilter = currentFilter .* sigma^2;
    end
    
    % convolution
    scalespace1(:,:,i) = imfilter(I1, currentFilter, 'same', 'replicate');
    %scalespace2(:,:,i) = imfilter(I2, currentFilter, 'same', 'replicate');
    
    % update sigma
    sigma = sigma * k;
    
    figure, imshow(scalespace1(:,:,i));
end


% TODO Frage: scalespace interpolieren zwischen den Scales): index mal
% scale + aufrunden

