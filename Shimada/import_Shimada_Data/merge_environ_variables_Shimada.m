%% merge Shimada temperature data with lat lon coordinates
% load in lat lon coordinates and environmental variables from Shimada 
% intakes 2019, 2021, or 2023 data
% group data by the minute 
% Stephanie K. Moore modified merge_environ_variables_Shimada.m by Alexis D. Fischer

clear;
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\Shimada\';
addpath(genpath(filepath)); 
yr='2023'; %2019, 2021, or 2023 

%%%% lat lon coordinates
load([filepath 'Data\lat_lon_time_Shimada' yr],'TT');
%TT = retime(TT,'secondly','mean');
TT = retime(TT,'minutely','mean'); %aggregate data on 1 minute time bins

%% temperature and salinity
if strcmp(yr,'2019')
    %%%% temp & sal
    load([filepath 'Data\temperature_salinity_Shimada' yr],'dt','temp','sal');
    T=timetable(dt,temp,sal);
    TT = synchronize(TT,T,'first','mean');
    %figure; plot(dt,temp,'-',TT.DT,TT.temp,'-')    
    clearvars T dt temp sal

else
    %%%% temp
    load([filepath 'Data\temperature_Shimada' yr],'dt','temp');
    T=timetable(dt,temp);    
    TT = synchronize(TT,T,'first','mean');
    clearvars T dt temp 

    %%%% sal
    load([filepath 'Data\salinity_Shimada' yr],'dt','sal');
    T=timetable(dt,sal);    
    TT = synchronize(TT,T,'first','mean');
    clearvars T dt sal

end

%% fluorescence
load([filepath 'Data\fluorescence_Shimada' yr],'dt','fl');
T=timetable(dt,fl);
TT = synchronize(TT,T,'first','mean');
%figure; plot(dt,fl,'-',TT.DT,TT.fl,'-')

clearvars T dt fl id di idx i

%% fill missing data  
% TT.LAT = fillmissing(TT.LAT,'linear','SamplePoints',TT.DT,'MaxGap',seconds(2));
% TT.LON = fillmissing(TT.LON,'linear','SamplePoints',TT.DT,'MaxGap',seconds(2));
% TT.temp = fillmissing(TT.temp,'linear','SamplePoints',TT.DT,'MaxGap',seconds(2)); %temp and sal measured every 10 s in 2019
% TT.sal = fillmissing(TT.sal,'linear','SamplePoints',TT.DT,'MaxGap',seconds(3)); %sal measured every 3 s 
% TT.fl = fillmissing(TT.fl,'linear','SamplePoints',TT.DT,'MaxGap',seconds(2));

%% save merged data

%figure; plot(TT.LON,TT.LAT,'.k'); % test plot

TEMP=TT.temp; SAL=TT.sal; FL=TT.fl; LON=TT.LON; LAT=TT.LAT; DT=TT.DT; 

save([filepath 'Data\environ_Shimada' yr],'DT','LON','LAT','TEMP','SAL','FL');

