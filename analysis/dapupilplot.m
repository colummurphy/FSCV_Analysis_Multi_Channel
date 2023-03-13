%% 
% function dapupilplot(session_num,range,alignment)
%% Set conditions
session_num=100;
analyzeSes(session_num);
cond=['reward'];
alignment_pd='display_fix';
alignment_da='display_fix';
channel_number=4; %look at trlists.fscvsites to select channel (p-putamen, c-caudate nucleus)
range_pd=[-7 4]; %tr_raster pupil diameter range 
range_da=[-12 4]; %tr_raster doapmine range 
%% Load data 
trlists=evalin('base','trlists');
[axabig,tridsbig,databig,stampsbig]=tr_raster(trlists,'nlx','eyed','ttypes',{{'big','left'},{'post','reward'}},'win',range_pd,'event',alignment_pd); % must fix "tbefore" variable in getpupilzs function when changing the event time point ("start or display target") for baseline subtraction
[sebig,allzsbig, pdbig,outliersB2]=getpupilzs('big',databig,tridsbig,stampsbig);
[axasmall,tridssmall,datasmall,stampssmall]=tr_raster(trlists,'nlx','eyed','ttypes',{{'small','left'},{'post','reward'}},'win',range_pd,'event',alignment_pd);
[sesmall,allzssmall,pdsmall,outliersS2]=getpupilzs('small',datasmall,tridssmall,stampssmall);
close all; %comment out if tr_raster plots are desired 
%% Cutting time window for pupil diameter [display target: 0-0.8s; start target: 0-0.2s]
num=0; %start time point of time window 
t=num+abs(range_pd(:,1))*1000; %start index
num_disp=0.8; %final time point of interest for display target
num_star=0.2; %final time point of interest for start target

switch(alignment_pd)
    case char('display_fix')
        num_ind=(num_disp+abs(range_pd(:,1)))*1000; %index of final time point  
    case char('start_target')
        num_ind=(num_star+abs(range_pd(:,1)))*1000; %index of final time point  
end

zsbig_cut=allzsbig(:,t:num_ind); %cut zscore data to the rearranged time window 
zssma_cut=allzssmall(:,t:num_ind);  %cut zscore data to the rearranged time window 
%% Get the quartile corresponding IDS to get the appropriate DA data
idbig=[tridsbig(:) zsbig_cut]; %appends trids and data in time window of interest 
QuantZBig=quantile(idbig(:,2:end),4); %quantile calculation of zs using trids

firstquantB=idbig(find(idbig(:,2:end)<QuantZBig(1,:))); %finds ids in first quantile 
fourthquantB=idbig(find(idbig(:,2:end)>QuantZBig(4,:))); %finds ids in fourth quantile
firstquantB=firstquantB(firstquantB>1); %finds trids>1
fourthquantB=fourthquantB(fourthquantB>1); %finds trids>1

meanzsbigcut=mean(zsbig_cut,2,"omitnan");
meanidsB=[tridsbig(:) meanzsbigcut];
meanidsB=meanidsB(~isnan(meanidsB(:,2)),:);
meanQuantZBig=quantile(meanidsB(:,2),4);

%get the quartile corresponding IDS to get the appropriate DA data
firstquantBmean=meanidsB(find(meanidsB(:,2)<meanQuantZBig(1)));
fourthquantBmean=meanidsB(find(meanidsB(:,2)>meanQuantZBig(4)));

%% getting the data concatenated with the IDS  that are used. 
idsmall=[tridssmall(:) zssma_cut];
QuantZsmall=quantile(idsmall(:,2:end),4);

%get the quartile corresponding IDS to get the appropriate DA data
firstquantS=idsmall(find(idsmall(:,2:end)<QuantZsmall(1,:)));
fourthquantS=idsmall(find(idsmall(:,2:end)>QuantZsmall(4,:)));
firstquantS=firstquantS(firstquantS>1);
fourthquantS=fourthquantS(fourthquantS>1);

meanzssmallcut=mean(zssma_cut,2,"omitnan");
meanidsS=[tridssmall(:) meanzssmallcut];
meanidsS=meanidsS(~isnan(meanidsS(:,2)),:);
meanQuantZsmall=quantile(meanidsS(:,2),4);

%get the quartile corresponding IDS to get the appropriate DA data
firstquantSmean=meanidsS(find(meanidsS(:,2)<meanQuantZsmall(1)));
fourthquantSmean=meanidsS(find(meanidsS(:,2)>meanQuantZsmall(4)));
%%
[axabigD,tridsbigD,databigD,stampsbigD]=tr_raster(trlists,'fscv','da',channel_number,'ttypes',{{'big','left'},{'post',cond}},'win',range_da,'event',alignment_da);
[axasmallD,tridssmallD,datasmallD,stampssmall]=tr_raster(trlists,'fscv','da',channel_number,'ttypes',{{'small','left'},{'post',cond}},'win',range_da,'event',alignment_da);
close all %comment out if tr_raster plots are desired 

labeled_dataB=[tridsbigD(:) databigD]; % split the DA data by the appropriate trial IDS
labeled_dataS=[tridssmallD(:) datasmallD];
%% Use this if you use the means 
fquantDAB=[];
lquantDAB=[];
firstquantidsB=firstquantBmean;
fourthquantidsB=fourthquantBmean;

fquantDAS=[];
lquantDAS=[];
firstquantidsS=firstquantSmean;
fourthquantidsS=fourthquantSmean;
%% Use this if you use the time series BIG vs SMALL
% BIG
% fquantDAB=ones(size(labeled_dataB));
% lquantDAB=ones(size(labeled_dataB));
% firstquantidsB=firstquantB;
% fourthquantidsB=fourthquantB;
firstquantidsB=firstquantidsB(ismember(firstquantidsB,tridsbigD(:)));
fourthquantidsB=fourthquantidsB(ismember(fourthquantidsB,tridsbigD(:)));

% SMALL 
% fquantDAS=ones(size(labeled_dataS));
% lquantDAS=ones(size(labeled_dataS));
% firstquantidsS=firstquantS;
% fourthquantidsS=fourthquantSmean;
firstquantidsS=firstquantidsS(ismember(firstquantidsS,tridssmallD(:)));
fourthquantidsS=fourthquantidsS(ismember(fourthquantidsS,tridssmallD(:)));
%% 
% BIG
for i= 1:size(firstquantidsB)
    fquantDAB(i,:)=labeled_dataB(find(labeled_dataB(:,1)==firstquantidsB(i)),:);
end
fquantDAB=fquantDAB(:,2:end);

for i= 1:size(fourthquantidsB)
    lquantDAB(i,:)=labeled_dataB(find(labeled_dataB(:,1)==fourthquantidsB(i)),:);
end
lquantDAB=lquantDAB(:,2:end);

% SMALL
for i= 1:size(firstquantidsS)
    fquantDAS(i,:)=labeled_dataS(find(labeled_dataS(:,1)==firstquantidsS(i)),:);
end
fquantDAS=fquantDAS(:,2:end);

for i= 1:size(fourthquantidsS)
    lquantDAS(i,:)=labeled_dataS(find(labeled_dataS(:,1)==fourthquantidsS(i)),:);
end
lquantDAS=lquantDAS(:,2:end);

%% plot the DA data for big and small left only 
channels=vertcat(trlists.fscvsites.ch);
sites={};
for i =1:size(channels,1)
    sites{i}=trlists.fscvsites(i).site;
end

%BIG
fqpupilB_mean=mean(fquantDAB,1,"omitnan");
lqpupilB_mean=mean(lquantDAB,1,"omitnan");
fqpupilB_SE=std(fquantDAB,0,1,"omitnan")./sqrt(size(firstquantB,1));
lqpupilB_SE=std(lquantDAB,0,1,"omitnan")./sqrt(size(fourthquantB,1));

xdiff=range_da(:,2)-range_da(:,1);
x2=linspace(0,xdiff*10,length(fqpupilB_mean)); %saves xaxis
ten=linspace(x2(:,1),x2(:,end),xdiff/2+1);
realtime=x2(ten+1)/10+range_da(:,1);

figure
set(gcf, 'Position', [1000 750 750 600]);
plot(fqpupilB_mean,'-b');
hold on; plot(lqpupilB_mean,'-r');
hold on; plot(lqpupilB_mean+lqpupilB_SE,'-k');
hold on; plot(lqpupilB_mean-lqpupilB_SE,'-k');
hold on; plot(fqpupilB_mean+fqpupilB_SE,'-k');
hold on; plot(fqpupilB_mean-fqpupilB_SE,'-k');

tick1=cell(1,xdiff/2+1);
for i=1:xdiff/2+1
    tick1{i}=num2str(realtime(i));
end
xticklabels(tick1);

title(append("DA mean by pupil diameter zscore quantiles Session:", num2str(session_num)," site:",num2str(sites{find(channels==channel_number)}), " Big, Left. post: ",cond));
x3=xline(x2(:,1)+abs(range_da(:,1)*10),'-',{alignment_da});
x3.LabelVerticalAlignment = 'bottom';
xlabel('time(s)')
legend("first quantile pupil diameter zscore","fourth quantile pupil diameter zscore");

%SMALL
fqpupilS_mean=mean(fquantDAS,1,"omitnan");
lqpupilS_mean=mean(lquantDAB,1,"omitnan");
fqpupilS_SE=std(fquantDAS,0,1,"omitnan")./sqrt(size(firstquantB,1));
lqpupilS_SE=std(lquantDAS,0,1,"omitnan")./sqrt(size(fourthquantB,1));

figure
set(gcf, 'Position', [1000 750 750 600]);
plot(fqpupilS_mean,'-b');
hold on; plot(lqpupilS_mean,'-r');
hold on; plot(lqpupilS_mean+lqpupilS_SE,'-k');
hold on; plot(lqpupilS_mean-lqpupilS_SE,'-k');
hold on; plot(fqpupilS_mean+fqpupilS_SE,'-k');
hold on; plot(fqpupilS_mean-fqpupilS_SE,'-k');

tick1=cell(1,xdiff/2+1);
for i=1:xdiff/2+1
    tick1{i}=num2str(realtime(i));
end
xticklabels(tick1);

title(append("DA mean by pupil diameter zscore quantiles Session:", num2str(session_num)," site:",num2str(sites{find(channels==channel_number)}), " Small, Left. post: ",cond));
x3=xline(x2(:,1)+abs(range_da(:,1)*10),'-',{alignment_da});
x3.LabelVerticalAlignment = 'bottom';
xlabel('time(s)')
legend("first quantile pupil diameter zscore","fourth quantile pupil diameter zscore");
