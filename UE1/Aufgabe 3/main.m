% TODO
function [sigma, k, levels] blobdetection

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

scalespace = zeros(height, width, levels); 

% todo Frage: scalespace interpolieren zwischen den Scales): index mal
% scale + aufrunden

end