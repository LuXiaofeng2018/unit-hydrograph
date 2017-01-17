function [timex, x, ind]  = unResp(UH,P,time)
% Usage: unResp(UH,P,time)
% Purpose: Compute and plot the unit response for each rain impulse
% INargs: UH = Unit Hydrograph data
%         P = Precipitation data
%         time = time data
% OUTargs: timex = max amount of time
disc = {};
tStep = time(2);
unRe = UH*P(1,2);
disc{1} = unRe;
plot(time,unRe)
pause(0.5)
hold on
for i = 2:length(P)
    unRe = UH*P(i,2);
    timex = time+(2*(i-1)*tStep);
    disc{i} = unRe;
    plot(timex,unRe)
    pause(0.5)
end
set(gca,'YGrid','on');
% Discrete Convolution
ind = length(unRe)+length(P)-1;
x = zeros(ind,1);
for s = 1:length(disc)
    a = disc{s};
    x(s:length(unRe)+s-1) = x(s:length(unRe)+s-1) + a;
end
end
