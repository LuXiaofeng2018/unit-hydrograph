function vol = integralNum(data,tStep)
% Usage: vol = integralNum(data,tStep)
% Purpose: Compute the total volume of a storm flow using numerical
% integration (Trapezoidal Rule)
% INargs: data = storm flow data points
%         tStep = time step
% OUTargs: vol = volume of storm flow

vol = 0;
for k = 2:length(data)
    vol = vol + (tStep/2)*(data(k)+data(k-1));
end