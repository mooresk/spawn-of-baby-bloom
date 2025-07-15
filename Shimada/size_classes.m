%% Create a summary file for particle size classes
% Stephanie K. Moore, June 2025

clear

%% load in data
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\';
summarydir = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\'; %where you want the summary file to go
addpath(genpath(filepath)); % add new data to search path
threshold = 10;

load([filepath 'class_eqdiam_biovol_class_byROI.mat'], 'BiEq', 'class2useTB'); %load IFCB data from summarize_class_cells_biovol_size_byROI.m

%% Generate size bins
Y = log2(1):1/3:log2(50e6); 
YY = 2.^Y;
% generates size classes from Dugenne et al 2024 (https://doi.org/10.5194/essd-16-2971-2024) that are logarithmically spaced 
% using a base of 2 and an increment of 1/3 so that a doubling in ESD occurs every third bin, with a range between 1–50,000,000 µm.

mxESD = NaN(1,length(BiEq));
mnESD = NaN(1,length(BiEq));

for i = 1:length(BiEq)
    mxESD(i) = max(BiEq(i).ESD);
    t = BiEq(i).ESD;
    t(t == 0) = NaN;
    mnESD(i) = min(t);
    clear t
end
clear i

maxESD = max(mxESD); %finds maximum ESD from all years
minESD = min(mnESD); %finds minimum ESD from all years

f = find(YY>maxESD);
YYmax = YY(f(1)); %this is the upper end of the biggest size bin needed
imax = f(1); %this is the index for the upper end in YY

% Can choose two ways to set the lower end of the smallest size bin - can
% use the smallest ESD to determine lower end, or can ignore ROIs smaller 
% than 10 um to standardize data collected in 2019, 2021 and 2023 using different 
% IFCBs and IFCB detection settings.
% 
% OPTION 1: smallest ESD measured
%ff = find(YY<minESD);
%YYmin = YY(ff(end)); %this is the lower end of the smallest size bin needed

% OPTION 2: 10 um size threshold
ff = find(YY<threshold); 
YYmin = YY(ff(end)+1); %this selects 10.0794 ESD
imin = ff(end)+1; %this is the index for the lower end in YY

clear f ff

sizeclass2use = YY(imin:imax);
sizeclass2useB = (pi*sizeclass2use^3)/6; %rearranged equation in biovol2esd.m to solve for biovol

%% sum up size classes for ROIs
%pre-allocate
sizeclasscount = NaN(length(BiEq),length(sizeclass2use)-1);
sizeclassbiovol = sizeclasscount;
filelist = cell(length(BiEq),1);
mdate = NaN(length(BiEq),1);
ml_analyzed = NaN(length(BiEq),1);

%sum counts and biovolume for particles in each size bin
for i = 1:length(BiEq)
    for j = 1:length(sizeclass2use)-1
        ind = find(BiEq(i).ESD>=sizeclass2use(j) & BiEq(i).ESD<sizeclass2use(j+1));
        sizeclasscount(i,j) = size(ind,1);
        sizeclassbiovol(i,j) = sum(BiEq(i).biovol(ind)); 
        clear ind
    end
    filelist(i) = BiEq(i).filename;
    mdate(i) = BiEq(i).mdate;
    ml_analyzed(i) = BiEq(i).ml_analyzed;
end
clear i j

%% save new summary file
save([summarydir 'summary_biovol_sizeclass'],'sizeclass2use', 'sizeclass2useB', 'sizeclasscount','sizeclassbiovol','ml_analyzed','filelist','mdate')
disp('Summary file stored here:')
disp([summarydir 'summary_biovol_sizeclass'])