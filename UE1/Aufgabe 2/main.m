%TODO
%
%
% Funktion schreiben (mehrere k-s einsetzen >=  2, inputbild, th)
% 
% 3D/5D Merkmale berechnen
% und normalisieren
% 
% Platzieren von k Centroids (pseudorandom Methode)
% Pixel zuteilen (R�umliche Distanz)

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
%      newVarianz updaten (alle Values von tmpVar/L�nge)   
%      currentVarianz zusammenrechnen   
%     terminieren wenn �nderung zwischen oldVarianz und newVarianz < th
%     end
%     
%     
% Bild schoen einf�rben (nach centroid)