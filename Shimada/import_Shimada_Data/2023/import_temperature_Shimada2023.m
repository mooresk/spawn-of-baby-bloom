%% import temperature and timestamps from 2023 Shimada cruise data
% process these data like a .csv file
% Stephanie K. Moore based on import_temperature_Shimada2021.m by Alexis D. Fischer

clear;
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; %USER
indir= 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\import_Shimada_Data\2023\Seawater System - TSG\'; %USER
outpath=[filepath 'Shimada\Data\']; %USER

addpath(genpath(outpath)); 
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\Misc-Functions\')); 
Tdir=dir([indir '*_TSG21-SBE38-Temp-F-Message.CALC.log']);

dt=[];
temp=[];

for i=1:length(Tdir)
    name=Tdir(i).name;    
    filename = [indir name];    
    disp(name);
    date=datetime(name(1:8),'InputFormat','yyyyMMdd');
    
    opts = delimitedTextImportOptions("NumVariables", 5, "Encoding", "UTF-8");
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["ACQTimestampServerTimeInUTC", "MessageID", "DataValueForTSG21SBE38TempFMessage", "VarName4", "VarName5"];
    opts.VariableTypes = ["string", "categorical", "categorical", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "ACQTimestampServerTimeInUTC", "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["ACQTimestampServerTimeInUTC", "MessageID", "DataValueForTSG21SBE38TempFMessage"], "EmptyFieldRule", "auto");
    tbl = readtable(filename, opts);
    
    dti = datetime(tbl.ACQTimestampServerTimeInUTC,"InputFormat",'yyyy-MM-dd''T''HH:mm:ss.SSSSSSS''Z');
    dti.Format='yyyy-MM-dd HH:mm:ss';        
    dt=[dt;dti];
    tempi = tbl.VarName5;
    temp=[temp;tempi];
    clearvars opts tbl dti tempi

end

%% remove missing values and outliers

idx=isnan(temp);
temp(idx)=[];
dt(idx)=[];

idx=isnat(dt);
dt(idx)=[];
temp(idx)=[];

dt = dateshift(dt,'start','second');

idx=isoutlier(temp,'percentiles',[0.05 99.95]);
figure; plot(dt,temp); hold on;
plot(dt(idx),temp(idx),'r+');
dt(idx)=[]; temp(idx)=[]; 
clear idx 

%% save clean data

save([outpath 'temperature_Shimada2023'],'dt','temp');
