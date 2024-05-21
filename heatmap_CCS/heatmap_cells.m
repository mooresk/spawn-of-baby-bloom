%% heatmap of IFCB-derived cell counts along CCS
% data options: all 24 IFCB classes
% option to plot scatter plot or heatmap (and change resolution)
% Shimada 2019 and 2021
% Fig 3 in Fischer et al. 2024
% A.D. Fischer, May 2024
%
clear;

%%%%USER
fprint = 1; % 1 = print; 0 = don't
yr = 2019; % 2019; 2021
option = 2; % 1 = Plot the individual data points; 2 = Grid the data
res = 0.15; % heatmap resolution: Coarser = 0.2; Finer = 0.1 % Set grid resolution (degrees)
unit = 0.06; % amount to subtract from latitude so does not overlap with map
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\'; % enter your path

% load in data
addpath(genpath('C:\Users\Stephanie.Moore\Documents\GitHub\')); % add new data to search path
load([filepath 'Data\summary_19-21Hake_cells'],'P'); %IFCB data
load([filepath 'Data\coast_CCS'],'coast'); %map
states=load([filepath 'Data\USwestcoast_pol']); %map

P(~(P.DT.Year==yr),:)=[]; %select year of data
lat=P.LAT; lon=P.LON-unit; dt=P.DT;  

%%%%USER enter data of interest
data=log10(P.Pseudonitzschia); label={'log PN (cells/mL)'}; name='PN'; cax=[0 2]; col=brewermap(256,'YlOrBr'); col(1:30,:)=[];
%data=P.Chaetoceros; label={'Chaetoceros (cells/mL)'}; name='CH'; cax=[0 500]; col=brewermap(256,'YlGn'); col(1:30,:)=[];

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
    exportgraphics(fig,[filepath 'heatmap_CCS\Figs\' name '_cells_CCS_heatmap_' num2str(yr) '.png'],'Resolution',100)    
end
hold off 
