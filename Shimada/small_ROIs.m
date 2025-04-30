%% calculate biomass of small ROIs <10 um by class 
% used to evaluate effect of removing small ROIs to try and standardize data 
% collected in 2019, 2021 and 2023 using different IFCBs and IFCB detection settings
% Stephanie K. Moore, February 2025
clear

filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\';
addpath(genpath(filepath)); % add new data to search path

%% load in data
load([filepath 'Shimada\Data\summary_19-23Hake_biovolume_sizethresh.mat'],'PB'); %load IFCB data that excludes small ROIs with ESD<10 um
load([filepath 'Shimada\Data\summary_19-23Hake_cells_sizethresh.mat'],'P'); 
PB_sizethresh=PB;
P_sizethresh=P;
clearvars PB P

load([filepath 'Shimada\Data\summary_19-23Hake_biovolume_lessthansizethresh.mat'],'PB'); %load IFCB data that ONLY INCLUDES small ROIs with ESD<10 um
load([filepath 'Shimada\Data\summary_19-23Hake_cells_lessthansizethresh.mat'],'P'); 
PB_lessthansizethresh=PB;
P_lessthansizethresh=P;
clearvars PB P

load([filepath 'Shimada\Data\summary_19-23Hake_biovolume.mat'],'PB'); %load all IFCB data
load([filepath 'Shimada\Data\summary_19-23Hake_cells.mat'],'P'); 

PB.unclassified(1) - (PB_sizethresh.unclassified(1) + PB_lessthansizethresh.unclassified(1))