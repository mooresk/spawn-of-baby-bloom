%% Edit csv file on dashboard to add lat and lon for 2019-2023 surveys
clear;

filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\';
ifcbpath = 'C:\Users\Stephanie.Moore\Documents\GitHub\ifcb-data-science\';
addpath(genpath(filepath)); 
addpath(genpath(ifcbpath));

%% Import dashboard metadata from text file: C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\nwfsc_pacific_hake_survey.csv
% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 16);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["dataset", "pid", "sample_time", "ifcb", "ml_analyzed", "latitude", "longitude", "depth", "cruise", "cast", "niskin", "sample_type", "n_images", "comment_summary", "trigger_selection", "skip"];
opts.VariableTypes = ["categorical", "string", "string", "double", "double", "string", "string", "string", "string", "string", "string", "string", "double", "string", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["pid", "sample_time", "latitude", "longitude", "depth", "cruise", "cast", "niskin", "sample_type", "comment_summary"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["dataset", "pid", "sample_time", "latitude", "longitude", "depth", "cruise", "cast", "niskin", "sample_type", "comment_summary"], "EmptyFieldRule", "auto");

% Import the data
nwfscpacifichakesurvey = readtable("C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\nwfsc_pacific_hake_survey.csv", opts);

% Clear temporary variables
clear opts

%% Load filelistTB and mdateTB variables from 2019-2023 IFCB summary file
load([ifcbpath 'IFCB-Data\Shimada\class\summary_biovol_allTB.mat'],'filelistTB','mdateTB');

% Format date, round to nearest minute, and convert to timetable
dt=datetime(mdateTB,'convertfrom','datenum'); dt.Format='yyyy-MM-dd HH:mm:ss';        
dt = dateshift(dt,'start','minute'); 

TT = timetable(dt,filelistTB);

%% Load and merge 2019, 2021 and 2023 lat and lon data
S19 = load([filepath 'Shimada\Data\environ_Shimada2019'],'DT','LON','LAT');
S21 = load([filepath 'Shimada\Data\environ_Shimada2021'],'DT','LON','LAT');
S23 = load([filepath 'Shimada\Data\environ_Shimada2023'],'DT','LON','LAT');
DT = [S19.DT;S21.DT;S23.DT]; LON = [S19.LON;S21.LON;S23.LON]; LAT = [S19.LAT;S21.LAT;S23.LAT];

T = timetable(DT,LAT,LON);

%% Merge lat and lon data with IFCB data
TM = synchronize(TT,T,'first');

%% Get lan and lon for matching files in nwfsc_pacific_hake_survey
for i = 1:height(nwfscpacifichakesurvey)
    f = strmatch(nwfscpacifichakesurvey.pid{i},TM.filelistTB,"exact");
    nwfscpacifichakesurvey.latitude(i) = TM.LAT(f);
    nwfscpacifichakesurvey.longitude(i) = TM.LON(f);
    clear f
end
clear i

%% format for .csv file
%%%% save edited file
writetable(nwfscpacifichakesurvey,'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\Data\nwfsc_pacific_hake_survey2.csv');