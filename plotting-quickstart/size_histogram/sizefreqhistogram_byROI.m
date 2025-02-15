%% compare size frequency histograms of particles imaged in 2019, 2021, and 2023 
% used to evaluate differences in IFCBs and IFCB detection settings
% the eqdiam_biovol_yr.mat file containing the ESD data is produced by the
% summarize_features_biovol_size_byROI.m script in the IFCB-Tools folder
% Stephanie K. Moore modified script by A.D. Fischer
clear

%%%%USER
fprint = 0; % 1 = print; 0 = don't
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; % enter your path
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\')); % add new data to search path

%%%% load in summary biovolume data for all years
load([filepath 'Shimada\Data\summary_19-23Hake_biovolume']);

%%%% load in ESD data for each year and format dataset
load([filepath 'Shimada\Data\eqdiam_biovol_2019'],'ESD','matdate');
ESD19 = ESD;
dt19 = datetime(matdate,'convertfrom','datenum');
clearvars ESD matdate

load([filepath 'Shimada\Data\eqdiam_biovol_2021'],'ESD','matdate');
ESD21 = ESD;
dt21 = datetime(matdate,'convertfrom','datenum');
clearvars ESD matdate

load([filepath 'Shimada\Data\eqdiam_biovol_2023'],'ESD','matdate');
ESD23 = ESD;
dt23 = datetime(matdate,'convertfrom','datenum');
clearvars ESD matdate

%%%% uncomment to figure out how many ROIs in each dataset
% e19=length(cell2mat(ESD19)); %1359747 %1607 samples
% e21=length(cell2mat(ESD21)); %1438887 %2890 samples 
% e23=length(cell2mat(ESD23)); %1725883 %2778 samples 

%% filter for samples with matching krill data

ESD_all = [ESD19; ESD21; ESD23];
dt_all = [dt19; dt21; dt23];

dts = dateshift(dt_all,'start','minute'); %round IFCB data to nearest minute to match with summary file

dt = [];
ESD = [];
for i = 1:length(dts)
    idx = find(dts(i)==PB.DT);
    if idx
        dt = [dt; dts(idx)];
        ESD = [ESD; ESD_all(idx)];
    end
end


%% get ml analyzed

ifcbpath = 'C:\Users\Stephanie.Moore\Documents\GitHub\ifcb-data-science\';
addpath(genpath(ifcbpath));

load([ifcbpath 'IFCB-Data\Shimada\class\summary_biovol_allTB.mat'],'mdateTB','ml_analyzedTB');

dtts = datetime(mdateTB,'convertfrom','datenum'); dtts.Format = 'yyyy-MM-dd HH:mm:ss';        
dtts = dateshift(dtts,'start','minute'); %round IFCB data to nearest minute to match with summary file

dtt = [];
mlAnalyzed = [];
for i = 1:length(dtts)
    idx = find(dtts(i)==PB.DT);
    if idx
        dtt = [dtt; dtts(idx)];
        mlAnalyzed = [mlAnalyzed; ml_analyzedTB(idx)];
    end
end

%% create timetable

PESD = timetable(dt,ESD,mlAnalyzed);

%% plot particles

tr19 = timerange(datetime(2019,1,1),datetime(2019,12,31));
tr21 = timerange(datetime(2021,1,1),datetime(2021,12,31));
tr23 = timerange(datetime(2023,1,1),datetime(2023,12,31));
PESD19 = PESD(tr19,:);
PESD21 = PESD(tr21,:);
PESD23 = PESD(tr23,:);
vol19 = sum(PESD19.mlAnalyzed);
vol21 = sum(PESD21.mlAnalyzed);
vol23 = sum(PESD23.mlAnalyzed);


h19 = histogram(cell2mat(PESD19.ESD),0:1:70);
hh19 = h19.Values/vol19;
h21 = histogram(cell2mat(PESD21.ESD),0:1:70);
hh21 = h21.Values/vol21;
h23 = histogram(cell2mat(PESD23.ESD),0:1:70);
hh23 = h23.Values/vol23;
bins = h23.BinEdges;

close all

fig=figure('Units','inches','Position',[1 1 3.5 2],'PaperPositionMode','auto');
    histogram('BinEdges',bins,'BinCounts',hh19,'DisplayStyle','stairs','edgecolor','g'); hold on
    histogram('BinEdges',bins,'BinCounts',hh21,'DisplayStyle','stairs','edgecolor','y'); hold on
    histogram('BinEdges',bins,'BinCounts',hh23,'DisplayStyle','stairs','edgecolor','r'); hold on
    set(gca,'xlim',[0 50],'fontsize',10,'tickdir','out');
    ylabel('particles per mL','fontsize',11)
    xlabel('ESD (\mum)')    
    legend('g=2019','y=2021','r=2023'); legend boxoff;


%%%% plots particles but does not standardize for volume analyzed
% fig=figure('Units','inches','Position',[1 1 3.5 2],'PaperPositionMode','auto');
%     histogram(cell2mat(PESD19.ESD),0:1:70,'DisplayStyle','stairs','edgecolor','g'); hold on
%     histogram(cell2mat(PESD21.ESD),0:1:70,'DisplayStyle','stairs','edgecolor','y'); hold on
%     histogram(cell2mat(PESD23.ESD),0:1:70,'DisplayStyle','stairs','edgecolor','r'); hold on
%     set(gca,'xlim',[0 50],'fontsize',10,'tickdir','out');
%     ylabel('particle count','fontsize',11)
%     xlabel('ESD (\mum)')    
%     legend('g=2019','y=2021','r=2023'); legend boxoff;

%CHANGE FOR SPAWN OF BABY BLOOM
% if fprint
%     exportgraphics(fig,[filepath 'plotting-quickstart\size_histogram\Figs\Particle_size_distribution_PMTB.png'],'Resolution',100)    
% end
% hold off 
