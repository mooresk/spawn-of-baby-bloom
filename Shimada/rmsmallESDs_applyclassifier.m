%% Modified workflow from extractblobfeat_applyclassifier.m to remove smaller particles that are not consistently imaged across years before applying classifier
%   Uses features that have already been extracted, applies the classifier, and creates summary files 
%   This workflow uses code in hsosik\ifcb-analysis\ and alexisfischer\ifcb-data-science\
%
%   Stephanie K. Moore, February 2025

clear;

%%%% USER specify year for data processing (functions only do one year at a time)
yr='2019'; %'2019' %'2021' %'2023'

%%%% USER specify IFCB data paths
ifcbdir='D:\Shimada\'; 

%%%% USER specify where you want your summary file to go
summarydir='C:\Users\ifcbuser\Documents\GitHub\ifcb-data-science\IFCB-Data\Shimada\';

%%%% USER specify your classifier
classifier='D:\general\classifier\summary\Trees_CCS_NOAA-OSU_v7'; %our Northern CA Current System random forest classifier

%% Organize and process the data (uses hsosik\ifcb-analysis\)
addpath(genpath(ifcbdir)); %add to your MATLAB paths
addpath(genpath('C:\Users\ifcbuser\Documents\GitHub\ifcb-analysis\')); %add to your MATLAB paths
addpath(genpath('C:\Users\ifcbuser\Documents\GitHub\ifcb-data-science\')); %add to your MATLAB paths

%%%% load in ESD data for each year and format dataset
load([filepath 'Shimada\Data\eqdiam_biovol_2019'],'ESD','matdate');
dt = datetime(matdate,'convertfrom','datenum');