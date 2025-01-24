%% import salinity, temperature, and timestamps from 2019 Shimada cruise data
% use TSG45 (not TSG21)
% process these data like a .csv file
% Stephanie K. Moore modified import_temperature_salinity_Shimada2019.m by Alexis D. Fischer

clear;
filepath='C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; %USER
indir=[filepath 'Shimada\import_Shimada_Data\2019\Seawater System - TSG\']; %USER
outpath=[filepath 'Shimada\Data\']; %USER

addpath(genpath(outpath)); 
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\Misc-Functions\')); 
Tdir=dir([indir 'TSG45-*']);

dt=[];
temp=[];
sal=[];
for i=1:length(Tdir)
    if Tdir(i).bytes == 0 %do nothing if file is empty
    else
        name=Tdir(i).name;    
        filename = [indir name];    
        disp(name);
        date=datetime(name(15:22),'InputFormat','yyyyMMdd');
    
        opts = delimitedTextImportOptions("NumVariables", 15);
        opts.DataLines = [1, Inf];
        opts.Delimiter = [" ", ","];
        opts.VariableNames = ["VarName1", "VarName2", "Var3", "VarName4", "Var5", "Var6", "Var7", "Var8", "Var9", "VarName10", "Var11", "Var12", "Var13", "Var14", "VarName15"];
        opts.SelectedVariableNames = ["VarName1", "VarName2", "VarName4", "VarName10", "VarName15"];
        opts.VariableTypes = ["datetime", "datetime", "char", "double", "char", "char", "char", "char", "char", "double", "char", "char", "char", "char", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        opts = setvaropts(opts, ["Var3", "Var5", "Var6", "Var7", "Var8", "Var9", "Var11", "Var12", "Var13", "Var14"], "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["Var3", "Var5", "Var6", "Var7", "Var8", "Var9", "Var11", "Var12", "Var13", "Var14"], "EmptyFieldRule", "auto");
        opts = setvaropts(opts, "VarName1", "InputFormat", "MM/dd/yyyy");
        opts = setvaropts(opts, "VarName2", "InputFormat", "HH:mm:ss.SSS");
        tbl = readtable(filename, opts);
       
        % Convert to output type
        d = tbl.VarName1; d.Format='yyyy-MM-dd HH:mm:ss';      
        h = duration(string(tbl.VarName2));
        dti=d+h; 
    
        ti = tbl.VarName15; %sbe38 (t2) which is mounted before the pump to the sea water system. external temperature
        sali = tbl.VarName10;
    
        dt=[dt;dti];
        sal=[sal;sali];
        temp=[temp;ti];
        
        clearvars opts tbl dti ti sali h dur d
    end
    
end

%% remove missing values 

idx=isnan(temp) & isnan(sal);
temp(idx)=[];
sal(idx)=[];
dt(idx)=[];
clear idx
dt=dateshift(dt,'start','second');

%% remove temp outliers

%idx=isoutlier(temp,'percentiles',[0.5 99.5]);
idx=temp<2;
figure; plot(dt,temp); hold on;
plot(dt(idx),temp(idx),'r+');
dt(idx)=[]; temp(idx)=[]; sal(idx)=[];
clear idx 

%% remove sal outliers

idx=isoutlier(sal,'percentiles',[0.05 100]);
figure; plot(dt,sal); hold on;
plot(dt(idx),sal(idx),'r+');
dt(idx)=[]; temp(idx)=[]; sal(idx)=[];
clear idx 

%% save clean data

save([outpath 'temperature_salinity_Shimada2019'],'dt','temp','sal');