%TODO
%
%
% D = x
%
% 1. Choose random starting values for the centroids c. (k-mal)
% 2. Assign all data points to their nearest cluster centroids
% 3. Compute the new cluster centroids as the mean of all data points 
%   assigned to that cluster:
% 4. Compute J and check for convergence. For this purpose, compute the ratio 
%   between the old and the new J. If the ratio lies under a given threshold, 
%   terminate the clustering, otherwise go to point 2.
%