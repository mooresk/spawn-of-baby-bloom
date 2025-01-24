%% import salinity and timestamps from 2021 Shimada cruise data
% process these data like a .csv file
% Stephanie K. Moore modified import_salinity_Shimada2021.m by Alexis D. Fischer

clear;
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; %USER
indir= 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\import_Shimada_Data\2021\Seawater System - TSG\'; %USER
outpath=[filepath 'Shimada\Data\']; %USER

addpath(genpath(outpath)); 
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\Misc-Functions\')); 
Tdir=dir([indir '*_TSG-4554924-0289-Message.RAW.log']);

dt=[];
sal=[];

for i=1:length(Tdir)
    name=Tdir(i).name;    
    filename = [indir name];    
    disp(name);
    date=datetime(name(1:8),'InputFormat','yyyyMMdd');

    if date < datetime(2021,09,03)
        opts = delimitedTextImportOptions("NumVariables", 12, "Encoding", "UTF-8");
        opts.DataLines = [2, Inf];
        opts.Delimiter = [",", "="];
        opts.VariableNames = ["ACQTimestampServerTimeInUTC", "MessageID", "DataValueForTSG45549240289Message", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12"];
        opts.VariableTypes = ["string", "categorical", "categorical", "double", "categorical", "double", "categorical", "double", "categorical", "double", "categorical", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        opts.ConsecutiveDelimitersRule = "join";
        opts = setvaropts(opts, "ACQTimestampServerTimeInUTC", "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["ACQTimestampServerTimeInUTC", "MessageID", "DataValueForTSG45549240289Message", "VarName5", "VarName7", "VarName9", "VarName11"], "EmptyFieldRule", "auto");
        opts = setvaropts(opts, ["VarName4", "VarName6", "VarName8", "VarName10", "VarName12"], "ThousandsSeparator", ",");
        tbl = readtable(filename, opts);   
    
        dti=datetime(tbl.ACQTimestampServerTimeInUTC,"InputFormat",'yyyy-MM-dd HH:mm:ss''Z');
        dti.Format='yyyy-MM-dd HH:mm:ss';     
        sali = tbl.VarName8;

    else
        opts = delimitedTextImportOptions("NumVariables", 12, "Encoding", "UTF-8");
        opts.DataLines = [2, Inf];
        opts.Delimiter = [" ", ",", "="];
        opts.VariableNames = ["ACQ", "Timestamp", "Server", "Time", "in", "UTC", "MessageID", "Data", "Value", "For", "TSG45549240289Message", "VarName12"];
        opts.VariableTypes = ["string", "categorical", "categorical", "double", "categorical", "double", "categorical", "double", "categorical", "double", "categorical", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        opts.ConsecutiveDelimitersRule = "join";
        opts = setvaropts(opts, "ACQ", "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["ACQ", "Timestamp", "Server", "in", "MessageID", "Value", "TSG45549240289Message"], "EmptyFieldRule", "auto");
        opts = setvaropts(opts, ["Time", "UTC", "Data", "For", "VarName12"], "ThousandsSeparator", ",");
        tbl = readtable(filename, opts);
         
        dti = datetime(tbl.ACQ,"InputFormat",'yyyy-MM-dd''T''HH:mm:ss.SSSSSSS''Z');
        dti.Format='yyyy-MM-dd HH:mm:ss';           
        sali = tbl.Data;
    end
    
    dt=[dt;dti];
    sal=[sal;sali];
    clearvars opts tbl dti sali h dur d

end

%% remove missing values and outliers

idx=isnan(sal);
sal(idx)=[];
dt(idx)=[]; clear idx

idx=isnat(dt);
dt(idx)=[];
sal(idx)=[]; clear idx

dt = dateshift(dt,'start','second');

idx=sal>36  | isoutlier(sal,'percentiles',[0.05 100]);
figure; plot(dt,sal); hold on;
plot(dt(idx),sal(idx),'r+');
dt(idx)=[]; sal(idx)=[]; 
clear idx 

%% save clean data

save([outpath 'salinity_Shimada2021'],'dt','sal');