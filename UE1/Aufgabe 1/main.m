% Read input data
name  = '01112v';
r = '_R.jpg';
g = '_G.jpg';
b = '_B.jpg';
path = 'input/';

red =  imread(strcat(strcat(path,name),r));

original = uint8(zeros(size(red,1), size(red,2), 3));
original(:,:,1) = red;
original(:,:,2) = imread(strcat(strcat(path,name),g));
original(:,:,3) = imread(strcat(strcat(path,name),b));

figure, imshow(original);

result =  uint8(zeros(size(red,1), size(red,2), 3));
result(:,:,1) = red;

highestResultBlue = 0;
highestResultGreen = 0;

%compare red with blue and red with green in a [-15 15] circular shift
%window
for i = -15:1:15
    for j = -15:1:15
        shiftedGreen = circshift(original(:,:,2),[i j]);
        shiftedBlue = circshift(original(:,:,3),[i j]);
        
        % calculated similarity between red and other channels
        similarityGreen = corr2(red, shiftedGreen);
        similarityBlue = corr2(red, shiftedBlue);
        
        %save best match!
        if (similarityGreen>highestResultGreen)
            highestResultGreen = similarityGreen;
            result(:,:,2) = shiftedGreen;
        end
        
        if (similarityBlue>highestResultBlue)
            highestResultBlue = similarityBlue;
            result(:,:,3) = shiftedBlue;
        end
    
    end
end

figure, imshow(result);
