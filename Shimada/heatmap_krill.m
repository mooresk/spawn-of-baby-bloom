%% heatmap of mean NASC matched to IFCB samples along CCS
% data options: NASC
% option to plot scatter plot or heatmap (and change resolution)
% option to plot diatom biovolume
% Shimada 2019, 2021, & 2023
%
close; 
clear;

%%%%USER
fprint = 0; % 1 = print; 0 = don't
yr = 2019:2:2023; % 2019; 2021; 2023
option = 1; % 1 = Plot the individual NASC data points; 2 = Grid the data
option_PB = 2; % 1 = Plot the individual dino:diat data points; 2 = Grid the data
res = 0.15; % heatmap resolution: Coarser = 0.2; Finer = 0.1 % Set grid resolution (degrees)
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\';

% load in data
addpath(genpath(filepath)); % add new data to search path
load([filepath 'Shimada\Data\summary_19-23Hake_biovolume.mat'],'PB'); %IFCB data
load([filepath 'Shimada\Data\coast_CCS.mat'],'coast'); %map
states=load([filepath 'Shimada\Data\USwestcoast_pol.mat']); %map

%remove IFCB data that does not have matching NASC value
PB(isnan(PB.avNASC),:)=[];

%% Plot NASC & IFCB data
fig=figure; 

for idx=1:length(yr)
    f=find(PB.DT.Year==yr(idx));
    lat=PB.LAT(f); lon=PB.LON(f); dt=PB.DT(f); 

    %plot NASC data
    krill=PB.avNASC(f); 
    
    label={'average NASC (m^2 nmi^{-2})'}; name='NASC'; cax=[0 5000]; 
    
    ax(idx)=subplot(2,3,idx);
    set(gcf,'color','w','Units','inches','Position',[1 1 2 4.7]); 
    
    if option==1    
        sz = .025*(krill+.01); %vector of scaled marker sizes based on data
        scatter(lon,lat,sz,krill,'o','filled','MarkerEdgeColor','k');  hold on
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
                data_grid(ii,jj) = mean(krill(lon>=lon_grid(ii)-res/2 & lon<lon_grid(ii)+res/2 & lat>=lat_grid(jj)-res/2 & lat<lat_grid(jj)+res/2),'omitnan');
            end
        end
        [lat_plot,lon_plot] = meshgrid(lat_grid,lon_grid);
        pcolor(lon_plot-res/2,lat_plot-res/2,data_grid); % have to shift lat/lon for pcolor with flat shading     
        shading flat; hold on;
        clearvars lat_plot lon_plot ii jj nx ny lon_grid lat_grid data_grid res
    end 
    
    colormap(ax(idx),jet)
    clim(cax);
    h=colorbar('northoutside');    
    set(h,'xaxisloc','top','fontsize',9,'tickdir','out');
    xtickangle(0); hold on;    
    colorTitleHandle = get(h,'Title');
    set(colorTitleHandle,'String',label,'fontsize',11);
    
    % Plot map
    fillseg(coast); dasp(42); hold on;
    plot(states.lon,states.lat,'k'); hold on;
    set(gca,'ylim',[34 49],'xlim',[-127 -120],'xtick',-127:3:-120,...
    'xticklabel',{'127 W','124 W','121 W'},'yticklabel',...
    {'34 N','35 N','36 N','37 N','38 N','39 N','40 N','41 N','42 N','43 N','44 N','45 N','46 N','47 N','48 N','49 N'},...
    'fontsize',9,'tickdir','out','box','on','xaxisloc','bottom');

    % %plot IFCB dino:diat
    % data=PB.dino_diat_ratio(f); 
    % 
    % label={'log(dino:diat)'}; name='ratio'; cax=[-3 3]; 
    % 
    % ax(idx+1)=subplot(2,3,idx+3);
    % set(gcf,'color','w','Units','inches','Position',[1 1 2 4.7]); 
    % 
    % if option_PB==1    
    %     scatter(lon,lat,15,data,'o','filled');  hold on
    % else
    %     % Create grid
    %     lon_grid = min(lon):res:max(lon)+.5;
    %     lat_grid = min(lat):res:max(lat)+.5;
    %     nx = length(lon_grid);
    %     ny = length(lat_grid);    
    %     % Average data on grid
    %     data_grid = nan(nx,ny);
    %     for ii = 1:nx
    %         for jj = 1:ny
    %             data_grid(ii,jj) = mean(data(lon>=lon_grid(ii)-res/2 & lon<lon_grid(ii)+res/2 & lat>=lat_grid(jj)-res/2 & lat<lat_grid(jj)+res/2),'omitnan');
    %         end
    %     end    
    %     [lat_plot,lon_plot] = meshgrid(lat_grid,lon_grid);
    %     pcolor(lon_plot-res/2,lat_plot-res/2,data_grid); % have to shift lat/lon for pcolor with flat shading     
    %     shading flat; hold on;
    %     clearvars lat_plot lon_plot ii jj nx ny lon_grid lat_grid data_grid
    % end 
    % 
    % colormap(ax(idx+1),flipud(brewermap(256,'PiYG')));
    % clim(cax);
    % h=colorbar('northoutside');    
    % set(h,'xaxisloc','top','fontsize',9,'tickdir','out');
    % xtickangle(0); hold on;    
    % colorTitleHandle = get(h,'Title');
    % set(colorTitleHandle,'String',label,'fontsize',11);
    % 
    % % Plot map
    % fillseg(coast); dasp(42); hold on;
    % plot(states.lon,states.lat,'k'); hold on;
    % set(gca,'ylim',[34 49],'xlim',[-127 -120],'xtick',-127:3:-120,...
    % 'xticklabel',{'127 W','124 W','121 W'},'yticklabel',...
    % {'34 N','35 N','36 N','37 N','38 N','39 N','40 N','41 N','42 N','43 N','44 N','45 N','46 N','47 N','48 N','49 N'},...
    % 'fontsize',9,'tickdir','out','box','on','xaxisloc','bottom');

    %plot IFCB diatom biomass/diatom + dinoflagellate biomass
    data=log10((PB.diatom(f)+1./(PB.diatom(f)+PB.dino(f)+1)));

    label={'log10 (diatom : diatom+dinoflagellate)'}; name='log10(diat:diat+dino)'; cax=[0 10]; 

    ax(idx+1)=subplot(2,3,idx+3);
    set(gcf,'color','w','Units','inches','Position',[1 1 2 4.7]); 

    if option_PB==1    
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
        clearvars lat_plot lon_plot ii jj nx ny lon_grid lat_grid data_grid
    end 

    colormap(ax(idx+1),jet)
    %colormap(ax(idx+1),brewermap(256,'PiYG'));
    clim(cax);
    h=colorbar('northoutside');    
    set(h,'xaxisloc','top','fontsize',9,'tickdir','out');
    xtickangle(0); hold on;    
    colorTitleHandle = get(h,'Title');
    set(colorTitleHandle,'String',label,'fontsize',11);

    % Plot map
    fillseg(coast); dasp(42); hold on;
    plot(states.lon,states.lat,'k'); hold on;
    set(gca,'ylim',[34 49],'xlim',[-127 -120],'xtick',-127:3:-120,...
    'xticklabel',{'127 W','124 W','121 W'},'yticklabel',...
    {'34 N','35 N','36 N','37 N','38 N','39 N','40 N','41 N','42 N','43 N','44 N','45 N','46 N','47 N','48 N','49 N'},...
    'fontsize',9,'tickdir','out','box','on','xaxisloc','bottom');
    clearvars f lat lon dt krill data

    % %plot IFCB diatom biomass
    % data=log(PB.diatom(f));
    % 
    % label={'diatom biomass'}; name='diatom'; cax=[0 20]; 
    % 
    % ax(idx+1)=subplot(2,3,idx+3);
    % set(gcf,'color','w','Units','inches','Position',[1 1 2 4.7]); 
    % 
    % if option_PB==1    
    %     scatter(lon,lat,15,data,'o','filled');  hold on
    % else
    %     % Create grid
    %     lon_grid = min(lon):res:max(lon)+.5;
    %     lat_grid = min(lat):res:max(lat)+.5;
    %     nx = length(lon_grid);
    %     ny = length(lat_grid);    
    %     % Average data on grid
    %     data_grid = nan(nx,ny);
    %     for ii = 1:nx
    %         for jj = 1:ny
    %             data_grid(ii,jj) = mean(data(lon>=lon_grid(ii)-res/2 & lon<lon_grid(ii)+res/2 & lat>=lat_grid(jj)-res/2 & lat<lat_grid(jj)+res/2),'omitnan');
    %         end
    %     end    
    %     [lat_plot,lon_plot] = meshgrid(lat_grid,lon_grid);
    %     pcolor(lon_plot-res/2,lat_plot-res/2,data_grid); % have to shift lat/lon for pcolor with flat shading     
    %     shading flat; hold on;
    %     clearvars lat_plot lon_plot ii jj nx ny lon_grid lat_grid data_grid
    % end 
    % 
    % colormap(ax(idx+1),flipud(brewermap(256,'PiYG')));
    % clim(cax);
    % h=colorbar('northoutside');    
    % set(h,'xaxisloc','top','fontsize',9,'tickdir','out');
    % xtickangle(0); hold on;    
    % colorTitleHandle = get(h,'Title');
    % set(colorTitleHandle,'String',label,'fontsize',11);
    % 
    % % Plot map
    % fillseg(coast); dasp(42); hold on;
    % plot(states.lon,states.lat,'k'); hold on;
    % set(gca,'ylim',[34 49],'xlim',[-127 -120],'xtick',-127:3:-120,...
    % 'xticklabel',{'127 W','124 W','121 W'},'yticklabel',...
    % {'34 N','35 N','36 N','37 N','38 N','39 N','40 N','41 N','42 N','43 N','44 N','45 N','46 N','47 N','48 N','49 N'},...
    % 'fontsize',9,'tickdir','out','box','on','xaxisloc','bottom');
    % clearvars f lat lon dt krill data
end

%% Print  
if fprint
    exportgraphics(fig,[filepath 'Figs\' name '_Shimada' num2str(yr) '.png'],'Resolution',300)    
end
hold off 
