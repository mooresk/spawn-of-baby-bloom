%% import lat lon and timestamps from 2019 Shimada cruise GPS data
% The ship records GPS data every second and writes it to a text file for each day. 
% process these data like a .csv file
% Stephanie K. Moore modified import_latlontime_SciGPS2019.m by Alexis D. Fischer

clear;
filepath='C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; %USER
indir=[filepath 'Shimada\import_Shimada_Data\2019\GPS_GPGGA\']; %USER
outpath=[filepath 'Shimada\Data\']; %USER

addpath(genpath(outpath)); 
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\Misc-Functions\')); 
Tdir=dir([indir 'SciGPS-GPGGA_*']);

DT=[];
LAT=[];
LON=[];

for i=1:length(Tdir)
    name=Tdir(i).name;
    filename = [indir name];
    disp(name);
  %  date=datetime(name(14:21),'InputFormat','yyyyMMdd');

    opts = delimitedTextImportOptions("NumVariables", 17);
    opts.DataLines = [1, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["VarName1", "VarName2", "Var3", "Var4", "VarName5", "Var6", "VarName7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17"];
    opts.SelectedVariableNames = ["VarName1", "VarName2", "VarName5", "VarName7"];
    opts.VariableTypes = ["datetime", "datetime", "char", "char", "double", "char", "double", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, ["Var3", "Var4", "Var6", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["Var3", "Var4", "Var6", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, "VarName1", "InputFormat", "MM/dd/yyyy");
    opts = setvaropts(opts, "VarName2", "InputFormat", "HH:mm:ss.SSS");

    tbl = readtable(filename, opts);

    d = tbl.VarName1; d.Format='yyyy-MM-dd HH:mm:ss';      
    h = duration(string(tbl.VarName2));
    dti=d+h; 
    lati = tbl.VarName5;
    loni = tbl.VarName7;

    DT=[DT;dti];
    LAT=[LAT;lati];
    LON=[LON;loni];    

    clearvars opts tbl lati loni dti filename date name d h

end

%% convert lat & lon to degrees

LAT=dm2degrees([floor(LAT/100),rem(LAT,100)]); %needs mapping toolbox
LON=-dm2degrees([floor(LON/100),rem(LON,100)]);

%% find and remove outliers

TT=timetable(DT,LAT,LON);

idx=TT.LAT<=32 | TT.LAT>=50;
TT(idx,:)=[]; clear idx
idx=TT.LON<=-129 | TT.LON>=-120;
TT(idx,:)=[]; clear idx

figure; plot(TT.LON,TT.LAT,'.k'); %sanity check plot

%%
save([outpath 'lat_lon_time_Shimada2019'],'TT');
