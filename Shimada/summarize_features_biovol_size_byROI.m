function [ ] = summarize_features_biovol_size_byROI(roibasepath,feapath_base,summarydir,micron_factor,yr)
%function [ ] = summarize_features_biovol_size_byROI(roibasepath,feapath_base,summarydir,micron_factor,yr)
% Inputs feature files and outputs a summary file of biovolume and equivalent spherical diameter using biovol2esd.m
%
% Stephanie K. Moore modified A.D. Fischer to correct for ESD, July 2025
%
% %Example inputs
yr='2023'; %year of interest, i.e., 2019 2021, 2023
roibasepath = 'D:\Shimada\data\'; %location of raw data
feapath_base = ['D:\Shimada\features\' yr '\']; %put in your featurepath by year
summarydir = 'C:\Users\ifcbuser\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\'; %where you want the summary file to go
micron_factor = 1/3.8; %pixel to micron conversion

filelist = dir([feapath_base 'D*.csv']);
matdate = IFCB_file2date({filelist.name}); %calculate date
runtype = cell(length(matdate),1);
filecomment = runtype;
ECD = cell(length(matdate),1);
biovol = ECD;
ESD = ECD;
roi = ECD;
for i = 1:length(filelist)
    filename = filelist(i).name;
    disp(filename)
    hdrname = [roibasepath filename(2:5) filesep filename(1:9) filesep regexprep(filename,'_fea_v2.csv','.hdr')];     
    [~,file] = fileparts(filename);

    hdr=IFCBxxx_readhdr2(hdrname);
    runtype{i}=hdr.runtype;
    filecomment{i}=hdr.filecomment;    

    feastruct = importdata([feapath_base file '.csv'], ',');
    ind = strmatch('roi_number', feastruct.colheaders);
    roi(i) = {feastruct.data(:,ind)}; clear ind

    ind = strmatch('EquivDiameter', feastruct.colheaders);
    ECD(i) = {feastruct.data(:,ind)*micron_factor}; clear ind
    
    ind = strcmp('Biovolume', feastruct.textdata);
    biovol(i) = {feastruct.data(:,ind)}; 
    ESD(i) = {biovol2esd(feastruct.data(:,ind))*micron_factor}; clear ind;

    clearvars hdrname feastruct ind;
end

%% save summary file

save([summarydir 'eqdiam_biovol_' yr], 'filelist','filecomment','roi','ECD','biovol','ESD','runtype','matdate')

disp('Summary file stored here:')
disp([summarydir 'eqdiam_biovol_' yr])

end