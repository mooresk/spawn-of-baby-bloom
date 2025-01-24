%% import salinity and timestamps from 2023 Shimada cruise data
% process these data like a .csv file
% Stephanie K. Moore based on import_temperature_Shimada2021.m by Alexis D. Fischer

clear;
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; %USER
indir= 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\import_Shimada_Data\2023\Seawater System - TSG\'; %USER
outpath=[filepath 'Shimada\Data\']; %USER

addpath(genpath(outpath)); 
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\Misc-Functions\')); 
Tdir=dir([indir '*_TSG-2174150-3326-Message.RAW.log']); 

dt=[];
sal=[];

for i=1:length(Tdir)
    name=Tdir(i).name;    
    filename = [indir name];    
    disp(name);
    date=datetime(name(1:8),'InputFormat','yyyyMMdd');

    opts = delimitedTextImportOptions("NumVariables", 9, "Encoding", "UTF-8");
    opts.DataLines = [2, Inf];
    opts.Delimiter = [" ", ","];
    opts.VariableNames = ["ACQTimestampServerTimeInUTC", "MessageID", "DataValueForTSG21741503326Message", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9"];
    opts.VariableTypes = ["string", "categorical", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts.ConsecutiveDelimitersRule = "join";
    opts = setvaropts(opts, "ACQTimestampServerTimeInUTC", "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["ACQTimestampServerTimeInUTC", "MessageID"], "EmptyFieldRule", "auto");
    tbl = readtable(filename, opts);   

    dti = datetime(tbl.ACQTimestampServerTimeInUTC,"InputFormat",'yyyy-MM-dd''T''HH:mm:ss.SSSSSSS''Z');
    sali = tbl.VarName6;
   
    dti.Format='yyyy-MM-dd HH:mm:ss';           
    dt=[dt;dti];
    sal=[sal;sali];
    clearvars opts tbl dti sali h dur d

end

%% remove missing values and outliers

idx=isnan(sal);
sal(idx)=[];
dt(idx)=[];

idx=isnat(dt);
dt(idx)=[];
sal(idx)=[];

dt = dateshift(dt,'start','second');

idx=sal>36  | isoutlier(sal,'percentiles',[0.05 100]);
figure; plot(dt,sal); hold on;
plot(dt(idx),sal(idx),'r+');
dt(idx)=[]; sal(idx)=[]; 
clear idx 

%% save clean data

save([outpath 'salinity_Shimada2023'],'dt','sal');