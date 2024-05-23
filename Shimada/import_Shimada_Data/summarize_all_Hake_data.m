%% make summary file of 2019 and 2021 Shimada data
% merge IFCB data, sensor data, and discrete data
% the resulting merged data are used in Fischer et al. 2024, L&O
%
clear;

filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\';
ifcbpath = 'C:\Users\Stephanie.Moore\Documents\GitHub\ifcb-data-science\';
%addpath(genpath('~/Documents/MATLAB/ifcb-analysis/'));
addpath(genpath(filepath));
addpath(genpath(ifcbpath));

%%%% match timestamps of sensor data and HAB data
%%%% merge 2019 and 2021 data
S19=load([filepath 'Shimada\Data\environ_Shimada2019'],'DT','LON','LAT','TEMP','SAL','PCO2','FL');
S21=load([filepath 'Shimada\Data\environ_Shimada2021'],'DT','LON','LAT','TEMP','SAL','PCO2','FL');
DT=[S19.DT;S21.DT]; LON=[S19.LON;S21.LON]; LAT=[S19.LAT;S21.LAT];
TEMP=[S19.TEMP;S21.TEMP]; SAL=[S19.SAL;S21.SAL]; PCO2=[S19.PCO2;S21.PCO2]; FL=[S19.FL;S21.FL];
T=timetable(DT,LAT,LON,TEMP,SAL,PCO2,FL);

load([filepath 'Shimada\Data\HAB_merged_Shimada19-21'],'HA'); %GMT time
HA.dt.Format='yyyy-MM-dd HH:mm:ss'; HA.dt=dateshift(HA.dt,'start','minute'); %change the date format and round up to nearest minute
H=table2timetable(HA); H=removevars(H,{'st','lat','lon','fx_pseu','fx_heim','fx_pung','fx_mult','fx_frau','fx_aust','fx_deli'});
H.pDA_pgmL(H.pDA_pgmL<0)=0; H=sortrows(H);
T = synchronize(T,H,'first','fillwithmissing');

%%%% find distance in km between samples
%REQUIRES MAPPING TOOLBOX
T.sample_km=NaN*T.Silicate_uM;
for i=1:(length(T.sample_km)-1)
    T.sample_km(i)=deg2km(distance(T.LAT(i),T.LON(i),T.LAT(i+1),T.LON(i+1))); 
end

%%%% find distance in km each sample and the coast
load([filepath 'Shimada\Data\coast_CCS.mat'],'coast');
coast=coast((coast(:,2)>=40 & coast(:,2)<=49),:); %shorten this to just NCC
C.lat=coast(:,2); C.lon=coast(:,1);
T.coast_km=NaN*T.Silicate_uM; %preallocate
for i=1:(length(T.coast_km))
    [dist,~]=(distance(T.LAT(i),T.LON(i),C.lat,C.lon)); % get all the possible combinations
    T.coast_km(i) = deg2km(min(dist)); %find the minimum distance
end

%%%% duplicate HA data for X minutes before and after data collection
% this is to determine the distance between IFCB and discrete samples
X=10; % minutes. max gap allowed 
range=(1:1:X)';
dist=[flipud(range);0;range];
T.gap_km=NaN*T.Silicate_uM;
idx=find(~isnan(T.chlA_ugL));
for i=1:length(idx)
    %fill before
    irange=idx(i)-X:idx(i)-1;
    T.gap_km(irange)=flipud(cumsum([T.sample_km(irange)]));
    %fill after
    irange=idx(i)+1:idx(i)+X;
    T.gap_km(irange)=cumsum([T.sample_km(irange)]);
    T.gap_km(idx(i))=0;

    irange=idx(i)-X:idx(i)+X;
    T.chlA_ugL(irange)=T.chlA_ugL(idx(i));
    T.pDA_pgmL(irange)=T.pDA_pgmL(idx(i));    
    T.PN_mcrspy(irange)=T.PN_mcrspy(idx(i));
    T.Nitrate_uM(irange)=T.Nitrate_uM(idx(i));
    T.Phosphate_uM(irange)=T.Phosphate_uM(idx(i));
    T.Silicate_uM(irange)=T.Silicate_uM(idx(i));
    T.S2N(irange)=T.S2N(idx(i));
    T.P2N(irange)=T.P2N(idx(i));      
end

clearvars S19 S21 LON LAT TEMP SAL PCO2 H HA DT i FL

%% format IFCB data
load([ifcbpath 'IFCB-Data\Shimada\class\summary_biovol_allTB_2019-2023'],...
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
idx=contains(class2useTB,'unclassified'); cellsmL(:,idx)=[]; bvmL(:,idx)=[]; class2useTB(idx)=[];

%%%% add PN back
class2useTB(end+1)={'Pseudonitzschia'};
cellsmL(:,end+1)=PN_cellsmL;
bvmL(:,end+1)=PN_bvmL;

clearvars PN_bvmL PN_cellsmL ml_analyzedTB idx classcount_above_optthreshTB classbiovol_above_optthreshTB mdateTB id1 id2 id3

%%%% option to add PN width (did not end up using in Fischer et al. 2024)
% load([ifcbpath 'IFCB-Data/Shimada/class/summary_PN_allTB_micron-factor3.8'],'PNwidth_opt');
% 
% width=[PNwidth_opt.mean]';
% width(isnan(width))=0;
% cellsmL(:,end+1)=width;
% bvmL(:,end+1)=width;
% class2useTB(end+1)={'mean_PNwidth'};
%
%%%% split PN into small and large cells (not using)
% thm=3.4; %large PN width threshold
% thl=6.5; %australis width threshold
%
% %preallocate
% smallPN1=NaN*ml_analyzedTB; smallPN2=smallPN1; smallPN3=smallPN1; 
% medPN1=smallPN1; medPN2=smallPN1; medPN3=smallPN1;
% largePN1=smallPN1; largePN2=smallPN1; largePN3=smallPN1;
% 
% for i=1:length(PNwidth_opt)
%     ids=(PNwidth_opt(i).cell1<thm);
%     idm=(PNwidth_opt(i).cell1>=thm & PNwidth_opt(i).cell1<thl);
%     idl=(PNwidth_opt(i).cell1>=thl);
%     smallPN1(i)=sum(ids); medPN1(i)=sum(idm); largePN1(i)=sum(idl);
% 
%     ids=(PNwidth_opt(i).cell2<thm);
%     idm=(PNwidth_opt(i).cell2>=thm & PNwidth_opt(i).cell2<thl);
%     idl=(PNwidth_opt(i).cell2>=thl);
%     smallPN2(i)=sum(ids); medPN2(i)=sum(idm); largePN2(i)=sum(idl);
% 
%     ids=(PNwidth_opt(i).cell3<thm);
%     idm=(PNwidth_opt(i).cell3>=thm & PNwidth_opt(i).cell3<thl);
%     idl=(PNwidth_opt(i).cell3>=thl);
%     smallPN3(i)=sum(ids); medPN3(i)=sum(idm); largePN3(i)=sum(idl);
% end
% 
% %sum up by cell count
% cellsmL(:,end+1)=sum([smallPN1,2*smallPN2,3.5*smallPN3],2)./ml_analyzedTB;
% cellsmL(:,end+1)=sum([medPN1,2*medPN2,3.5*medPN3],2)./ml_analyzedTB;
% cellsmL(:,end+1)=sum([largePN1,2*largePN2,3.5*largePN3],2)./ml_analyzedTB;
% class2useTB(end+1)={'Pseudonitzschia_small'};
% class2useTB(end+1)={'Pseudonitzschia_medium'};
% class2useTB(end+1)={'Pseudonitzschia_large'};
% 
% %sum all PN
% cellsmL(:,end+1)=sum([cellsmL(:,contains(class2useTB,'Pseudonitzschia'))],2);
% cellsmL(:,end+1)=sum([cellsmL(:,contains(class2useTB,'Pseudonitzschia'))],2);
% 
% class2useTB(end+1)={'PN_cell'};

%%%% add biovol
class2useTB_b=class2useTB;
bvmL(:,end+1)=diatom_bvmL;
bvmL(:,end+1)=dino_bvmL;
bvmL(:,end+1)=dino_diat_ratio;
class2useTB_b(end+1)={'diatom'};
class2useTB_b(end+1)={'dino'};
class2useTB_b(end+1)={'dino_diat_ratio'};

%%%% round IFCB data to nearest minute and match with environmental data
dt=dateshift(dt,'start','minute'); 
TT = array2timetable(cellsmL,'RowTimes',dt,'VariableNames',class2useTB(1:end));
TT=addvars(TT,filelistTB,'Before',class2useTB(1));

TB = array2timetable(bvmL,'RowTimes',dt,'VariableNames',class2useTB_b(1:end));
TB=addvars(TB,filelistTB,'Before',class2useTB(1));

clearvars class2useTB th dt cellsmL filelistTB i idx ml_analyzedTB mdateTB smallPN1 smallPN2 smallPN3 largePN1 largePN2 largePN3

%% merge environmental data with IFCB data
P=synchronize(TT,T,'first');
PB=synchronize(TB,T,'first');

P.pDA_fgmL=P.pDA_pgmL.*0.001.*1000000; %convert to fg/mL
PB.pDA_fgmL=PB.pDA_pgmL.*0.001.*1000000; %convert to fg/mL

% make 2019 and 2021 datasets equivalent
P(P.LAT<40,:)=[]; % remove data south of 40 N
P(P.LAT>47.5 & P.LON>-124.7,:)=[]; %remove data from the Strait
P=movevars(P,{'LAT' 'LON' 'gap_km' 'sample_km' 'coast_km' 'TEMP' 'SAL' 'PCO2' 'FL' 'Nitrate_uM' 'Phosphate_uM' ...
    'Silicate_uM' 'P2N' 'S2N' 'chlA_ugL' 'pDA_pgmL' 'pDA_fgmL' 'PN_mcrspy'},'Before','filelistTB');
P(isnan(P.LAT),:)=[];

% make 2019 and 2021 datasets equivalent
% remove non biovolume
PB(PB.LAT<40,:)=[]; % remove data south of 40 N
PB(PB.LAT>47.5 & PB.LON>-124.7,:)=[]; %remove data from the Strait
PB=removevars(PB,{'gap_km' 'sample_km' 'coast_km' 'TEMP' 'SAL' 'PCO2' 'FL' 'Nitrate_uM' 'Phosphate_uM' ...
    'Silicate_uM' 'P2N' 'S2N' 'chlA_ugL' 'PN_mcrspy'});
PB=movevars(PB,{'LAT' 'LON'},'Before','filelistTB');
PB(isnan(PB.LAT),:)=[];

%%find toxicity/cell and toxicity/biovolume
% P.tox_small=P.pDA_fgmL./P.Pseudonitzschia_small;
% P.tox_medium=P.pDA_fgmL./P.Pseudonitzschia_medium;
% P.tox_large=P.pDA_fgmL./P.Pseudonitzschia_large;
P.tox_PNcell=P.pDA_fgmL./P.Pseudonitzschia;
PB.tox_PNbv=PB.pDA_fgmL./PB.Pseudonitzschia;

% P.tox_small(P.tox_small==Inf)=0;
% P.tox_medium(P.tox_medium==Inf)=0;
% P.tox_large(P.tox_large==Inf)=0;
P.tox_PNcell(P.tox_PNcell==Inf)=0;
PB.tox_PNbv(PB.tox_PNbv==Inf)=0;

%% format for .csv file
save('C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\summary_19-23Hake_cells.mat','P');
save('C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\summary_19-23Hake_biovolume.mat','PB');

clearvars E T idx X
