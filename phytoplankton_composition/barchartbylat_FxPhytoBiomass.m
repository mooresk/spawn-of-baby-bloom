%% plot fx of phytoplankton community composition biomass by latitude using IFCB data
% Shimada 2019 and 2021
% A.D. Fischer, May 2024
%
clear;

%%%%USER
fprint = 1; % 1 = print; 0 = don't
yr=2019; % 2019; 2021
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; % enter your path

% load in data
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\')); % add new data to search path
load([filepath 'Data\summary_19-21Hake_biovolume'],'PB');
PB(~(PB.DT.Year==yr),:)=[]; %select year of data
names=PB.Properties.VariableNames(4:23);
bvmL=timetable2table(PB(:,4:23));
bvmL(:,1)=[];
bvmL=table2array(bvmL);
lat=PB.LAT;

% Create grid
res = 0.2; %Set grid resolution (degrees)
lat_grid = min(lat):res:max(lat)+.5;
ny = length(lat_grid);
nx = size(bvmL,2);

% Average data on grid
data_grid = nan(ny,nx); 
for i = 1:nx
    data=bvmL(:,i);
    for j = 1:ny
        data_grid(j,i) = mean(data(lat>=lat_grid(j)-res/2 & lat<lat_grid(j)+res/2),'omitnan');
    end
end

% calculate fractions of bvmL
total=sum(data_grid,2);
fx = data_grid./total;

% reorder by highest fraction
col=brewermap(length(names),'Spectral');
rng("default"); idx=randperm(length(names));
col=col(idx,:);

t=sum(fx,1,'omitnan');
[~,i]=sort(t,'descend');
fxi=fx(:,i);
names=names(i);
col=col(i,:);

% find the dominant phytoplankton
fx_2=(fxi);
fx_PN=(fxi(:,idx));

clearvars i j nx ny data_grid total res lat data bvmL t

fig=figure; set(gcf,'color','w','Units','inches','Position',[1 1 6 5]); 
b=bar(lat_grid,fxi,'stacked','EdgeColor','none'); hold on;
for i=1:length(b)
    set(b(i),'FaceColor',col(i,:)); hold on;
end

set(gca,'ylim',[0 1],'ytick',.1:.1:1,'xlim',[39.9 49],'xtick',40:1:49,...
    'fontsize',9,'yaxislocation','right');
legend(names,'Location','EastOutside','fontsize',9);legend boxoff; hold on;
ylabel('fx of sample biomass','fontsize',10); hold on;
view([90 -90])

if fprint
    exportgraphics(fig,[filepath 'phytoplankton_composition\Figs\FxPhytoCommunity_CCS_' num2str(yr) '.png'],'Resolution',100)    
end
hold off 
