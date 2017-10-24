% TODO
redTmp =  imread('input/01112v_R.jpg');

original = uint8(zeros(size(redTmp,1), size(redTmp,2), 3));
original(:,:,1) = redTmp;
original(:,:,2) = imread('input/01112v_G.jpg');
original(:,:,3) = imread('input/01112v_B.jpg');

imshow(original);
% zuerst circshift 

% resultimage = 0
% higestREsult = 0
% crop RED
% schleife: -15 till 15 (horizontal and veritcal)
% 1) cumpute circshiftIMG
% 2) crop BLUE
% 3) value = NCC (CropRed, cropBlue)
% 4) if value > highestREsult;
%    ---> higestReslut = value
%    ---> resultImage = cirshiftIMG
%

% same R and G

% merge resulting layers

