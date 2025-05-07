%% OPTION 1 
%Alternate code to sum up classes for ROIs > & < threshold & do sanity check #2 - CLUNKY
%max_biovol_diff = 3.7253e-09, sum_biovol_diff = 5.9464e-07
%run this code block instead of the code block beginning on line 18 in small_ROIs.m

%pre-allocate
BiEq_szthr = BiEq;
BiEq_rm = BiEq;
classcount_above_optthreshTB_szthr = NaN(length(BiEq_szthr),length(class2useTB));
classbiovol_above_optthreshTB_szthr = classcount_above_optthreshTB_szthr;
classcount_above_optthreshTB_rm = classcount_above_optthreshTB_szthr;
classbiovol_above_optthreshTB_rm = classcount_above_optthreshTB_szthr;
filelistTB = cell(length(BiEq),1);
mdateTB = NaN(length(BiEq),1);
ml_analyzedTB = NaN(length(BiEq),1);

for i = 1:length(BiEq)
    f = find(BiEq(i).eqdiam<threshold);
    ff = find(BiEq(i).eqdiam>=threshold);
    BiEq_szthr(i).roi(f)=[]; BiEq_szthr(i).eqdiam(f)=[]; BiEq_szthr(i).biovol(f)=[]; ...
        BiEq_szthr(i).class_opt(f)=[]; BiEq_szthr(i).class_wta(f)=[]; %remove ROIs < threshold from structure
    BiEq_rm(i).roi(ff)=[]; BiEq_rm(i).eqdiam(ff)=[]; BiEq_rm(i).biovol(ff)=[]; ...
        BiEq_rm(i).class_opt(ff)=[]; BiEq_rm(i).class_wta(ff)=[]; %remove ROIs > threshold from structure
end

%sum up everything for ROIs > threshold
for i = 1:length(BiEq_szthr)
    for j = 1:length(class2useTB)
        ind = strmatch(class2useTB(j), BiEq_szthr(i).class_opt);
        classcount_above_optthreshTB_szthr(i,j) = size(ind,1);
        classbiovol_above_optthreshTB_szthr(i,j) = sum(BiEq_szthr(i).biovol(ind)); 
        clear ind
    end
    filelistTB(i) = BiEq(i).filename;
    mdateTB(i) = BiEq(i).mdate;
    ml_analyzedTB(i) = BiEq(i).ml_analyzed;
    clear f 
end
clear i j

%sum up everything for ROIs < threshold
for i = 1:length(BiEq_rm)
    for j = 1:length(class2useTB)
        ind = strmatch(class2useTB(j), BiEq_rm(i).class_opt);
        classcount_above_optthreshTB_rm(i,j) = size(ind,1);
        classbiovol_above_optthreshTB_rm(i,j) = sum(BiEq_rm(i).biovol(ind)); 
        clear ind
    end
end
clear i j

%%%% sanity check
%sum up counts and biovolume for ROIs > & < threshold
classcount_above_optthreshTB_check = classcount_above_optthreshTB_szthr + classcount_above_optthreshTB_rm;
classbiovol_above_optthreshTB_check = classbiovol_above_optthreshTB_szthr + classbiovol_above_optthreshTB_rm;

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

%% OPTION 2
%Alternate code to sum up classes for ROIs > & < threshold & do sanity check #2
%max_biovol_diff = 3.7253e-09, sum_biovol_diff = 5.9464e-07
% ***THIS IS THE CODE THAT IS USED IN small_ROIs.m*** It replaced the original code that is pasted at the end of this file.
%This is the code block beginning on line 18 of small_ROIs.m and includes sanity check #2

%pre-allocate
classcount_above_optthreshTB = NaN(length(BiEq),length(class2useTB));
classbiovol_above_optthreshTB = classcount_above_optthreshTB;
classcount_above_optthreshTB_xx = classcount_above_optthreshTB;
classbiovol_above_optthreshTB_xx = classcount_above_optthreshTB;
filelistTB = cell(length(BiEq),1);
mdateTB = NaN(length(BiEq),1);
ml_analyzedTB = NaN(length(BiEq),1);

for i = 1:length(BiEq)
    f = find(BiEq(i).eqdiam<threshold);
    ff = find(BiEq(i).eqdiam>=threshold);
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

%%%% sanity check
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

%% OPTION 3
%Alternate code to sum up classes for ROIs > & < threshold & do sanity check #2 - CLUNKY
%max_biovol_diff = 3.7253e-09, sum_biovol_diff = 5.9464e-07
%run this code block instead of the code block beginning on line 18 in small_ROIs.m

%pre-allocate
classcount_above_optthreshTB_szthr = NaN(length(BiEq),length(class2useTB));
classbiovol_above_optthreshTB_szthr = classcount_above_optthreshTB_szthr;
classcount_above_optthreshTB_rm = classcount_above_optthreshTB_szthr;
classbiovol_above_optthreshTB_rm = classcount_above_optthreshTB_szthr;
filelistTB = cell(length(BiEq),1);
mdateTB = NaN(length(BiEq),1);
ml_analyzedTB = NaN(length(BiEq),1);

for i = 1:length(BiEq)
    BiEqi = [BiEq(i).roi BiEq(i).eqdiam BiEq(i).biovol];
    class_opti = BiEq(i).class_opt;
    f = BiEqi(:,2)<threshold;
    BiEqi_szthr = BiEqi(~f,:);
    class_opti_szthr = class_opti(~f);
    BiEqi_rm = BiEqi(f,:);
    class_opti_rm = class_opti(f);

    %sum counts and biovolume for particles > threshold
    for j = 1:length(class2useTB)
        ind = strmatch(class2useTB(j), class_opti_szthr);
        classcount_above_optthreshTB_szthr(i,j) = size(ind,1);
        classbiovol_above_optthreshTB_szthr(i,j) = sum(BiEqi_szthr(ind,3)); 
        clear ind
    %sum counts and biovolume for particles < threshold
        ind = strmatch(class2useTB(j), class_opti_rm);
        classcount_above_optthreshTB_rm(i,j) = size(ind,1);
        classbiovol_above_optthreshTB_rm(i,j) = sum(BiEqi_rm(ind,3)); 
        clear ind
    end
    
    filelistTB(i) = BiEq(i).filename;
    mdateTB(i) = BiEq(i).mdate;
    ml_analyzedTB(i) = BiEq(i).ml_analyzed;
    clear BiEqi class_opti f BiEqi_szthr class_opti_szthr BiEqi_rm class_opti_rm

end
clear i j

%%%% sanity check
%sum up counts and biovolume for ROIs > & < threshold
classcount_above_optthreshTB_check = classcount_above_optthreshTB_szthr + classcount_above_optthreshTB_rm;
classbiovol_above_optthreshTB_check = classbiovol_above_optthreshTB_szthr + classbiovol_above_optthreshTB_rm;

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

%% original code - calculates ROIs > threshold only - no sanity check
%pre-allocate
BiEq_threshold = BiEq;
classcount_above_optthreshTB = NaN(length(BiEq),length(class2useTB));
classbiovol_above_optthreshTB = classcount_above_optthreshTB;
filelistTB = cell(length(BiEq),1);
mdateTB = NaN(length(BiEq),1);
ml_analyzedTB = NaN(length(BiEq),1);

for i = 1:length(BiEq_threshold)
    f = find(BiEq_threshold(i).eqdiam<threshold);
    BiEq_threshold(i).roi(f)=[]; BiEq_threshold(i).eqdiam(f)=[]; BiEq_threshold(i).biovol(f)=[]; ...
        BiEq_threshold(i).class_opt(f)=[]; BiEq_threshold(i).class_wta(f)=[]; %remove ROIs < threshold from structure
    %sum counts and biovolume for particles > threshold
    for j = 1:length(class2useTB)
        ind = strmatch(class2useTB(j), BiEq_threshold(i).class_opt);
        classcount_above_optthreshTB(i,j) = size(ind,1);
        classbiovol_above_optthreshTB(i,j) = sum(BiEq_threshold(i).biovol(ind)); 
        clear ind
    end
    filelistTB(i) = BiEq_threshold(i).filename;
    mdateTB(i) = BiEq_threshold(i).mdate;
    ml_analyzedTB(i) = BiEq_threshold(i).ml_analyzed;
    clear f 
end
clear i j