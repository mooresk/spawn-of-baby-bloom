%% remove small ROIs with ESD < threshold & create modified summary file
% Used remove small ROIs with ESD < threshold (10 um here) to standardize data 
% collected in 2019, 2021 and 2023 using different IFCBs and IFCB detection settings.
% Size threshold determined from inspection of sizefreqhistogram_byROI.m.
% ESD is calculated using biovol2esd.m
%
% Stephanie K. Moore, February 2025
%
clear

filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\';
summarydir = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\'; %where you want the summary file to go
addpath(genpath(filepath)); % add new data to search path
threshold = 10;

%% load in data
load([filepath 'class_eqdiam_biovol_class_byROI.mat'], 'BiEq', 'class2useTB'); %load IFCB data from summarize_class_cells_biovol_size_byROI.m

%% sum up classes for ROIs > & < threshold
%pre-allocate
classcount_above_optthreshTB = NaN(length(BiEq),length(class2useTB));
classbiovol_above_optthreshTB = classcount_above_optthreshTB;
classcount_above_optthreshTB_xx = classcount_above_optthreshTB;
classbiovol_above_optthreshTB_xx = classcount_above_optthreshTB;
filelistTB = cell(length(BiEq),1);
mdateTB = NaN(length(BiEq),1);
ml_analyzedTB = NaN(length(BiEq),1);

for i = 1:length(BiEq)
    f = find(BiEq(i).ESD<threshold);
    ff = find(BiEq(i).ESD>=threshold);
    %sum counts and biovolume for particles > threshold
    for j = 1:length(class2useTB)
        ind = strmatch(class2useTB(j), BiEq(i).class_opt(ff));
        classcount_above_optthreshTB(i,j) = size(ind,1);
        classbiovol_above_optthreshTB(i,j) = sum(BiEq(i).biovol(ff(ind))); 
        clear ind
    %sum counts and biovolume for particles < threshold
        ind = strmatch(class2useTB(j), BiEq(i).class_opt(f));
        classcount_above_optthreshTB_xx(i,j) = size(ind,1);
        classbiovol_above_optthreshTB_xx(i,j) = sum(BiEq(i).biovol(f(ind))); 
        clear ind
    end
    filelistTB(i) = BiEq(i).filename;
    mdateTB(i) = BiEq(i).mdate;
    ml_analyzedTB(i) = BiEq(i).ml_analyzed;
    clear f 
end
clear i j

%% save new summary file
save([summarydir 'summary_biovol_allTB_szthr'] ,'*TB')

disp('Summary file stored here:')
disp([summarydir 'summary_biovol_allTB_szthr'])

%% sanity check #1
%run this code block to sum up all ROIs from BiEq & compare with output from summarize_class_cells_biovol_size.m

%pre-allocate
classcount_above_optthreshTB_check = NaN(length(BiEq),length(class2useTB));
classbiovol_above_optthreshTB_check = classcount_above_optthreshTB_check;

%sum up everything
for i = 1:length(BiEq)
    for j = 1:length(class2useTB)
        ind = strmatch(class2useTB(j), BiEq(i).class_opt);
        classcount_above_optthreshTB_check(i,j) = size(ind,1);
        classbiovol_above_optthreshTB_check(i,j) = sum(BiEq(i).biovol(ind)); 
        clear ind
    end
end
clear i j

%load classcount_above_optthreshTB from original summary file
load('C:\Users\Stephanie.Moore\Documents\GitHub\ifcb-data-science\IFCB-Data\Shimada\class\summary_biovol_allTB.mat',...
   'classcount_above_optthreshTB', 'classbiovol_above_optthreshTB');

class_result = isequal(classcount_above_optthreshTB_check,classcount_above_optthreshTB);
biovol_result = isequal(classbiovol_above_optthreshTB_check,classbiovol_above_optthreshTB);

class_result %will return 1 if the same and 0 if different
biovol_result %will return 1 if the same and 0 if different

%% sanity check #2 - max_biovol_diff = 3.7253e-09, sum_biovol_diff = 5.9464e-07
%run this code block to add classes from BiEq that are > & < threshold & compare with output from summarize_class_cells_biovol_size.m

%sum up counts and biovolume for ROIs > & < threshold
classcount_above_optthreshTB_check = classcount_above_optthreshTB + classcount_above_optthreshTB_xx;
classbiovol_above_optthreshTB_check = classbiovol_above_optthreshTB + classbiovol_above_optthreshTB_xx;

classcount_above_optthreshTB_szthr = classcount_above_optthreshTB;
classbiovol_above_optthreshTB_szthr = classbiovol_above_optthreshTB;

clear classcount_above_optthreshTB classbiovol_above_optthreshTB;

%load classcount_above_optthreshTB from original summary file
load('C:\Users\Stephanie.Moore\Documents\GitHub\ifcb-data-science\IFCB-Data\Shimada\class\summary_biovol_allTB.mat',...
   'classcount_above_optthreshTB', 'classbiovol_above_optthreshTB');

%compare
class_result = isequal(classcount_above_optthreshTB_check,classcount_above_optthreshTB);
biovol_result = isequal(classbiovol_above_optthreshTB_check,classbiovol_above_optthreshTB);

class_result %will return 1 if the same and 0 if different
biovol_result %will return 1 if the same and 0 if different

max_biovol_diff = max(max(abs(classbiovol_above_optthreshTB_check-classbiovol_above_optthreshTB)))
sum_biovol_diff = sum(sum(abs(classbiovol_above_optthreshTB_check-classbiovol_above_optthreshTB)))