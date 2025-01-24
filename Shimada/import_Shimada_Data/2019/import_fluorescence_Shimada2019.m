%% import fluorometer and timestamps from 2019 Shimada cruise data
% process these data like a .csv file
% Stephanie K. Moore modified import_flourescence_Shimada2019.m by Alexis D. Fischer

clear;
filepath='C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; %USER
indir=[filepath 'Shimada\import_Shimada_Data\2019\2019_Fluorometer\']; %USER
outpath=[filepath 'Shimada\Data\']; %USER

addpath(genpath(outpath)); 
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\Misc-Functions\')); 
Tdir=dir([indir 'Fluorometer-Turner-*']);

dt=[];
fl=[];
for i=1:length(Tdir)

    if Tdir(i).bytes == 0 %do nothing if file is empty
    else
        name=Tdir(i).name;  
        indir=[Tdir(i).folder '/'];
        filename = [indir name];    
        disp(name);
        date=datetime(name(30:37),'InputFormat','yyyyMMdd');
    
        opts = delimitedTextImportOptions("NumVariables", 12);
        opts.DataLines = [1, Inf];
        opts.Delimiter = [" ", ","];
        opts.VariableNames = ["VarName1", "VarName2", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "VarName9", "Var10", "Var11", "Var12"];
        opts.SelectedVariableNames = ["VarName1", "VarName2", "VarName9"];
        opts.VariableTypes = ["datetime", "datetime", "char", "char", "char", "char", "char", "char", "double", "char", "char", "char"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        opts.ConsecutiveDelimitersRule = "join";
        opts = setvaropts(opts, ["Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var10", "Var11", "Var12"], "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var10", "Var11", "Var12"], "EmptyFieldRule", "auto");
        opts = setvaropts(opts, "VarName1", "InputFormat", "MM/dd/yyyy");
        opts = setvaropts(opts, "VarName2", "InputFormat", "HH:mm:ss.SSS");
        tbl = readtable(filename, opts);
        
        d = tbl.VarName1; d.Format='yyyy-MM-dd HH:mm:ss';      
        h = duration(string(tbl.VarName2));
        dti=d+h; 
        fli = tbl.VarName9;

        dt=[dt;dti];
        fl=[fl;fli];
    
        clearvars opts tbl dti fli h dur d

    end
end

%% remove outliers and missing values

idx=isnan(fl);
fl(idx)=[];
dt(idx)=[];
clear idx;

dt=dateshift(dt,'start','second');

%idx=fl<=0;
idx=isoutlier(fl,'percentiles',[0.01 99.99]);
figure; plot(dt,fl); hold on;
plot(dt(idx),fl(idx),'r+');
plot(dt(~idx),fl(~idx),'g'); 
dt(idx)=[]; fl(idx)=[];
clear idx 

%% save clean data

save([outpath 'fluorescence_Shimada2019'],'dt','fl');