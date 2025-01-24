%% Make summary file of 2019, 2021 and 2023 Shimada data
% merge IFCB data, sensor data, and krill data
%
clear;

filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\';
ifcbpath = 'C:\Users\Stephanie.Moore\Documents\GitHub\ifcb-data-science\';
addpath(genpath(filepath)); 
addpath(genpath(ifcbpath));

%% Load and merge 2019, 2021 and 2023 environmental sensor data
S19=load([filepath 'Shimada\Data\environ_Shimada2019'],'DT','LON','LAT','TEMP','SAL','FL');
S21=load([filepath 'Shimada\Data\environ_Shimada2021'],'DT','LON','LAT','TEMP','SAL','FL');
S23=load([filepath 'Shimada\Data\environ_Shimada2023'],'DT','LON','LAT','TEMP','SAL','FL');
DT=[S19.DT;S21.DT;S23.DT]; LON=[S19.LON;S21.LON;S23.LON]; LAT=[S19.LAT;S21.LAT;S23.LAT];
TEMP=[S19.TEMP;S21.TEMP;S23.TEMP]; SAL=[S19.SAL;S21.SAL;S23.SAL]; FL=[S19.FL;S21.FL;S23.FL];
T=timetable(DT,LAT,LON,TEMP,SAL,FL);

%% Load and format 2019-2023 IFCB data
load([ifcbpath 'IFCB-Data\Shimada\class\summary_biovol_allTB.mat'],...
    'class2useTB','classcount_above_optthreshTB','classbiovol_above_optthreshTB','filelistTB','mdateTB','ml_analyzedTB');

dt=datetime(mdateTB,'convertfrom','datenum'); dt.Format='yyyy-MM-dd HH:mm:ss';        
cellsmL = classcount_above_optthreshTB./ml_analyzedTB;    
bvmL = classbiovol_above_optthreshTB./ml_analyzedTB;    

%%%% sum PN biovolume into one variable all variables except and PN from regular summary
id1=find(contains(class2useTB,'Pseudo-nitzschia_large_1cell')); 
id2=find(contains(class2useTB,'Pseudo-nitzschia_large_2cell')); 
id3=find(contains(class2useTB,'Pseudo-nitzschia_large_3cell')); 
PN_bvmL = sum(classbiovol_above_optthreshTB(:,[id1,id2,id3]),2)./ml_analyzedTB;
PN1 = sum(classcount_above_optthreshTB(:,id1),2);
PN2 = 2*sum(classcount_above_optthreshTB(:,id2),2);
PN3 = 3.5*sum(classcount_above_optthreshTB(:,id3),2);
PN_cellsmL = sum([PN1,PN2,PN3],2)./ml_analyzedTB;

%%%% get ratio of of dinos to diatoms 
% sum diatom biovolume
[idiatom,~]=get_class_ind(class2useTB,'diatom',[ifcbpath 'IFCB-Tools\convert_index_class\class_indices']); %get_class_ind function A.Fischer wrote in IFCB_Tools
[idino,~]=get_class_ind(class2useTB,'dinoflagellate',[ifcbpath 'IFCB-Tools\convert_index_class\class_indices']);
diatom_bvmL=sum(classbiovol_above_optthreshTB(:,idiatom),2)./ml_analyzedTB;
dino_bvmL=sum(classbiovol_above_optthreshTB(:,idino),2)./ml_analyzedTB;
dino_diat_ratio=log10((dino_bvmL+1)./(diatom_bvmL+1)); %log scale so don't bias denominator low. see Isles 2020. add +1 so avoid Inf

%%%% rename grouped classes 
class2useTB(strcmp('Cerataulina,Dactyliosolen,Detonula,Guinardia',class2useTB))={'Cera_Dact_Deto_Guin'};
class2useTB(strcmp('Chaetoceros_chain,Chaetoceros_single',class2useTB))={'Chaetoceros'};
class2useTB(strcmp('Dinophysis_acuminata,Dinophysis_acuta,Dinophysis_caudata,Dinophysis_fortii,Dinophysis_norvegica,Dinophysis_odiosa,Dinophysis_parva,Dinophysis_rotundata,Dinophysis_tripos',class2useTB))={'Dinophysis'};
class2useTB(strcmp('Heterocapsa_triquetra,Scrippsiella',class2useTB))={'Hete_Scri'};
class2useTB(strcmp('Thalassiosira_chain',class2useTB))={'Thalassiosira'};
class2useTB(strcmp('Proboscia,Rhizosolenia',class2useTB))={'Prob_Rhiz'};

%%%% remove unclassified and PN from regular summary
idx=contains(class2useTB,'Pseudo-nitzschia'); cellsmL(:,idx)=[]; bvmL(:,idx)=[]; class2useTB(idx)=[];
%idx=contains(class2useTB,'unclassified'); cellsmL(:,idx)=[]; bvmL(:,idx)=[]; class2useTB(idx)=[];

%%%% add PN back
class2useTB(end+1)={'Pseudonitzschia'};
cellsmL(:,end+1)=PN_cellsmL;
bvmL(:,end+1)=PN_bvmL;

clearvars PN_bvmL PN_cellsmL ml_analyzedTB idx classcount_above_optthreshTB classbiovol_above_optthreshTB mdateTB id1 id2 id3

%%%% add biovol
class2useTB_b=class2useTB;
bvmL(:,end+1)=diatom_bvmL;
bvmL(:,end+1)=dino_bvmL;
bvmL(:,end+1)=dino_diat_ratio;
class2useTB_b(end+1)={'diatom'};
class2useTB_b(end+1)={'dino'};
class2useTB_b(end+1)={'dino_diat_ratio'};

%%%% round IFCB data to nearest minute and match with environmental data
dt = dateshift(dt,'start','minute'); 
TT = array2timetable(cellsmL,'RowTimes',dt,'VariableNames',class2useTB(1:end));
TT = addvars(TT,filelistTB,'Before',class2useTB(1));

TB = array2timetable(bvmL,'RowTimes',dt,'VariableNames',class2useTB_b(1:end));
TB = addvars(TB,filelistTB,'Before',class2useTB(1));

clearvars class2useTB th dt cellsmL filelistTB i idx ml_analyzedTB mdateTB 

%% Merge environmental data with IFCB data and calculate distance between each IFCB sample and the coast
P=synchronize(TT,T,'first');
PB=synchronize(TB,T,'first');

% calculate distance to caoast
load([filepath 'Shimada\Data\coast_CCS.mat'],'coast');
coast=coast((coast(:,2)>=32 & coast(:,2)<=50),:); %shorten this to latitide where we have IFCB data
C.lat=coast(:,2); C.lon=coast(:,1);
coast_km=NaN*P.LAT; %preallocate
for i=1:(length(coast_km))
    [dist,~]=(distance(P.LAT(i),P.LON(i),C.lat,C.lon)); % get all the possible combinations
    coast_km(i) = deg2km(min(dist)); %find the minimum distance
end

P=addvars(P,coast_km);
PB=addvars(PB,coast_km);

PB=movevars(PB,{'LAT' 'LON' 'coast_km' 'TEMP' 'SAL' 'FL'},'Before','filelistTB');
PB=movevars(PB,{'Pseudonitzschia'},'Before','Skeletonema');
PB(isnan(PB.LAT),:)=[];

% remove non biovolume
P=removevars(P,{'TEMP' 'SAL' 'FL'});
P=movevars(P,{'LAT' 'LON' 'coast_km'},'Before','filelistTB');
P=movevars(P,{'Pseudonitzschia'},'Before','Skeletonema');
P(isnan(P.LAT),:)=[];

%% Set up the Import Options and import the krill data
opts = delimitedTextImportOptions("NumVariables", 27);

% specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% specify column names and types
opts.VariableNames = ["Year", "ID", "Survey", "Transect", "Interval", "NASC", "Lat_S", "Lat_M", "Lat_E", "Lon_S", "Lon_M", "Lon_E", "Date_S", "Date_M", "Date_E", "Time_S", "Time_M", "Time_E", "Ping_S", "Ping_M", "Ping_E", "Dist_S", "Dist_M", "Dist_E", "Date", "Frequency", "DepthBin"];
opts.VariableTypes = ["double", "string", "string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "string", "datetime", "string", "datetime", "datetime", "datetime", "double", "double", "double", "double", "double", "double", "datetime", "double", "string"];

% specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% specify variable properties
opts = setvaropts(opts, ["ID", "Survey", "Transect", "Date_S", "Date_E", "DepthBin"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["ID", "Survey", "Transect", "Date_S", "Date_E", "DepthBin"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Date_M", "InputFormat", "yyyy-MM-dd", "DatetimeFormat", "preserveinput");
opts = setvaropts(opts, "Time_S", "InputFormat", "HH:mm:ss", "DatetimeFormat", "preserveinput");
opts = setvaropts(opts, "Time_M", "InputFormat", "HH:mm:ss", "DatetimeFormat", "preserveinput");
opts = setvaropts(opts, "Time_E", "InputFormat", "HH:mm:ss", "DatetimeFormat", "preserveinput");
opts = setvaropts(opts, "Date", "InputFormat", "yyyy-MM-dd", "DatetimeFormat", "preserveinput");

% import the data
krill = readtable([filepath 'Shimada\Data\Combine_0.5nmixWC_2019-2023.csv'], opts);

% combine date and time from separate variables
%%%% preallocate
Date_S_t=NaT(height(krill),1);
Date_E_t=NaT(height(krill),1);
krill.myDatetime_S=NaT(height(krill),1);
krill.myDatetime_M=NaT(height(krill),1);
krill.myDatetime_E=NaT(height(krill),1);

for i=1:height(krill)
    Date_S_t(i) = datetime(krill.Date_S(i),'InputFormat','yyyyMMdd');
    Date_E_t(i) = datetime(krill.Date_E(i),'InputFormat','yyyyMMdd');
end

% clear temporary variables
clear i

Date_M_t = krill.Date_M;

Date_S_t.Format = 'dd.MM.uuuu HH:mm:ss';
Date_M_t.Format = 'dd.MM.uuuu HH:mm:ss';
Date_E_t.Format = 'dd.MM.uuuu HH:mm:ss';

Time_S_t = krill.Time_S;
Time_M_t = krill.Time_M;
Time_E_t = krill.Time_E;

Time_S_t.Format = 'dd.MM.uuuu HH:mm:ss';
Time_M_t.Format = 'dd.MM.uuuu HH:mm:ss';
Time_E_t.Format = 'dd.MM.uuuu HH:mm:ss';

krill.myDatetime_S = Date_S_t + timeofday(Time_S_t);
krill.myDatetime_M = Date_M_t + timeofday(Time_M_t);
krill.myDatetime_E = Date_E_t + timeofday(Time_E_t);

% clear temporary variables
clear opts Date_S_t Date_M_t Date_E_t Time_S_t Time_M_t Time_E_t i

%% Match IFCB and krill data
% for each IFCB sample, find the NASC measurements for 0.5 nmi bins that start no more than 10 min before the IFCB sample and end no more than 10 min after
%%%% preallocate
PB.avNASC=NaN(height(PB),1);
PB.transect=strings(height(PB),1);

for i = 1:height(PB)
    idx = find(krill.myDatetime_S >= PB.DT(i) - minutes(10) & krill.myDatetime_E <= PB.DT(i) + minutes(10));
    if idx
        PB.avNASC(i) = mean(krill.NASC(idx));
        PB.transect(i) = strtrim(mode(char(krill.Transect(idx))));
    end
end

% Clear temporary variables
clear i idx

%% Calculate proportion of unclassified cells/biomass
fx_unclassified_P=mean(P.unclassified./(P.unclassified + P.Akashiwo + P.Alexandrium_catenella + P.Asterionellopsis + P.Cera_Dact_Deto_Guin + P.Chaetoceros + P.Cylindrotheca + ...
    P.Dictyocha + P.Dinophysis + P.Eucampia + P.Gymnodinium + P.Hete_Scri + P.Katodinium + P.Lauderia + P.Leptocylindrus + P.Navicula + P.Nitzschia + ...
    P.Prob_Rhiz + P.Skeletonema + P.Thalassiosira + P.Pseudonitzschia));

fx_unclassified_PB=mean(PB.unclassified./(PB.unclassified + PB.Akashiwo + PB.Alexandrium_catenella + PB.Asterionellopsis + PB.Cera_Dact_Deto_Guin + PB.Chaetoceros + PB.Cylindrotheca + ...
    PB.Dictyocha + PB.Dinophysis + PB.Eucampia + PB.Gymnodinium + PB.Hete_Scri + PB.Katodinium + PB.Lauderia + PB.Leptocylindrus + PB.Navicula + PB.Nitzschia + ...
    PB.Prob_Rhiz + PB.Skeletonema + PB.Thalassiosira + PB.Pseudonitzschia));

%% format for .csv file
save('C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\summary_19-23Hake_cells.mat','P');
save('C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\summary_19-23Hake_biovolume.mat','PB');

clearvars E T idx X
