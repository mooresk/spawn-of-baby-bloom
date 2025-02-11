%% Find smaller particles that are not consistently imaged across years before applying classifier
%   
%   Stephanie K. Moore, February 2025

clear;

%%%% USER specify year for data processing (functions only do one year at a time)
yr = '2019'; %'2019' %'2021' %'2023'

%%%% USER specify IFCB data paths
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\';
addpath(genpath(filepath)); 

%%%% USER specify size cutoff (ESD in microns)
ct = 10;

%%%% load in ESD data for each year
load([filepath 'Shimada\Data\eqdiam_biovol_' yr],'ESD','matdate');
dt = datetime(matdate,'convertfrom','datenum');

%%%% find ROIs that are smaller than size cutoff
ct_ROIs = {};
for i = 1:length(ESD)
    idx = find(ESD{i,1}<ct);
    ct_ROIs{i,1} = idx;
end
