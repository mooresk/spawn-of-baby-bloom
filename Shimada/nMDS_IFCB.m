%% Conduct nMDS on IFCB data

close all; 
clear all;

%%%%USER
filepath = 'C:\Users\Stephanie.Moore\Documents\GitHub\spawn-of-baby-bloom\';
yr=[2019 2021 2023];

% load in data
addpath(genpath(filepath)); % add new data to search path
load([filepath 'Shimada\Data\summary_19-23Hake_biovolume.mat'],'PB'); %IFCB data

% remove IFCB data that does not have matching NASC value
PB(isnan(PB.avNASC),:)=[];

% extract species biomass data only from PB
% NOTE: including unclassified in X, else need to remove rows with all zeros (nothing classified, all in unclassified)
X=[PB.Akashiwo PB.Alexandrium_catenella PB.Asterionellopsis PB.Cera_Dact_Deto_Guin PB.Chaetoceros PB.Cylindrotheca ...
    PB.Dictyocha PB.Dinophysis PB.Eucampia PB.Gymnodinium PB.Hete_Scri PB.Katodinium PB.Lauderia PB.Leptocylindrus PB.Navicula PB.Nitzschia ...
    PB.Prob_Rhiz PB.Pseudonitzschia PB.Skeletonema PB.Thalassiosira PB.unclassified];

% transform data
X=nthroot(X,4);
%X=log10(X+1);

%% use mds2 from Fathom toolbox to perform 2-D nonmetric multidimensional scaling
%https://www.usf.edu/marine-science/research/matlab-resources/fathom-toolbox-for-matlab.aspx

% create a Bray-Curtis dissimilarity matrix among observations using Fathom toolbox 
dis = f_dis(X,'bc');

mds_2 = f_nmds(dis,2,1,1);

f_nmdsPlot(mds_2,PB.transect,X,PB.Properties.VariableNames(8:28),0,'none',1);

%% use mdscale from Mathworks to perform nonmetric multidimensional scaling
%https://www.mathworks.com/help/stats/nonclassical-and-nonmetric-multidimensional-scaling.html

%produce a vector containing only the elements in the upper triangle of the dissimilarity matrix.
dissimilarities=squareform(dis);

[Y,stress,disparities] = mdscale(dissimilarities,2,'criterion','stress');
stress

%make Shepard plot
figure
distances = pdist(Y);
[dum,ord] = sortrows([disparities(:) dissimilarities(:)]);
plot(dissimilarities,distances,'bo',dissimilarities(ord),disparities(ord),'r.-',[0 1],[0 1],'k-')
xlabel('Dissimilarities')
ylabel('Distances/Disparities')
legend({'Distances' 'Disparities' '1:1 Line'},'Location','NorthWest');

figure
plot(Y(:,1),Y(:,2),'o','LineWidth',2);

%% color code nMDS plot based on NASC value
figure
sz = .025*(PB.avNASC +.01) + 1; %vector of scaled marker sizes based on krill index
scatter(Y(:,1),Y(:,2),sz,PB.avNASC,'o','filled','MarkerEdgeColor','k');  hold on; 
cax=[0 8500]; 
colormap(jet);
clim(cax);
h=colorbar('northoutside');    
set(h,'xaxisloc','top','fontsize',9,'tickdir','out');

%% color code nMDS plot based on year
figure
sz = .025*(PB.avNASC +.01) + 1; %vector of scaled marker sizes based on krill index
colors = 'gyr';
for idx=1:length(yr)
    ff=find(PB.DT.Year==yr(idx));
    if ff
        scatter(Y(ff,1),Y(ff,2),sz(ff),PB.avNASC(ff),'o','filled','MarkerEdgeColor','k','MarkerFaceColor',colors(idx));  hold on;
    end
end
