%% import lat lon and timestamps from 2023 Shimada cruise GPS data
% The ship records GPS data every second and writes it to a text file for each day. 
% process these data like a .csv file
% Stephanie K. Moore modified import_temperature_Shimada2023.m by Alexis D. Fischer
 
clear;
filepath='C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; %USER
indir=[filepath 'Shimada\import_Shimada_Data\2023\GPS-Science - GP170\']; %USER
outpath=[filepath 'Shimada\Data\']; %USER

addpath(genpath(outpath)); 
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\bloom-baby-bloom\Misc-Functions\')); 
LATdir=dir([indir '*_SciGPS-Derived-DD-Lat-Message.CALC.log']);
LONdir=dir([indir '*_SciGPS-Derived-DD-Lon-Message.CALC.log']);

DT=[];
DT_LON=[];
LAT=[];
LON=[];

for i=1:length(LATdir)
    namelat=LATdir(i).name;
    namelon=LONdir(i).name;    
    filelat = [indir namelat];
    filelon = [indir namelon];    
    disp(namelat);
    date=datetime(namelat(1:8),'InputFormat','yyyyMMdd');

    opts = delimitedTextImportOptions("NumVariables", 5, "Encoding", "UTF-8");
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["ACQTimestampServerTimeInUTC", "MessageID", "DataValueForSciGPSDerivedDDLatMessage", "VarName4", "VarName5"];
    opts.VariableTypes = ["string", "string", "categorical", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, ["ACQTimestampServerTimeInUTC", "MessageID"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["ACQTimestampServerTimeInUTC", "MessageID", "DataValueForSciGPSDerivedDDLatMessage"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, "VarName5", "TrimNonNumeric", true);
    opts = setvaropts(opts, "VarName5", "ThousandsSeparator", ",");

    tbl = readtable(filelat, opts);    
    dt = datetime(tbl.ACQTimestampServerTimeInUTC,"InputFormat",'yyyy-MM-dd''T''HH:mm:ss.SSSSSSS''Z');
    dt.Format='yyyy-MM-dd HH:mm:ss';           
    lat = tbl.VarName4;
    
    tbl = readtable(filelon, opts);         
    dt_lon = datetime(tbl.ACQTimestampServerTimeInUTC,"InputFormat",'yyyy-MM-dd''T''HH:mm:ss.SSSSSSS''Z');
    dt_lon.Format='yyyy-MM-dd HH:mm:ss';           
    lon = tbl.VarName4;  

    if length(lat) == length(lon)
    else
        disp('different length lat and lon files')
    end

    DT=[DT;dt];
    DT_LON=[DT_LON;dt_lon];
    LAT=[LAT;lat];
    LON=[LON;lon];    
    clearvars opts tbl fileid lat lon dt dt_lon name date

end

T_LAT=timetable(DT,LAT); 
T_LON=timetable(DT_LON,LON); 

TT = synchronize(T_LAT,T_LON,'intersection');

%% find and remove outliers

idx=TT.LAT<=32 | TT.LAT>=50;
TT(idx,:)=[]; clear idx
idx=TT.LON<=-129 | TT.LON>=-120;
TT(idx,:)=[]; clear idx

figure; plot(TT.LON,TT.LAT,'.k'); %sanity check plot

%% save clean data

save([outpath 'lat_lon_time_Shimada2023'],'TT');
