
%% Section 1: preprocess raw image files 
%this section is only performed once for each raw image file, performing 
% the following procedures:
% 1. extract TTL pulse synchronization signal from imaging channel 1 to 
% determine the starting frames for each stimulus set
% 2. perform motion-correction on imaging channel 2 (gcamp-specific
% channel) to prepare for active neuron segmentation with suite2p
% 
% after this section is performed, each motion-corrected calcium imaging
% file is opened through suite2p, which generates a "Fall.mat" file for
% each imaging file, which are then used to continue with the remainder of
% this analysis and plotting script.


exp_folder = '...\Published Data\2P Imaging\VR2 Data\mouse1';
imagedir = dir(fullfile(exp_folder,'rfm0*.tif'));
ppd = 220/140; %pixels/per/degree

savech2 = false;
imageName = fullfile(imagedir.folder,imagedir.name);
iminfo = imfinfo(imageName);
numInds = length(iminfo);
numFrames = numInds/4;
numRstims = 5*25; %4 directions each at 25 spots
numDstims = 5*12; %12 directions
numTstims = 5*16; %5 contrasts, 6 freqs, 5 waves
numCstims = 3*3;
numStims = numRstims + numDstims + numTstims + numCstims;

trigger = nan(1,10000);
ch = 1;
f = 1;
for i = 1:numInds
    if savech2 && (ch==2)
        I = imread(imageName,i);
        I = uint16(I);
        savename = fullfile(imagedir.folder,['ch' num2str(ch) '_' imagedir.name]);
        if f==1
            imwrite(I,savename);
        else
            imwrite(I,savename,'WriteMode','append');
        end
    end
    if ch==1
        I = imread(imageName,i);
        trigger(f) = mean(I,'all','omitnan');
    end
    ch = ch+1;
    if ch==5
        ch = 1;
        f = f+1;
    end
    if ch==1 && mod(f,1000)==0
        fprintf([num2str(f) '\n'])
    end
end
if f<length(trigger)
    trigger(f+1:end) = [];
end

triggerRange = min(trigger);
triggerRange(2) = max(trigger);
triggerLevel = mean(triggerRange);

triggerLevel = -29000;
starts = find(diff(trigger<triggerLevel)==1)+1;

figure()
plot(trigger);
figure()
plot(trigger<triggerLevel);

% after plotting the trigger signal, manual inspection of the signal was
% done to find the frames which separate the stimulus sets.
% for each of the 3 mouse files, uncomment the relevant section of code

%mouse 1
% rdsep1 = 2600; %separation between receptive field mapping and direction tuning
% rdsep2 = rdsep1;
% dtsep = 3885; %separation between direction tuning and contrast/frequency/wavelength tuning
% tcsep = 6200; %%separation between contrast/frequency/wavelength tuning and light contamination test
% badstarts = [2255];

%mouse 2
% rdsep1 = 2600;
% rdsep2 = rdsep1;
% dtsep = 4000;
% tcsep = 7150;
% badstarts = [];

%mouse 3
% rdsep1 = 2600;
% rdsep2 = 2900;
% dtsep = 4200;
% tcsep = 6400;
% badstarts = [2652 2679 2706 2734 2761 2788 2815 2843];

for s = badstarts
    starts(starts==s) = [];
end
numDetectedRstims = sum(starts<rdsep1);
numDetectedDstims = sum(starts>rdsep2 & starts<dtsep);
numDetectedTstims = sum(starts>dtsep & starts<tcsep);
numDetectedCstims = sum(starts>tcsep);
assert(length(starts)==numStims,'unexpected number of start triggers');
save(fullfile(imagedir.folder,'starts.mat'),'starts','trigger')

%perform normcorre on ch2
imageName = fullfile(imagedir.folder,['ch2_' imagedir.name]);
suite2pfolder = fullfile(imagedir.folder,'suite2p');
if ~exist(suite2pfolder,'dir')
    mkdir(suite2pfolder);
end
stabilizedFullTifName = run_normcorre('imageName',imageName,'saveDir',suite2pfolder);
%motion-corrected file saved as stabilizedFullTifName


%% Section 2: run suite2p
%to start suite2p (after it has been downloaded and installed from suite2p.org):
%open anaconda prompt
%type "conda activate suite2p"
%type "suite2p"
%run suite2p on each motion corrected file individually. a "Fall.mat" file
%is saved for each, which are used in the following sections


%% Section 3a: organize/analyze saved data
%run once for all mice
base_directory = '...Published Data\2P Imaging\VR2 Data\';
positions_x_0 = [-24 -12 0 12 24];
positions_y = [-24 -12 0 12 24];
angles = 0:30:330; %only angles are used in this script
frequencies = [0.5 1 2 4 8 12]; %default is 2
contrasts = 0:20:100; %default is 100
barwidths = [2 5 10 20 40]; %default is 2
numMice = 3;

%get number of cells
numCellsAll = nan(1,3);
for m = 1:numMice
    exp_folder = [base_directory 'mouse' num2str(m)];
    load(fullfile(exp_folder,'suite2p','suite2p','plane0','Fall.mat'));
    numCellsAll(m) = size(spks,1);
end
maxCells = max(numCellsAll);

%get cell classifiers
iscellAll = nan(maxCells,numMice);
for m = 1:numMice
    exp_folder = [base_directory 'mouse' num2str(m)];
    load(fullfile(exp_folder,'suite2p','suite2p','plane0','Fall.mat'));
    iscellAll(1:numCellsAll(m),m) = iscell(:,1);
end

% loop for all mice
for m = 1:numMice
    exp_folder = [base_directory 'mouse' num2str(m)];
    metadir = dir(fullfile(exp_folder,'*VR2*.mat'));

    % load metadata
    load(fullfile(metadir.folder,metadir.name));
    
    % load suite2p
    load(fullfile(exp_folder,'suite2p','suite2p','plane0','Fall.mat'));
    [numCells, numFrames] = size(spks);
    cellInds = 1:numCells;

    % load triggers
    load(fullfile(exp_folder,'starts.mat'));

    % Organize spike and F data into trials by condition using start times and metadata
    figure()
    plot(trigger)
    hold on

    %organize RFM data
    numFramesPerStim = 28; % ~2 s before stim, 6 s after
    numConditions = 25;
    numRepetitions = 5;
    if m==1
        rS = nan(maxCells, numFramesPerStim, 5, 5, numRepetitions, numMice);
        rF = nan(maxCells, numFramesPerStim, 5, 5, numRepetitions, numMice);
        rFneu = nan(maxCells, numFramesPerStim, 5, 5, numRepetitions, numMice);
    end
    t = 1;
    for r = 1:numRepetitions
        for c = 1:numConditions
            plot([starts(t) starts(t)],[-10000 -35000],'-r')
            finds = starts(t)-7:starts(t)+20;
            position = trial_orders.full_order_of_positions_0(c,:,r);
            xind = find(positions_x_0==position(1));
            yind = find(positions_y==position(2));
            rS(cellInds,:,xind,yind,r,m) = spks(:,finds);
            rF(cellInds,:,xind,yind,r,m) = F(:,finds);
            rFneu(cellInds,:,xind,yind,r,m) = Fneu(:,finds);
            t = t+1;
        end
    end

    % organize dir tuning data
    numFramesPerStim = 28; % ~2 s before stim, 6 s after
    numConditions = 12;
    numRepetitions = 5;
    if m==1
        dS = nan(maxCells, numFramesPerStim, 12, numRepetitions, numMice);
        dF = nan(maxCells, numFramesPerStim, 12, numRepetitions, numMice);
        dFneu = nan(maxCells, numFramesPerStim, 12, numRepetitions, numMice);
    end
    for r = 1:numRepetitions
        for c = 1:numConditions
            plot([starts(t) starts(t)],[-10000 -35000],'-g')
            finds = starts(t)-7:starts(t)+20;
            curangle = trial_orders.full_order_of_angles_dir(c,r);
            aind = find(angles==curangle);
            dS(cellInds,:,aind,r,m) = spks(:,finds);
            dF(cellInds,:,aind,r,m) = F(:,finds);
            dFneu(cellInds,:,aind,r,m) = Fneu(:,finds);
            t = t+1;
        end
    end

    % organize other tuning data
    numFramesPerStim = 28; % ~2 s before stim, 6 s after
    numConditions = 16;
    numRepetitions = 5;
    if m==1
        cS = nan(maxCells, numFramesPerStim, 6, numRepetitions, numMice);
        cF = nan(maxCells, numFramesPerStim, 6, numRepetitions, numMice);
        cFneu = nan(maxCells, numFramesPerStim, 6, numRepetitions, numMice);
        wS = nan(maxCells, numFramesPerStim, 5, numRepetitions, numMice);
        wF = nan(maxCells, numFramesPerStim, 5, numRepetitions, numMice);
        wFneu = nan(maxCells, numFramesPerStim, 5, numRepetitions, numMice);
        fS = nan(maxCells, numFramesPerStim, 6, numRepetitions, numMice);
        fF = nan(maxCells, numFramesPerStim, 6, numRepetitions, numMice);
        fFneu = nan(maxCells, numFramesPerStim, 6, numRepetitions, numMice);
    end
    for r = 1:numRepetitions
        for c = 1:numConditions
            plot([starts(t) starts(t)],[-10000 -35000],'-m')
            finds = starts(t)-7:starts(t)+20;
            type = trial_orders.full_order_of_tuning_types(c,r);
            switch type
                case 1 %contrast
                    contrast = trial_orders.full_order_of_tuning_values(c,r);
                    ind = find(contrasts==contrast);
                    cS(cellInds,:,ind,r,m) = spks(:,finds);
                    cF(cellInds,:,ind,r,m) = F(:,finds);
                    cFneu(cellInds,:,ind,r,m) = Fneu(:,finds);
                case 2 %wavelength
                    barwidth = trial_orders.full_order_of_tuning_values(c,r);
                    ind = find(barwidths==barwidth);
                    wS(cellInds,:,ind,r,m) = spks(:,finds);
                    wF(cellInds,:,ind,r,m) = F(:,finds);
                    wFneu(cellInds,:,ind,r,m) = Fneu(:,finds);

                case 3 %freq
                    frequency = trial_orders.full_order_of_tuning_values(c,r);
                    ind = find(frequencies==frequency);
                    fS(cellInds,:,ind,r,m) = spks(:,finds);
                    fF(cellInds,:,ind,r,m) = F(:,finds);
                    fFneu(cellInds,:,ind,r,m) = Fneu(:,finds);

                    if ind==2
                        ind = find(contrasts==100);
                        cS(cellInds,:,ind,r,m) = spks(:,finds);
                        cF(cellInds,:,ind,r,m) = F(:,finds);
                        cFneu(cellInds,:,ind,r,m) = Fneu(:,finds);
                    end

            end
            t = t+1;
        end
    end

    % organize color test data
    numFramesPerStim = 56; % ~2 s before stim, 14 s after
    numRepetitions = 3;
    if m==1
        colS = nan(maxCells, numFramesPerStim, numRepetitions, numMice);
        colF = nan(maxCells, numFramesPerStim, numRepetitions, numMice);
        colFneu = nan(maxCells, numFramesPerStim, numRepetitions, numMice);
    end
    for r = 1:numRepetitions
        plot([starts(t) starts(t)],[-10000 -35000],'-y')
        finds = starts(t)-7:starts(t)+48;
        colS(cellInds,:,r,m) = spks(:,finds);
        colF(cellInds,:,r,m) = F(:,finds);
        colFneu(cellInds,:,r,m) = Fneu(:,finds);
        t = t+3;
    end
end


%% Section 3b: plot direction tuning
%S/F/Fneu = [numCells, numFrames, numConds, numReps, numMice]
%use spikes to calculate OSI/DSI for all cells, all mice
OSI = nan(maxCells,numMice);
Opref = nan(maxCells,numMice);
DSI = nan(maxCells,numMice);
Dpref = nan(maxCells,numMice);
baselineFrames = 1:7;
stimFrames = 8:11; %dirtuning
numConditions = 12;
numRepetitions = 5;
meandS = mean(dS,4,'omitnan'); %average of all reps
dFadj = dF-(0.7*dFneu);

%for polarplots
theta = deg2rad([angles angles(1)]);
figure_size = [300 250];
OSI_threshold = 0.3;
DSI_threshold = 0.3;
pval_theshold = 0.05;
primary_threshold = 0.5;
primaryDirCells = false(maxCells,numMice);
pvalsDirCells = ones(maxCells,numMice);
plot_polars = true;
plot_mouse = 3;
poloarplotcells = [16 65 77];
plot_fluorescence = true;
fluorescenceplotcells = [16,65,77,34,49,59,71,110,107,158];
num_fluorescenceplotcells = length(fluorescenceplotcells);
for m = 1:numMice
    numCells = numCellsAll(m);
    for cell = 1:numCells
        meanActivity = mean(meandS(cell,stimFrames,:,:,m),2,'omitnan');
        baselineActivity = mean(meandS(cell,baselineFrames,:,:,m),2,'omitnan');
        pvalsDirCells(cell,m) = ranksum(squeeze(meanActivity),squeeze(baselineActivity));
        meanActivity = permute(meanActivity,[1 3 2]);
        OSI_complex = sum(meanActivity.*(exp(2*1i*deg2rad(angles))))./sum(meanActivity);
        OSI(cell,m) = abs(OSI_complex);
        Opref(cell,m) = rad2deg(angle(OSI_complex));        

        DSI_complex = sum(meanActivity.*(exp(1i*deg2rad(angles))))./sum(meanActivity);
        DSI(cell,m) = abs(DSI_complex);
        Dpref(cell,m) = rad2deg(angle(DSI_complex));

        if (DSI(cell,m)>=DSI_threshold || OSI(cell,m)>=OSI_threshold) && pvalsDirCells(cell,m)<=pval_theshold
            rho = [meanActivity meanActivity(1)];
            rho = rho/max(rho);
            if plot_polars && m==plot_mouse && any(cell==poloarplotcells)
                plotind = find(cell==poloarplotcells);
                if plotind==1
%                     F1 = figure('Position',[100 100 figure_size]);
                else
%                     figure(F1);
                end
%                 subplot(length(poloarplotcells),1,plotind)
                figure('Position',[100 100 100 100])
                polarplot(theta,rho,'LineWidth',1)
                ax = gca;
                ax.RTick = [0.5 1];
                ax.RLim = [0 1];
                ax.ThetaDir = 'clockwise';
                disp(['cell ' num2str(cell) ' mouse ' num2str(m) ' OSI ' num2str(OSI(cell,m)) 'DSI' num2str(DSI(cell,m))])
%                 if plotind==num_fluorescenceplotcells
%                     axis off
%                 end
            end
            if plot_fluorescence && m==plot_mouse && any(cell==fluorescenceplotcells)
                plotind = find(cell==fluorescenceplotcells);
                if plotind==1
                    F2 = figure('Position',[100 100 figure_size]);
                else
                    figure(F2);
                end
                frames2plot = 4:21;
                maxFvecs = squeeze(dFadj(cell,:,:,:,m)); %[frames, conds, reps]
                maxFvecs = maxFvecs(frames2plot,:,:);
                maxFvecs = mean(maxFvecs,3,'omitnan');
                baseFvecs = prctile(maxFvecs(:),10);
                maxFvecs = maxFvecs-baseFvecs;
                maxFvecs = max(maxFvecs(:));
                
                for cond=1:numConditions
                    Fvecs = squeeze(dFadj(cell,:,cond,:,m))'; %[reps, frames]
                    Fvecs = Fvecs(:,frames2plot);
                    Fvecs = (Fvecs-baseFvecs)/maxFvecs;
                    numPlotFrames = size(Fvecs,2);
                    mFvec = mean(Fvecs,'omitnan');
                    stdFvec = std(Fvecs);
                    x0 = (1.1*(cond-1))*(1.2*numPlotFrames);
                    y0 = num_fluorescenceplotcells - plotind;
                    patch(x0+[1:numPlotFrames numPlotFrames:-1:1],y0+[mFvec+stdFvec fliplr(mFvec-stdFvec)],'b',...
                        'FaceColor','b','EdgeColor','none','FaceAlpha',0.15);
                    hold on
                    plot(x0+(1:numPlotFrames),y0+mFvec,'b','LineWidth',1)
                end
                if plotind==num_fluorescenceplotcells
                    axis off
                    ylim([-0.5 num_fluorescenceplotcells+0.3])
                    xlim([0 1.1*1.2*numPlotFrames*numConditions])
                end
            end
            if rho(4)>=primary_threshold
                primaryDirCells(cell,m) = true;
            end
        end
    end
end 

figure('Position',[100 100 300 100])
subplot(121);
tmp = OSI;
tmp(pvalsDirCells>pval_theshold) = nan;
histogram(tmp(:),-0.025:0.05:1.025);
ylabel('number of cells')
xlabel('OSI')
ylim([0 120])
sum(~isnan(tmp(:)))

subplot(122);
tmp = DSI;
tmp(pvalsDirCells>pval_theshold) = nan;
histogram(tmp(:),-0.025:0.05:1.025);
ylabel('number of cells')
xlabel('DSI')
ylim([0 120])
sum(~isnan(tmp(:)))

Dcells = (DSI>DSI_threshold & pvalsDirCells<pval_theshold);
Ocells = (OSI>OSI_threshold & pvalsDirCells<pval_theshold);
% 10 nicest looking mouse 3 polar plots:
% 16(d),34(o),49(o),59(o),65(od),71(d),77(o),110(o),107(o),158(o)
% 3 nicest looking mouse 3 polar plots:
% 16(d),65(od),77(o)
sum(primaryDirCells)


%% Section 3c: contrast tuning curve
baselineFrames = 1:7;
stimFrames = 8:14; %contrast, frequency, wavelength tuning
numConditions = 6;
meanActivity = squeeze(mean(mean(cS(:,stimFrames,:,:,:),2,'omitnan'),4,'omitnan'));
meanBaseline = squeeze(mean(mean(cS(:,baselineFrames,:,:,:),2,'omitnan'),4,'omitnan'));
maxActivity = max(meanActivity,[],2,'omitnan');
normActivity = meanActivity./repmat(maxActivity,[1 numConditions 1]);
normBaseline = meanBaseline./repmat(maxActivity,[1 numConditions 1]);

%use all cells
normActivity = permute(normActivity,[2 1 3]);
normActivity = reshape(normActivity,[numConditions maxCells*numMice]);

normBaseline = permute(normBaseline,[2 1 3]);
normBaseline = reshape(normBaseline,[numConditions maxCells*numMice]);

figure('Position',[100 100 150 100])
y = normActivity;
goodcols = find(sum(isnan(y))<numConditions);
y = y(:,goodcols);
meany = mean(y,2,'omitnan');
bsey= std(bootstrp(2000,@mean,y'));
errorbar(contrasts,meany,bsey,'b','LineWidth',1)
hold on
b = normBaseline;
goodcols = find(sum(isnan(b))<numConditions);
b = b(:,goodcols);
meanb = mean(b,'all','omitnan');
sb = std(bootstrp(2000,@mean,b(:)));
patch([0 100 100 0],[meanb+sb meanb+sb meanb-sb meanb-sb],'k','EdgeColor','none','FaceAlpha',0.15)
plot([-0 100],[meanb meanb],'--k','LineWidth',0.5)
% xticks([1 2 3 4 5 6]);
% xticklabels({'0','20','40','60','80','100'})
xlabel('contrast (%)')
ylabel('normalized activity')
ylim([0 1.1])
xlim([-10 110])

figure('Position',[100 100 300 200])
y = normActivity;
goodcols = find(sum(isnan(y))<numConditions);
y = y(:,goodcols);
[~,maxi] = max(y);
histogram(maxi,0.5:6.5)
xticks([1 2 3 4 5 6]);
xticklabels({'0','20','40','60','80','100'})
xlabel('contrast (%)')
ylabel('number of cells')

figure('Position',[100 100 300 200])
y = normActivity;
goodcols = find(sum(isnan(y))<numConditions);
y = y(:,goodcols);
[~,maxi] = max(y);
mccs = find(maxi<4.5); %mid contrast cells
hccs = find(maxi>=4.5); %high contrast cells
% y = mean(normActivity,2,'omitnan');
% plot(frequencies,y)
meanm = mean(y(:,mccs),2,'omitnan');
bsem = std(bootstrp(2000,@mean,y(:,mccs)'));
meanh = mean(y(:,hccs),2,'omitnan');
bseh = std(bootstrp(2000,@mean,y(:,hccs)'));
errorbar(contrasts,meanm,bsem,'b','LineWidth',1)
hold on
errorbar(contrasts,meanh,bseh,'r','LineWidth',1)

b = normBaseline;
goodcols = find(sum(isnan(b))<numConditions);
b = b(:,goodcols);
meanb = mean(b,'all','omitnan');
sb = std(bootstrp(2000,@mean,b(:)));
patch([0 100 100 0],[meanb+sb meanb+sb meanb-sb meanb-sb],'k','EdgeColor','none','FaceAlpha',0.15)
plot([-0 100],[meanb meanb],'--k','LineWidth',0.5)

xticks([1 2 3 4 5 6]);
xticklabels({'0','20','40','60','80','100'})
xlabel('contrast (%)')
ylabel('normalized activity')
ylim([0 1.1])

%fit naka rushton function to each cell's contrast tuning curve

%all cells
numAcells = size(y,2);
ks = nan(1,numAcells);
ns = nan(1,numAcells);
rms = nan(1,numAcells);
gs = nan(1,numAcells);
nc = numAcells;

gthresh = 0.8;
x = 0:20:100;
ft = fittype('(x^b/((x^b) + (c^b)))');
fitopts = fitoptions('METHOD','NonlinearLeastSquares','Lower',[0.5 5],'Upper',[10 90],'Robust','on','StartPoint',[2.5 30]);
figure('Position',[100 100 200 350])
subplot(211)
plot(x,zeros(size(x)),'--k')
hold on
num_contrast_cells = 0;
sx = 0:100;
for cell = 1:nc
    try
        [curve, goodness] = fit(x',y(:,cell),ft,fitopts);
        ns(cell) = curve.b;
        ks(cell) = curve.c;
%         rms(cell) = curve.a;
        gs(cell) = goodness.adjrsquare;
        sy = ((sx.^curve.b./(sx.^curve.b + curve.c^curve.b)));
        if goodness.adjrsquare>gthresh
            plot(sx,sy,'Color',[0.7 0.7 0.7],'Linewidth',0.25)
            num_contrast_cells = num_contrast_cells+1;
        end
    end

end
mk = median(ks(gs>gthresh),'omitnan');
mn = median(ns(gs>gthresh),'omitnan');
sy = ((sx.^mn./(sx.^mn + mk^mn)));
plot(sx,sy,'k','Linewidth',1)
xlim([0 100]);
ylim([0 1])
xlabel('contrast (%)')
ylabel('normalized activity')

%histogram
figure('Position',[100 100 200 350])
subplot(212)
h = histogram(ks(gs>gthresh),0:3:100);
hold on
h.EdgeColor = [0.3 0.3 0.3];
h.FaceColor = [0.7 0.7 0.7];
h.FaceAlpha = 0.7;
xlim([0 100])
plot([mk mk],[0 22],'--k','LineWidth',1);
ylabel('number of cells')
xlabel('semisaturation contrast (%)')
ylim([0 25])


%% Section 3d: freq tuning
baselineFrames = 1:7;
stimFrames = 8:14; %contrast, frequency, wavelength tuning
numConditions = 6;
meanActivity = squeeze(mean(mean(fS(:,stimFrames,:,:,:),2,'omitnan'),4,'omitnan'));
meanBaseline = squeeze(mean(mean(fS(:,baselineFrames,:,:,:),2,'omitnan'),4,'omitnan'));
maxActivity = max(meanActivity,[],2,'omitnan');
normActivity = meanActivity./repmat(maxActivity,[1 numConditions 1]);
normBaseline = meanBaseline./repmat(maxActivity,[1 numConditions 1]);

%all cells
normActivity = permute(normActivity,[2 1 3]);
normActivity = reshape(normActivity,[numConditions maxCells*numMice]);

normBaseline = permute(normBaseline,[2 1 3]);
normBaseline = reshape(normBaseline,[numConditions maxCells*numMice]);

figure('Position',[100 100 300 200])
y = normActivity;
goodcols = find(sum(isnan(y))<numConditions);
y = y(:,goodcols);
[~,maxi] = max(y);
histogram(maxi,0.5:6.5)
xticks([1 2 3 4 5 6]);
xticklabels({'0.5','1','2','4','8','16'})
xlabel('temporal frequency (Hz)')
ylabel('number of cells')

figure('Position',[100 100 300 200])
y = normActivity;
goodcols = find(sum(isnan(y))<numConditions);
y = y(:,goodcols);
[~,maxi] = max(y);
lpcs = find(maxi<2.5);
bpcs = find(maxi>=2.5);
% y = mean(normActivity,2,'omitnan');
% plot(frequencies,y)
meanb = mean(y(:,bpcs),2,'omitnan');
bseb = std(bootstrp(2000,@mean,y(:,bpcs)'))
meanl = mean(y(:,lpcs),2,'omitnan');
bsel = std(bootstrp(2000,@mean,y(:,lpcs)'))
errorbar(meanb,bseb,'b','LineWidth',1)
hold on
errorbar(meanl,bsel,'r','LineWidth',1)
xticks([1 2 3 4 5 6]);
xticklabels({'0.5','1','2','4','8','16'})
xlabel('temporal frequency (Hz)')
ylabel('normalized activity')
ylim([0 1.1])
b = normBaseline;
goodcols = find(sum(isnan(b))<numConditions);
b = b(:,goodcols);
meanb = mean(b,'all','omitnan');
sb = std(bootstrp(2000,@mean,b(:)));
patch([0.1 100 100 0.1],[meanb+sb meanb+sb meanb-sb meanb-sb],'k','EdgeColor','none','FaceAlpha',0.15)
plot([-10 110],[meanb meanb],'--k','LineWidth',0.5)
xlim([0 6.5])

%fit log-gaussian
tf = frequencies;
tpref = 4; %b
twidth = 4; %c
y = normActivity;

ft = fittype('exp(-((log2(x) - log2(b)).^2)./(2*c^2))');
fitopts = fitoptions('METHOD','NonlinearLeastSquares','Lower',[0.5 1],'Upper',[64 10],'Robust','on','Startpoint',[4 4]);

numAcells = size(y,2);
ps = nan(1,numAcells);
ws = nan(1,numAcells);
gs = nan(1,numAcells);
nc = numAcells;
x = fliplr(tf);
sx = 0.5:0.1:64;
num_frequency_cells = 0;
gthresh = 0.8;

figure('Position',[100 100 600 200])
subplot(121)
for cell = 1:nc
    try
        [curve, goodness] = fit(x',y(:,cell),ft,fitopts);
        ps(cell) = curve.b;
        ws(cell) = curve.c;
        gs(cell) = goodness.adjrsquare;
        sy = exp(-((log2(sx) - log2(curve.b)).^2)./(2*curve.c^2));
        if goodness.adjrsquare>gthresh
            semilogx(sx,sy,'Color',[0.7 0.7 0.7],'Linewidth',0.25)
            hold on
            num_frequency_cells = num_frequency_cells+1;
        end
    end
end
mp = median(ps(gs>gthresh),'omitnan');
mw = median(ws(gs>gthresh),'omitnan');
sy = exp(-((log2(sx) - log2(mp)).^2)./(2*mw^2));
semilogx(sx,sy,'k','Linewidth',1)
xlim([0.5 64])
ylim([0 1])
xticks([0.5 1 2 4 8 16 32 64])
xlabel('t.f. (Hz)')
ylabel('normalized activity')

subplot(122)
scatter(ps(gs>gthresh),ws(gs>gthresh),8,[0.7 0.7 0.7],'filled')
hold on
scatter(mp,mw,20,'k','filled')
xlim([0.5 64])
ylim([0 10])
xticks([0.5 1 2 4 8 16 32 64])
set(gca,'xscale','log')
xlabel('preferred t.f. (Hz)')
ylabel('sigma')


%% Section 3e: wavelength tuning
baselineFrames = 1:7;
stimFrames = 8:14; %contrast, frequency, wavelength tuning
wavelengths = barwidths*2/ppd;
numConditions = 5;
meanActivity = squeeze(mean(mean(wS(:,stimFrames,:,:,:),2,'omitnan'),4,'omitnan'));
meanBaseline = squeeze(mean(mean(wS(:,baselineFrames,:,:,:),2,'omitnan'),4,'omitnan'));
maxActivity = max(meanActivity,[],2,'omitnan');
normActivity = meanActivity./repmat(maxActivity,[1 numConditions 1]);
normBaseline = meanBaseline./repmat(maxActivity,[1 numConditions 1]);

%all cells
normActivity = permute(normActivity,[2 1 3]);
normActivity = reshape(normActivity,[numConditions maxCells*numMice]);

normBaseline = permute(normBaseline,[2 1 3]);
normBaseline = reshape(normBaseline,[numConditions maxCells*numMice]);

figure('Position',[100 100 150 100])
y = normActivity;
goodcols = find(sum(isnan(y))<numConditions);
y = y(:,goodcols);
[~,maxi] = max(y);
histogram(maxi,0.5:5.5)
xticks([1 2 3 4 5]);
xticklabels({'2','6','12','25','50'})
xlabel('spatial wavelength deg')
ylabel('number of cells')

figure('Position',[100 100 150 100])
ax1 = axes();
y = normActivity;
goodcols = find(sum(isnan(y))<numConditions);
y = y(:,goodcols);
meany = mean(y,2,'omitnan');
bsey = std(bootstrp(2000,@mean,y'));
errorbar(wavelengths,meany,bsey,'b','LineWidth',1)
hold on
b = normBaseline;
goodcols = find(sum(isnan(b))<numConditions);
b = b(:,goodcols);
meanb = mean(b,'all','omitnan');
sb = std(bootstrp(2000,@mean,b(:)));
patch([0.1 100 100 0.1],[meanb+sb meanb+sb meanb-sb meanb-sb],'k','EdgeColor','none','FaceAlpha',0.15)
plot([0.1 100],[meanb meanb],'--k','LineWidth',0.5)
% errorbar(wavelengths,meany,bsey,'k','Linewidth',1)
% xticks(10:10:50);
% xticklabels({'2.5','6.4','12.7','25.5','50.9'})
xlabel('spatial wavelength (deg)')
ylabel('normalized activity')
ylim([0 1.1])
xlim([2 60])
hold on
set(ax1,'XScale','log')
% set(ax1,'XTick',[2 5 10 20 50]);
set(ax1,'XMinorTick','on');
set(ax1,'XGrid','on')
box off

%fit log-gaussian
sf = 1./[50.9, 25.5, 12.7, 6.4, 2.5]; %for ~[0.02, 0.04, 0.08, 0.16 0.32]; %cpd
sfpref = 0.04; %b
sfwidth = 0.04; %c
y = normActivity;

ft = fittype('exp(-((log2(x) - log2(b)).^2)./(2*c^2))');
fitopts = fitoptions('METHOD','NonlinearLeastSquares','Lower',[0.02 0.25],'Upper',[0.4 4],'Robust','on','Startpoint',[0.04 1]);

numAcells = size(y,2);
ps = nan(1,numAcells);
ws = nan(1,numAcells);
gs = nan(1,numAcells);
as = nan(1,numAcells);
nc = numAcells;
x = fliplr(sf);
sx = 0.02:0.001:0.4;
num_wavelength_cells = 0;
gthresh = 0.8;

figure('Position',[100 100 200 350])
subplot(211)
for cell = 1:nc
    try
        [curve, goodness] = fit(x',y(:,cell),ft,fitopts);
        ps(cell) = curve.b;
        ws(cell) = curve.c;
        gs(cell) = goodness.adjrsquare;
        sy = exp(-((log2(sx) - log2(curve.b)).^2)./(2*curve.c^2));
        if goodness.adjrsquare>gthresh
            semilogx(sx,sy,'Color',[0.7 0.7 0.7],'Linewidth',0.25)
            hold on
            num_wavelength_cells = num_wavelength_cells+1;
        end
    end
end
mp = median(ps(gs>gthresh),'omitnan');
mw = median(ws(gs>gthresh),'omitnan');
sy = exp(-((log2(sx) - log2(mp)).^2)./(2*mw^2));
semilogx(sx,sy,'k','Linewidth',1)
xlim([0.02 0.4])
ylim([0 1])
xticks([0.02 0.04 0.08 0.16 0.32])
xticklabels({'2', '4', '8', '16', '32'})
xlabel('s.f. (cpd)')
ylabel('normalized activity')

%
%histogram
figure('Position',[100 100 200 350])
subplot(212)

xspatials = [0.02 0.04 0.08 0.16 0.32];

h = histogram(ps(gs>gthresh),logspace(-1.7, 0.60206, 50));
hold on
h.EdgeColor = [0.3 0.3 0.3];
h.FaceColor = [0.7 0.7 0.7];
h.FaceAlpha = 0.7;
xlim([0.02 0.4])
set(gca,'xscale','log')
plot([mp mp],[0 35],'--k','LineWidth',1);
ylabel('number of cells')
xlabel('preferred sf (cpd)')
xticks([0.02 0.04 0.08 0.16 0.32])
xticklabels({'2', '4', '8', '16', '32'})
xlim([0.02 0.4])
ylim([0 38])


%% Section 3f: receptive field heatmaps
%get comparison data
Lpixels = 112.5;
Ldeg = 20;
% upper 2/3
rfpixels = [23.75, 25.88, 27.39, 28.6, 28.6, 29.92, 31.94, 34.16, 34.87, 36.49, 46.80, 47.50, 56.40, 64.99, 86.62];
% lower 2/3
rfpixels2 = [25.07, 25.8, 28.5, 29.10, 29.41, 29.41, 30.63, 31.54, 33.76, 33.76, 33.86, 34.26, 36.5, 36.5, 37.09, 38.31, 39.01, 41.64, 41.64, 41.74, 42.42, 53.97, 59.30, 63.67, 80.76];
rfdeg = [rfpixels rfpixels2]*(Ldeg/Lpixels);


%rS = [maxCells, numFramesPerStim, 5, 5, numRepetitions, numMice]
grid_size = [5 5];
pixels = 12;
subgrid_size = grid_size*2;

%create 5x5 heatmap
baselineFrames = 1:6;
stimFrames = 7:14;
heatmaps = zeros([grid_size, numRepetitions, maxCells, numMice]);
heatmaps_baseline = zeros([grid_size, numRepetitions, maxCells, numMice]);
for x = 1:5
    for y = 1:5
        activedata = mean(rS(:,stimFrames,x,y,:,:),2,'omitnan');
        activedata = permute(activedata,[4 3 5 1 6 2]);
        heatmaps(y,x,:,:,:) = heatmaps(y,x,:,:,:) + activedata;
        baselinedata = mean(rS(:,baselineFrames,x,y,:,:),2,'omitnan');
        baselinedata = permute(baselinedata,[4 3 5 1 6 2]);
        heatmaps_baseline(y,x,:,:,:) = heatmaps_baseline(y,x,:,:,:) + baselinedata;
    end
end

%create 10x10 upsampled heatmap]
% stimFrames = [7 8 9 10 10 11 12 13]';
stimFrames = [7 8 9; 8 9 10; 9 10 11; 9 10 11; 10 11 12; 11 12 13; 12 13 14; 13 14 15];
hd_heatmaps = zeros([subgrid_size, numRepetitions, maxCells, numMice]);
hd_heatmaps_baseline = zeros([subgrid_size, numRepetitions, maxCells, numMice]);
for x = 1:5
    for y = 1:5
        subxind = x*2;
        subyind = y*2;
        sx = [subxind-1 subxind subxind-1 subxind];
        sy = [subyind subyind subyind-1 subyind-1];

        %baseline activity
        baselinedata = mean(rS(:,baselineFrames,x,y,:,:),2,'omitnan');
        baselinedata = permute(baselinedata,[4 3 5 1 6 2]);
        for i = 1:2
            for p = 1:4
                hd_heatmaps_baseline(sy(p),sx(p),:,:,:) = hd_heatmaps_baseline(sy(p),sx(p),:,:,:) + baselinedata;
            end
        end
        
        %stimulated data (in 8 parts (l,r,u,d,r,l,d,u]
        locs = [1 3; 2 4; 1 2; 3 4; 2 4; 1 3; 3 4; 1 2];
        for p = 1:8
            activedata = mean(rS(:,stimFrames(p,:),x,y,:,:),2,'omitnan');
            activedata = permute(activedata,[4 3 5 1 6 2]);
            for i = 1:2
                hd_heatmaps(sy(locs(p,i)),sx(locs(p,i)),:,:,:) = hd_heatmaps(sy(locs(p,i)),sx(locs(p,i)),:,:,:) + activedata;
            end
        end
    end
end


%% estimate hwhm from heatmaps
resnorms = nan(maxCells,numMice);
hwhm = nan(maxCells,numMice,3); %dim3: average, x, y

%prepare figure to show example heatmaps
figure()
% goodCells = [13 14 31 41 48 52 90 96 148 157]; %10 handpicked examples
% goodCells = [14 31 157]; %mouse 3, 3 handpicked examples
% goodCells = [11]; % mouse 2
goodCells = [14 11];
goodMouse = [3 2];
numGoodCells = length(goodCells);

for m = 1:numMice
    for c = 1:maxCells
        %get normalized average heatmap
        activedata = mean(heatmaps(:,:,:,c,m),3,'omitnan');
        baselinedata = mean(heatmaps_baseline(:,:,:,c,m),3,'omitnan');
        if iscellAll(c,m)==1 %&& ranksum(activedata(:),baselinedata(:))<0.05
            activedata = activedata-baselinedata;
            activedata = activedata./max(activedata,[],'all');
            
            %fit 2D gaussian
            MdataSize = size(activedata,1)-1; % Size of nxn data matrix
            % parameters are: [Amplitude, x0, sigmax, y0, sigmay, angel(in rad)]
            [~,centerind] = max(activedata(:));
            [centery, centerx] = ind2sub(size(activedata),centerind);
            x0 = [1,centerx-(MdataSize/2),1,centery-(MdataSize/2),1,0]; %Inital guess parameters
            InterpolationMethod = 'nearest'; % 'nearest','linear','spline','cubic'
            [X,Y] = meshgrid(-MdataSize/2:MdataSize/2);
            xdata = zeros(size(X,1),size(Y,2),2);
            xdata(:,:,1) = X;
            xdata(:,:,2) = Y;
            Z = activedata;
            lb = [0,-MdataSize/2,0,-MdataSize/2,0,-pi/4];
            ub = [realmax('double'),MdataSize/2,(MdataSize/2)^2,MdataSize/2,(MdataSize/2)^2,pi/4];
            [x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunctionRot,x0,xdata,Z,lb,ub);
            resnorms(c,m) = resnorm;
        
            %gaussian function
            [XHD, YHD] = meshgrid(-MdataSize/2:0.25:MdataSize/2);
            Xrot= XHD*cos(x(6)) - YHD*sin(x(6));
            Yrot= XHD*sin(x(6)) + YHD*cos(x(6));
            x0rot = x(2)*cos(x(6)) - x(4)*sin(x(6));
            y0rot = x(2)*sin(x(6)) + x(4)*cos(x(6));
            F = x(1)*exp(   -((Xrot-x0rot).^2/(2*x(3)^2) + (Yrot-y0rot).^2/(2*x(5)^2) )    );
            
            %calculate hwhm
            degperpixel = 12/ppd;
            incr = 0.01;
            sweep = -10:incr:10;
            stay = zeros(size(sweep));
            Fx = exp(   -(sweep.^2/(2*x(3)^2) + stay.^2/(2*x(5)^2) )    );
            Fy = exp(   -(stay.^2/(2*x(3)^2) + sweep.^2/(2*x(5)^2) )    );
            fwhm_pixels = incr*mean([sum(Fx>0.5)+1, sum(Fy>0.5)+1]);
            hwhm(c,m) = degperpixel*(fwhm_pixels/2); %in degrees
    
            fwhm_pixels = incr*(sum(Fx>0.5)+1);
            hwhm(c,m,2) = degperpixel*(fwhm_pixels/2); %in degrees
            fwhm_pixels = incr*(sum(Fy>0.5)+1);
            hwhm(c,m,3) = degperpixel*(fwhm_pixels/2); %in degrees

            for cind = 1:numGoodCells
                if (m==goodMouse(cind)) && (c==goodCells(cind))
                    goodCellInd = find(goodCells==c);
                    subplot(2,numGoodCells,goodCellInd);
                    imshow(kron(activedata,ones(32)))
                    axis off
        
                    subplot(2,numGoodCells,numGoodCells+goodCellInd);
                    imshow(F)
                    
                end
            end
        end
    end
end
hwhm(goodCells(1),goodMouse(1),1)
hwhm(goodCells(2),goodMouse(2),1)

constrained_hwhm = hwhm;
constrained_hwhm(repmat(resnorms,[1 1 3])>0.25) = nan;

constrained_resnorms = resnorms;
constrained_resnorms(resnorms>0.25) = nan;

figure('Position',[100 100 200 175])
tmp1 = constrained_hwhm(:,:,1);
tmp2 = constrained_hwhm(:,:,2);
tmp3 = constrained_hwhm(:,:,3);
tmp4 = [tmp2(:)'; tmp3(:)'];
[~,i] = max(tmp4);
tmp_ma = tmp4(sub2ind(size(tmp4),i,1:size(tmp4,2)));
tmp_mi = tmp4(sub2ind(size(tmp4),3-i,1:size(tmp4,2)));
scatter(tmp_mi,tmp_ma,8,[0.7 0.7 0.7],'filled');
hold on
scatter(median(tmp_mi,'omitnan'),median(tmp_ma,'omitnan'),20,'k','filled')
ylabel('rf size, major (deg)')
xlabel('rf size, minor (deg)')
ylim([0 20])
xlim([0 10])

median_rf_size_avg = median(tmp1(:),'omitnan');
num_rf_cells = sum(sum(~isnan(hwhm(:,:,1))));

figure('Position',[100 100 200 175])
skew = tmp_ma./tmp_mi;
scatter(tmp1(:),resnorms(:),8,[0.7 0.7 0.7],'filled');
hold on
scatter(median(tmp1(:),'omitnan'),median(constrained_resnorms(:),'omitnan'),20,'k','filled')
ylabel('residuals')
xlabel('rf size (deg)')
ylim([0 0.25])
xlim([0 10])

figure('Position',[100 100 200 175])
tmp = constrained_hwhm(:,:,1);

hold on
h = histogram(tmp(:),0:0.5:15);
hold on
h.EdgeColor = [0.3 0.3 0.3];
h.FaceColor = [0.7 0.7 0.7];
h.FaceAlpha = 0.7;
plot([median_rf_size_avg median_rf_size_avg],[0 14],'--k','LineWidth',1);
ylabel('number of cells')
xlabel('rf size (deg)')

ylim([0 15])