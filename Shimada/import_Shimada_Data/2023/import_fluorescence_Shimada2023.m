%% import fluorometer and timestamps from 2023 Shimada cruise data
% process these data like a .csv file
% Stephanie K. Moore based on import_flourescence_Shimada2021.m by Alexis D. Fischer

clear;
filepath='C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; %USER
indir=[filepath 'Shimada\import_Shimada_Data\2023\Seawater System - Fluorometer\']; %USER
outpath=[filepath 'Shimada\Data\']; %USER

addpath(genpath(outpath)); 
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\Misc-Functions\')); 
Tdir=dir([indir '*_Fluorometer-6993RTD-Message.RAW.log']);

dt=[];
fl=[];

for i=1:length(Tdir)
    name=Tdir(i).name;    
    filename = [indir name];    
    disp(name);
    date=datetime(name(1:8),'InputFormat','yyyyMMdd');

    opts = delimitedTextImportOptions("NumVariables", 11, "Encoding", "UTF-8");
    opts.DataLines = [2, Inf];
    opts.Delimiter = [" ", ",", "="];
    opts.VariableNames = ["ACQ", "Timestamp", "Server", "Time", "in", "UTC", "MessageID", "Data", "Value", "For", "Fluorometer6993RTDMessage"];
    opts.VariableTypes = ["string", "categorical", "double", "double", "categorical", "datetime", "datetime", "double", "categorical", "double", "categorical"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts.ConsecutiveDelimitersRule = "join";
    opts = setvaropts(opts, "ACQ", "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["ACQ", "Timestamp", "in", "Value", "Fluorometer6993RTDMessage"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, "UTC", "InputFormat", "MM/dd/yy", "DatetimeFormat", "preserveinput");
    opts = setvaropts(opts, "MessageID", "InputFormat", "HH:mm:ss", "DatetimeFormat", "preserveinput");
    tbl = readtable(filename, opts);

    dti = datetime(tbl.ACQ,"InputFormat",'yyyy-MM-dd''T''HH:mm:ss.SSSSSSS''Z');
    dti.Format='yyyy-MM-dd HH:mm:ss';          
    fli = tbl.Data;

    dt=[dt;dti];
    fl=[fl;fli];
    clearvars opts tbl dti fli h dur
end

%% remove outliers and missing values

idx=isnan(fl);
fl(idx)=[];
dt(idx)=[];
clear idx;

dt=dateshift(dt,'start','second');

idx=fl>500;
fl(idx)=[];
dt(idx)=[];
clear idx;

idx=isoutlier(fl,'percentiles',[0.01 99.99]);
figure; plot(dt,fl); hold on;
plot(dt(idx),fl(idx),'r+');
plot(dt(~idx),fl(~idx),'g'); 
dt(idx)=[]; fl(idx)=[];
clear idx 

%% save clean data

save([outpath 'fluorescence_Shimada2023'],'dt','fl');
