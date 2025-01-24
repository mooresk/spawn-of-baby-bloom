%% heatmap of IFCB-derived biovolume along CCS
% data options: all 24 IFCB classes, diatoms, dinoflagellates, or 
%   ratio = log10(dino biovolume/diatom biovolume) per Isles 2020
% option to plot scatter plot or heatmap (and change resolution)
% Shimada 2019, 2021, 2023
% S.K. Moore modified script by A.D. Fischer
%
clear;

%%%%USER
fprint = 1; % 1 = print; 0 = don't
yr = 2023; % 2019; 2021; 2023
option = 2; % 1 = Plot the individual data points; 2 = Grid the data
res = 0.15; % heatmap resolution: Coarser = 0.2; Finer = 0.1 % Set grid resolution (degrees)
unit = 0.06; % amount to subtract from latitude so does not overlap with map
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; % enter your path

% load in data
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\')); % add new data to search path
load([filepath 'Shimada\Data\summary_19-23Hake_biovolume'],'PB'); %IFCB data
load([filepath 'Shimada\Data\coast_CCS'],'coast'); %map
states=load([filepath 'Shimada\Data\USwestcoast_pol']); %map

PB(~(PB.DT.Year==yr),:)=[]; %select year of data
lat=PB.LAT; lon=PB.LON-unit; dt=PB.DT;  

%%%%USER enter data of interest
%data=PB.dino_diat_ratio; label={'log(dino:diat)'}; name='ratio'; cax=[-2 2]; col=flipud(brewermap(256,'PiYG'));
data=PB.Thalassiosira; label={'Thalassiosira biovol/mL'}; name='TH'; cax=[0 100000]; col=(brewermap(256,'Reds'));

%%%% plot
fig=figure; set(gcf,'color','w','Units','inches','Position',[1 1 2 4.7]); 

if option==1    
    scatter(lon,lat,15,data,'o','filled');  hold on
else
    % Create grid
    lon_grid = min(lon):res:max(lon)+.5;
    lat_grid = min(lat):res:max(lat)+.5;
    nx = length(lon_grid);
    ny = length(lat_grid);    
    % Average data on grid
    data_grid = nan(nx,ny);
    for ii = 1:nx
        for jj = 1:ny
            data_grid(ii,jj) = mean(data(lon>=lon_grid(ii)-res/2 & lon<lon_grid(ii)+res/2 & lat>=lat_grid(jj)-res/2 & lat<lat_grid(jj)+res/2),'omitnan');
        end
    end    
    [lat_plot,lon_plot] = meshgrid(lat_grid,lon_grid);
    pcolor(lon_plot-res/2,lat_plot-res/2,data_grid); % have to shift lat/lon for pcolor with flat shading     
    shading flat; hold on;
    clearvars lat_plot lon_plot ii jj nx ny lon_grid lat_grid data_grid res
end 

colormap(col); clim(cax);
axis([min(lon) max(lon) min(lat) max(lat)]);
h=colorbar('northoutside'); hp=get(h,'pos');    
set(h,'pos',hp,'xaxisloc','top','fontsize',9,'tickdir','out');
xtickangle(0); hold on;    
colorTitleHandle = get(h,'Title');
set(colorTitleHandle,'String',label,'fontsize',11);

% Plot map
fillseg(coast); dasp(42); hold on;
plot(states.lon,states.lat,'k'); hold on;
set(gca,'ylim',[39.9 49],'xlim',[-126.6 -123.5],'xtick',-127:2:-124,...
    'xticklabel',{'127 W','125 W'},'yticklabel',...
    {'40 N','41 N','42 N','43 N','44 N','45 N','46 N','47 N','48 N','49 N'},...
    'fontsize',9,'tickdir','out','box','on','xaxisloc','bottom');

if fprint
    exportgraphics(fig,[filepath 'plotting-quickstart\heatmap_CCS\Figs\' name '_bv_CCS_heatmap_' num2str(yr) '.png'],'Resolution',100)    
end
hold off 
