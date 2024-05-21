%% compare size frequency histograms of particles imaged using different PMTB settings 
% used to evaluate if differences in IFCB detection settings affected
% example data is 2021 and 2022 Budd Inlet data
% A.D. Fischer, May 2024
clear

%%%%USER
fprint = 1; % 1 = print; 0 = don't
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; % enter your path

%%%% load in data and format dataset
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\')); % add new data to search path
load([filepath 'Data\eqdiam_biovol_2021'],'ESD','matdate','filecomment','runtype');
dt=datetime(matdate,'convertfrom','datenum');
idx=(contains(filecomment,'trigger')); ESD(idx)=[]; dt(idx)=[]; runtype(idx)=[]; % trigger is Emilie's discrete samples
idx=find(dt.Month==1 | dt.Month==2 | dt.Month==3 | dt.Month==10 | dt.Month==11 | dt.Month==12); ESD(idx)=[]; runtype(idx)=[]; 
idx=(contains(runtype,{'ALT','Alternative'})); E1a=ESD(idx); E1b=ESD(~idx);  

load([filepath 'Data\eqdiam_biovol_2022'],'ESD','matdate','filecomment','runtype');
dt=datetime(matdate,'convertfrom','datenum');
idx=(contains(filecomment,'trigger')); ESD(idx)=[]; dt(idx)=[]; runtype(idx)=[]; 
idx=find(dt.Month==1 | dt.Month==2 | dt.Month==3 | dt.Month==10 | dt.Month==11 | dt.Month==12); ESD(idx)=[]; runtype(idx)=[]; 
idx=(contains(runtype,{'ALT','Alternative'})); E2a=ESD(idx); E2b=ESD(~idx);  

%%%% uncomment to figure out how many ROIs in each dataset
% e1=length(cell2mat(E1b)); %3493761 %2483 samples
% e2=length(cell2mat(E2b)); %5873360 %7370 samples 

c=brewermap(2,'Set2'); %set colors

%%%% plot all particles
fig=figure('Units','inches','Position',[1 1 3.5 2],'PaperPositionMode','auto');
    histogram(cell2mat(E1b),0:1:70,'DisplayStyle','stairs','edgecolor',c(1,:)); hold on
    histogram(cell2mat(E2b),0:1:70,'DisplayStyle','stairs','edgecolor',c(2,:)); hold on
    set(gca,'xlim',[0 50],'fontsize',10,'tickdir','out');
    ylabel('particle count','fontsize',11)
    xlabel('ESD (\mum)')    
    legend('2021 (PMTB: .63, t.138)','2022 (PMTB: .60, t.125)'); legend boxoff;

if fprint
    exportgraphics(fig,[filepath 'size_histogram\Figs\Particle_size_distribution_PMTB.png'],'Resolution',100)    
end
hold off 
