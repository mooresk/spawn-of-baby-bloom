%% scatter plots of mean NASC vs IFCB diatom:diatom+dino biomass along CCS
% Shimada 2019, 2021, & 2023
%
close; 
clear;

%%%%USER
fprint = 0; % 1 = print; 0 = don't
yr = 2019:2:2023; % 2019; 2021; 2023
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\';

% load in data
addpath(genpath(filepath)); % add new data to search path
load([filepath 'Shimada\Data\summary_19-23Hake_biovolume.mat'],'PB'); %IFCB data
load([filepath 'Shimada\Data\coast_CCS.mat'],'coast'); %map
states=load([filepath 'Shimada\Data\USwestcoast_pol.mat']); %map

%remove IFCB data that does not have matching NASC value
PB(isnan(PB.avNASC),:)=[];

%% Plot NASC & IFCB diatom:diatom+dinoflagellate biomass
fig=figure; 

diat_diatDino=log10((PB.diatom+1./(PB.diatom+PB.dino+1)));

colors = 'gyr';
for idx=1:length(yr)
    ff=find(PB.DT.Year==yr(idx));
    if ff
        scatter(diat_diatDino(ff),PB.avNASC(ff),10,'o','filled','MarkerEdgeColor','k','MarkerFaceColor',colors(idx));  hold on;
    end
end
xlabel('log10 (diatom : diatom+dinoflagellate)') 
ylabel('mean NASC') 
