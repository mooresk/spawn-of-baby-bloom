%% IFCB data processing and summary making workflow
%   Organizes raw IFCB data, extracts blobs and features, applies the
%   classifier, and creates summary files for manual, class, and features files
%   Also provides input for adjusting classlists (at bottom)
%   This workflow uses code in hsosik\ifcb-analysis\ and alexisfischer\ifcb-data-science\
%
%   A.D. Fischer, May 2024

clear;

%%%% USER specify year for data processing (those functions only do one year at a time)
yr='2024'; %'2019' %'2021' %'2022' %'2023'

%%%% USER specify IFCB data paths
ifcbdir='F:\NCC\'; 
%ifcbdir='F:\Shimada\'; 
%ifcbdir='F:\BuddInlet\';

%%%% USER specify where you want your summary file to go
summarydir='C:\Users\ifcbuser\Documents\GitHub\spawn-of-baby-bloom\NCC\';
%summarydir='C:\Users\ifcbuser\Documents\GitHub\ifcb-data-science\IFCB-Data\Shimada\';
%summarydir='C:\Users\ifcbuser\Documents\GitHub\ifcb-data-science\IFCB-Data\BuddInlet\';

%%%% USER specify your classifier
classifier='F:\general\classifier\summary\Trees_CCS_NOAA-OSU_v7'; %our Northern CA Current System random forest classifier
%classifier='F:\general\classifier\summary\Trees_BI_NOAA_v15'; %our Budd Inlet random forest classifier

%% Organize and Process the data (uses hsosik\ifcb-analysis\ and alexisfischer\ifcb-data-science\)
addpath(genpath(ifcbdir)); %add to your MATLAB paths
addpath(genpath('C:\Users\ifcbuser\Documents\GitHub\ifcb-analysis\')); %add to your MATLAB paths
addpath(genpath('C:\Users\ifcbuser\Documents\GitHub\ifcb-data-science\')); %add to your MATLAB paths

% Step 1: Put raw data in correct folders
copy_data_into_folders('F:\NCC\2024\',[ifcbdir 'data\' yr '\']); %use this if data are already in folder structure (e.g., Budd Inlet)
%copy_data_into_folders('C:\SFTP-BuddInlet\2024\',[ifcbdir 'data\' yr '\']); %use this if data are already in folder structure (e.g., Budd Inlet)
%sort_data_into_folders('F:\KudelaSynology\',[ifcbdir 'data\' yr '\']); %use this if data also need to be put into folder structure

% Step 2: Extract blobs
start_blob_batch_user_training([ifcbdir 'data\' yr '\'],[ifcbdir 'blobs\' yr '\'],true); 

% Step 3: Extract features
start_feature_batch_user_training([ifcbdir 'data\' yr '\'],[ifcbdir 'blobs\' yr '\'],[ifcbdir 'features\' yr '\'],true)

% Step 4: Apply classifier
start_classify_batch_user_training(classifier,[ifcbdir 'features\' yr '\'],[ifcbdir 'class\class' yr '_v1\']);

%% Summarize class files (uses alexisfischer\ifcb-data-science\)
%%%% USER
yrrange = 2024:2024; %years that you want summarized
adhoc = 0.50; %adhoc score threshold of interest
micron_factor=1/3.8; %pixel to micron conversion
classindexpath ='C:\Users\ifcbuser\Documents\GitHub\ifcb-data-science\IFCB-Tools\convert_index_class\class_indices.mat'; %location of class index path to identify which classes are diatoms for carbon conversion

% Option 1: summarize cell counts for 3 different different classifier outputs (winner takes all, opt score threshold, adhoc threshold)
summarize_cells_from_classifier([ifcbdir 'data\xxxx\'],[ifcbdir 'data\class\classxxxx_v1\'],[summarydir 'class\'],adhoc,yrrange)

% Option 2: summarize cell counts, biovolume, and mean size for 3 different classifier outputs (winner takes all, opt score threshold, adhoc threshold)
summarize_class_cells_biovol_size([ifcbdir 'data\xxxx\'],[ifcbdir 'features\xxxx\'],[ifcbdir 'data\class\classxxxx_v1\'],[summarydir 'class\'],micron_factor,adhoc,yrrange);

% Option 3: summarize cell counts, biovolume, and carbon for 2 different classifier outputs (winner takes all, opt score threshold)
summarize_class_cells_biovol_carbon([ifcbdir 'data\xxxx\'],[ifcbdir 'features\xxxx\'],[ifcbdir 'data\class\classxxxx_v1\'],classindexpath,[summarydir 'class\'],micron_factor,yrrange)

%% Summarize manual annotations (uses alexisfischer\ifcb-data-science\)
%%%% USER
micron_factor=1/3.8; %pixel to micron conversion

% Option 1: summarize cell counts for manual annotations
summarize_manual_cells([ifcbdir 'manual\'],[ifcbdir 'data\'],[summarydir 'manual\'])

% Option 2: summarize cell counts, biovolume, and mean size for manual annotations
summarize_manual_cells_biovol_size([ifcbdir 'manual\'],[ifcbdir 'data\'],[ifcbdir 'features\'],[summarydir 'manual\'],micron_factor)

%% Summarize ROI size and biovolume (uses alexisfischer\ifcb-data-science\)
% use these summaries to make particle size distribution plots
%%%% USER
micron_factor=1/3.8; %pixel to micron conversion
yr='2021'; %year you want summarized

% Option 1: summarize biovolume and size for each ROI for features dataset
summarize_features_biovol_size_byROI([ifcbdir 'data\'],[ifcbdir 'features\' yr '\'],summarydir,micron_factor,yr)

% Option 2: summarize cell counts, biovolume, and size for each ROI for manual annotations
summarize_manual_cells_biovol_size_byROI([ifcbdir 'manual\'],[ifcbdir 'data\'],[ifcbdir 'features\' yr '\'],[summarydir 'manual\'],micron_factor,yr)

%% adjust classlists
% you will need to do this if you change the classes in the config file
% start_mc_adjust_classes_user_training('F:\general\config\class2use_17','F:\general\classifier\manual_merged_NOAA\')
% start_mc_adjust_classes_user_training('F:\general\config\class2use_17','F:\BuddInlet\manual\')
% start_mc_adjust_classes_user_training('F:\general\config\class2use_17','F:\LabData\manual\')
% start_mc_adjust_classes_user_training('F:\general\config\class2use_17','F:\Shimada\manual\')
% start_mc_adjust_classes_user_training('F:\general\config\class2use_17','F:\BuddInlet\manual_DiscreteSamples\')
% start_mc_adjust_classes_user_training('F:\general\config\class2use_17','F:\BuddInlet\manual_AltSamples\')
