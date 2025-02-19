function [ ] = summarize_class_cells_biovol_size_byROI(summarydir,feapath_generic,roibasepath_generic,classpath_generic,micron_factor,yrrange)
%function [ ] = summarize_class_cells_biovol_size_byROI(summarydir,feapath_generic,roibasepath_generic,classpath_generic,micron_factor,yrrange)
% Inputs class and features files and outputs a summary file of cell counts 
% and ESD for all ROIs for 2 different classifier outputs (winner takes all, opt score threshold)
%
% Stephanie K. Moore, February 2025
%
% %Example inputs
% summarydir = 'C:\Users\ifcbuser\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\'; %where you want the summary file to go
% feapath_generic = 'D:\Shimada\features\xxxx\'; %Put in your featurepath byyear
% roibasepath_generic = 'D:\Shimada\data\xxxx\'; %location of raw data
% classpath_generic = 'D:\Shimada\class\classxxxx_v1\'; %location of classified data
% yrrange = [2019 2021 2023];  %years that you want summarized
% micron_factor = 1/3.8; %pixel to micron conversion

%%%% USER specify size cutoff (ESD in microns)
ESDthreshold = 10;

classfiles = [];
filelistTB = [];
feafiles = [];
hdrname = [];

%% get the names and paths of the files to summarize
for i = 1:length(yrrange)
    yr = yrrange(i);  
    classpath = regexprep(classpath_generic, 'xxxx', num2str(yr));
    feapath = regexprep(feapath_generic, 'xxxx', num2str(yr));
    roibasepath = regexprep(roibasepath_generic, 'xxxx', num2str(yr));

    temp = dir([classpath 'D*.mat']);
    if ~isempty(temp) 
        names = char(temp.name);
        filelistTB = [filelistTB; cellstr(names(:,1:24))];    
        
        pathall = repmat(roibasepath, length(temp),1);
        xall = repmat('.hdr', size(names,1),1);      
        fall = repmat('\', size(names,1),1);            
        hdrname = [hdrname; cellstr([pathall names(:,1:9) fall names(:,1:24) xall])];

        pathall = repmat(classpath, length(temp),1);
        classfiles = [classfiles; cellstr([pathall names])];
        
        pathall = repmat(feapath, length(temp),1);
        xall = repmat('_fea_v2.csv', length(temp),1);
        feafiles = [feafiles; cellstr([pathall names(:,1:24) xall])];   
    end
   clearvars temp names pathall classpath feapath roibasepath xall fall yr    
end

mdateTB = IFCB_file2date(filelistTB);
ml_analyzedTB = IFCB_volume_analyzed(hdrname); 

runtypeTB=filelistTB;
filecommentTB=filelistTB;

load(classfiles{1},'class2useTB');
num2dostr = num2str(length(classfiles));

classcount_sizethreshTB = NaN(length(classfiles),length(class2useTB));
classbiovol_sizethreshTB = classcount_sizethreshTB;
classcount_above_optthresh_sizethreshTB = classcount_sizethreshTB;
classbiovol_above_optthresh_sizethreshTB = classcount_sizethreshTB;

for i = 1:length(filelistTB)
    if ~rem(i,100), disp(['reading ' num2str(i) ' of ' num2dostr]), end  
    
    classfile = classfiles{i};
    load(classfile,'roinum','TBclass','TBclass_above_threshold');
    
    feafile = feafiles{i};
    feastruct = importdata(feafile);
    ind = strmatch('Biovolume', feastruct.colheaders);
    biovol = feastruct.data(:,ind)*micron_factor.^3; clearvars ind;
    ind = strmatch('EquivDiameter', feastruct.colheaders);
    eqdiam = feastruct.data(:,ind)*micron_factor; clearvars ind;
    
    idx = eqdiam<ESDthreshold; 
    
    % ClBiEq(i).filename=filelistTB(i);
    % ClBiEq(i).dt=datetime(mdateTB(i),'convertfrom','datenum');
    % ClBiEq(i).ml_analyzed=IFCB_volume_analyzed(hdrname(i));   
    % 
    % ClBiEq(i).roi=roinum(~idx);
    % ClBiEq(i).class_wta=TBclass(~idx);
    % ClBiEq(i).class_opt=TBclass_above_threshold(~idx);
    % ClBiEq(i).eqdiam=eqdiam(~idx);
    % ClBiEq(i).biovol=biovol(~idx);
    % 
    % ClBiEq(i).REMOVEDroi=roinum(idx);
    % ClBiEq(i).REMOVEDclass_wta=TBclass(idx);
    % ClBiEq(i).REMOVEDclass_opt=TBclass_above_threshold(idx);
    % ClBiEq(i).REMOVEDeqdiam=eqdiam(idx);
    % ClBiEq(i).REMOVEDbiovol=biovol(idx);

    %% sum up classes
    classcount = NaN(length(class2useTB),1);
    classcount_above_optthresh = classcount;
    classbiovol = classcount;
    classbiovol_above_optthresh = classcount;

    for ii = 1:length(class2useTB)
        ind = strmatch(class2useTB(ii), TBclass(~idx));
        classcount(ii) = size(ind,1);
        classbiovol(ii) = sum(biovol(ind)); clearvars ind;  
    
        ind = strmatch(class2useTB(ii), TBclass_above_threshold(~idx));
        classcount_above_optthresh(ii) = size(ind,1);
        classbiovol_above_optthresh(ii) = sum(biovol(ind)); clearvars ind;     
    end

    classcount_sizethreshTB(i,:) = classcount;
    classbiovol_sizethreshTB(i,:) = classbiovol;
    classcount_above_optthresh_sizethreshTB(i,:) = classcount_above_optthresh;
    classbiovol_above_optthresh_sizethreshTB(i,:) = classbiovol_above_optthresh;

    hdr=IFCBxxx_readhdr2(hdrname{i});
    runtypeTB{i}=hdr.runtype;
    filecommentTB{i}=hdr.filecomment;    

    clearvars idx
end

%% save summary file

note1 = 'Biovolume: cubed micrometers';
note2= 'Equivalent spherical diameter: micrometers';
note3= ['ESD size threshold=' num2str(ESDthreshold)];

save([summarydir 'class_cells_biovol_eqdiam_sizethresh'], '*TB', 'note1', 'note2', 'note3')

disp('Summary file stored here:')
disp([summarydir 'class_cells_biovol_eqdiam_sizethresh'])

end
