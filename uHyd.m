function UH = uHyd(data,area,vol)
% Usage: UH = uHyd(data,area,vol)
% Purpose: Compute the unit hydrograph based on storm flow data
% INargs: data = storm flow data
%         area = area of the watershed
%         vol = volume of storm flow
% OUTargs: UH = Unit hydrograph data points

sFac = (vol/area)*100;
UH = data(:)/sFac;