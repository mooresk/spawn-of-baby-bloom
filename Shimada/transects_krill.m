%% plot transects of mean NASC and matched IFCB samples along each transect
% data options: NASC
% option to plot scatter plot or heatmap (and change resolution)
% option to plot diatom biovolume
% Shimada 2019, 2021, & 2023
%
close; 
clear;

%%%%USER
fprint = 0; % 1 = print; 0 = don't
yr = 2019; % 2019; 2021; 2023
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\';

% load in data
addpath(genpath(filepath)); % add new data to search path
load([filepath 'Shimada\Data\summary_19-23Hake_biovolume.mat'],'PB'); %IFCB data
load([filepath 'Shimada\Data\coast_CCS.mat'],'coast'); %map
states=load([filepath 'Shimada\Data\USwestcoast_pol.mat']); %map

%remove IFCB data that does not have matching NASC value
PB(isnan(PB.avNASC),:)=[];

PB(~(PB.DT.Year==yr),:)=[]; %select year of data

figure
plot(PB.coast_km,(PB.unclassified + PB.Akashiwo + PB.Alexandrium_catenella + PB.Asterionellopsis + PB.Cera_Dact_Deto_Guin + PB.Chaetoceros + PB.Cylindrotheca + ...
    PB.Dictyocha + PB.Dinophysis + PB.Eucampia + PB.Gymnodinium + PB.Hete_Scri + PB.Katodinium + PB.Lauderia + PB.Leptocylindrus + PB.Navicula + PB.Nitzschia + ...
    PB.Prob_Rhiz + PB.Skeletonema + PB.Thalassiosira + PB.Pseudonitzschia),'.g'); hold on;

plot(PB.coast_km,PB.avNASC,'xr'); hold on;