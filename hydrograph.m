% Final project for CS 020 (CS Fair) - by David Willian Berri (11/14/2014)
% Discrete convolution and composite hydrograph (Hydrology model)
% Input: Precipitation table
%        Unit Hydrograph table
% Output: Animation -> Graphs for each precipitation step
%                      Composite Hydrograph
clear all
close all
clc

choice = menu('Load from:','Spreadsheet','Data file','Simple text');

prompt = {'File Name:','Watershed Area:'};
response = inputdlg(prompt,'Infromation');
name = response{1};
area = str2double(response{2});

switch choice
    case 1
        data = xlsread(name);
    case 2
        data = load(name,'-mat');
    case 3
        data = load(name,'-ascii');
end

%% need to subtract the base flow
time = data(:,1);
tStep = time(2);
data = data(:,2)-13.31;
dataUH = data;
%%
% convert to hours
data = data*3600;

vol = integralNum(data,tStep);
sFac = (vol/area)*100;
UH = dataUH/sFac;

plot(time,UH)
hold on
% load some data about precipitation
P = xlsread('prec_data');

hyGrph = discrete(UH,P);

% Plot composite hydrograph
plot(time,hyGrph)

plot(time,(1.5*UH))
plot(time(3:end),(3*UH(2:(end-1))))
hold off