%% set directory
base_dir = '\Eye Tracking\';

%% set experiment parameters
exp_name = 'loom';
fs = 60; %sample rate of synchronized, resampled data
exp_duration = 150; %duration of experiment in s
loom_dur = 0.78; %duration of looming stimulus
num_reps = 5; %number of repetitions of set of looming stimuli
num_conds = 3; %number of looming stimuli (center, right, left)
num_exps = 5; %number of experiments (i.e., mice)

num_trials = num_reps*num_conds;
pre_dur = 3; %duration of data prior to loom to include
post_dur = 3; %duration of data after loom to include
num_datatypes = 9; %number of data columns in dataset
num_datapoints = round(fs*(pre_dur+post_dur+loom_dur)) + 1; %number of datapoints in time-series


%% load all data
%pre-allocate space for an organized dataset
data2 = nan(num_datapoints,num_datatypes,num_conds,num_reps,num_exps);
cond_order = [];
for exp_num = 1:num_exps
    %load all synchronized data, and save a comprehensive resampled dataset @ 60 Hz
    load(fullfile(base_dir,['mouse' num2str(exp_num)],'data.mat'),"data","synced_data")
    
    %get loom start/stop times
    rise_idx = [false; diff(synced_data.data(:,7))>1];
    loom_start_inds = find(diff(rise_idx)==1)+1;
    loom_stop_inds = loom_start_inds + fs*loom_dur;
    assert(length(loom_start_inds)==num_trials,'unexpected number of trials detected')
    
    %organize data by loom repetition and condition    
    for t = 1:length(loom_start_inds)
        cond = synced_data.data(loom_start_inds(t),8)+1;
        cond_order = [cond_order cond];
        rep = ceil(t/num_conds);
        
        start_ind = loom_start_inds(t)-(fs*pre_dur);
        stop_ind = start_ind + num_datapoints - 1;
        data2(:,:,cond,rep,exp_num) = synced_data.data(start_ind:stop_ind,:);
    end

    time_vec = linspace(-pre_dur,loom_dur+post_dur,num_datapoints);
end


%% create a baseline-normalized dataset
baseline_inds = find(time_vec<0 & time_vec>-2); %2 seconds prior to stimulus = baseline region
data2_norm = data2./repmat(mean(data2(baseline_inds,:,:,:,:),'omitnan'),[num_datapoints 1 1 1 1]);


%% time-series plot of average pupil diameter change (and std patch) during 1st repetition (avg of all conditions)
tmp = 100*(data2_norm-1);
tmp = tmp(:,[3 6],:,:,:);
tmp = squeeze(mean(tmp,2)); %[datapoint cond rep exp]
tmp = squeeze(mean(tmp,2)); %[datapoint rep exp]
meantmp = mean(tmp,3);
stdtmp = std(tmp,0,3);

for rep = 1:num_reps
    figure('Position',[100 100 200 175])
    plot([-3 6],[0 0],'--k')
    hold on
    patch([0 loom_dur loom_dur 0],[-10 -10 10 10],'k','EdgeColor','none','FaceAlpha',0.15)
    plot(time_vec,meantmp(:,rep),'b','LineWidth',1)
    ul = meantmp(:,rep)+stdtmp(:,rep);
    ll = meantmp(:,rep)-stdtmp(:,rep);
    patch([time_vec fliplr(time_vec)],[ul' fliplr(ll')],'b','EdgeColor','none','FaceAlpha',0.15)
    xlim([-2 3.5])
    ylim([-3 9])
    ylabel('pupil diameter change (%)')
    xlabel('time (s)')
    box off
    xticks([-2 -1 0 1 2 3])
end


%% boxplot/scatterplot of pupil diameter change as a function of repetition (average of all conditions)
tmp = 100*(data2_norm-1);
tmp = tmp(:,[3 6],:,:,:);
tmp = squeeze(mean(tmp,2)); %[datapoint cond rep exp]
tmp = squeeze(mean(tmp,2)); %[datapoint rep exp]
inds = find(time_vec>0 & time_vec<3);
tmp = squeeze(mean(tmp(inds,:,:)))'; %[exp rep]
figure('Position',[100 100 200 175])
plot([0 6],[0 0],'--k')
hold on
b = boxplot(tmp);
for rep = 1:num_reps
    x = rep+linspace(-0.1,0.1,5);
    y = tmp(:,rep);
    scatter(x,y,20,'filled','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerFaceAlpha',0.3)
end
ylim([-7 9])
yticks([-6 -4 -2 0 2 4 6 8])
xlim([0.5 5.5])
xticklabels({'1-3','4-6','7-9','10-12','13-15'})
ylabel('pupil diameter change (%)')
box off

%run cuzicks test for trend
x = reshape(tmp,[25 1]);
g = repmat([1 2 3 4 5],[5 1]);
g = reshape(g,[25 1]);
x = [x g];
cuzick(x)
%p = 0.0073


%% plot time-series of avg eye pitch change during loom for each rep (average of all conditions)
tmp = data2(:,[2 5],:,:,:); %[datapoint datatype cond rep exp]
tmp = tmp - repmat(mean(tmp(baseline_inds,:,:,:,:)),[num_datapoints 1 1 1 1]);
tmp = squeeze(mean(tmp,2));  %[datapoint cond rep exp]
tmp = squeeze(mean(tmp,2));  %[datapoint rep exp]
meantmp = mean(tmp,3); %[datapoint rep
stdtmp = std(tmp,0,3);

for rep = 1:num_reps
    figure('Position',[100 100 200 175])
    plot([-3 6],[0 0],'--k')
    hold on
    patch([0 loom_dur loom_dur 0],[-10 -10 10 10],'k','EdgeColor','none','FaceAlpha',0.15)
    plot(time_vec,meantmp(:,rep),'b','LineWidth',1)
    ul = meantmp(:,rep)+stdtmp(:,rep);
    ll = meantmp(:,rep)-stdtmp(:,rep);
    patch([time_vec fliplr(time_vec)],[ul' fliplr(ll')],'b','EdgeColor','none','FaceAlpha',0.15)
    xlim([-2 3.5])
    ylim([-2 4])
    ylabel('eye pitch change (deg)')
    xlabel('time (s)')
    box off
    xticks([-2 -1 0 1 2 3])
end


%% boxplot/scatterplot plots of avg eye pitch change as a function of repetition (average of all conditions)
tmp = data2(:,[2 5],:,:,:); %[datapoint datatype cond rep exp]
tmp = tmp - repmat(mean(tmp(baseline_inds,:,:,:,:)),[num_datapoints 1 1 1 1]);
tmp = squeeze(mean(tmp,2)); %[datapoint cond rep exp]
tmp = squeeze(mean(tmp,2)); %[datapoint rep exp]
inds = find(time_vec>0 & time_vec<2);
tmp = squeeze(mean(tmp(inds,:,:)))'; %[exp rep]
figure('Position',[100 100 200 175])
plot([0 6],[0 0],'--k')
hold on
b = boxplot(tmp);
for rep = 1:num_reps
    x = rep+linspace(-0.1,0.1,5);
    y = tmp(:,rep);
    scatter(x,y,20,'filled','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerFaceAlpha',0.3)
end
ylim([-1.5 4])
yticks(-2:4)
xlim([0.5 5.5])
xticklabels({'1-3','4-6','7-9','10-12','13-15'})
ylabel('eye pitch change (deg)')
box off

%run cuzicks test for trend
x = reshape(tmp,[25 1]);
g = repmat([1 2 3 4 5],[5 1]);
g = reshape(g,[25 1]);
x = [x g];
cuzick(x)
%p = 0.2445


%% plot time-series of avg eye pitch change during loom (avg of all reps)
tmp = data2(:,[2 5],:,:,:); %[datapoint datatype cond rep exp]
tmp = tmp - repmat(mean(tmp(baseline_inds,:,:,:,:)),[num_datapoints 1 1 1 1]);
tmp = squeeze(mean(tmp,2));  %[datapoint cond rep exp]
tmp = squeeze(mean(tmp,2));  %[datapoint rep exp]
tmp = squeeze(mean(tmp,2));  %[datapoint exp]
meantmp = mean(tmp,2); %[datapoint]
stdtmp = std(tmp,0,2);

figure('Position',[100 100 200 175])
plot([-3 6],[0 0],'--k')
hold on
patch([0 loom_dur loom_dur 0],[-10 -10 10 10],'k','EdgeColor','none','FaceAlpha',0.15)
plot(time_vec,meantmp,'b','LineWidth',1)
ul = meantmp+stdtmp;
ll = meantmp-stdtmp;
patch([time_vec fliplr(time_vec)],[ul' fliplr(ll')],'b','EdgeColor','none','FaceAlpha',0.15)
xlim([-2 3.5])
ylim([-1.5 4])
ylabel('eye pitch change (deg)')
xlabel('time (s)')
box off
xticks([-2 -1 0 1 2 3 4])
yticks(-2:4)



%% plot walking speed during loom (avg of all reps)
tmp = data2(:,9,:,:,:); %[datapoint datatype cond rep exp]
tmp = squeeze(mean(tmp,2));  %[datapoint cond rep exp]
tmp = squeeze(mean(tmp,2));  %[datapoint rep exp]
tmp = squeeze(mean(tmp,2));  %[datapoint exp]
meantmp = mean(tmp,2); %[datapoint]
stdtmp = std(tmp,0,2);

figure('Position',[100 100 200 175])
plot([-3 6],[0 0],'--k')
hold on
patch([0 loom_dur loom_dur 0],[-10 -10 10 10],'k','EdgeColor','none','FaceAlpha',0.15)
plot(time_vec,meantmp,'b','LineWidth',1)
ul = meantmp+stdtmp;
ll = meantmp-stdtmp;
patch([time_vec fliplr(time_vec)],[ul' fliplr(ll')],'b','EdgeColor','none','FaceAlpha',0.15)
xlim([-2 3.5])
ylim([-2.5 5])
ylabel('walking speed (cm/s)')
xlabel('time (s)')
box off
xticks([-2 -1 0 1 2 3])


%% boxplot/scatterplot of walking speed as a function of repetition (average of all conditions)
tmp = data2(:,9,:,:,:); %[datapoint datatype cond rep exp]
tmp = tmp - repmat(mean(tmp(baseline_inds,:,:,:,:)),[num_datapoints 1 1 1 1]);
tmp = squeeze(mean(tmp,2)); %[datapoint cond rep exp]
tmp = squeeze(mean(tmp,2)); %[datapoint rep exp]
inds = find(time_vec>0 & time_vec<2);
tmp = squeeze(mean(tmp(inds,:,:)))'; %[exp rep]
figure('Position',[100 100 200 175])
plot([0 6],[0 0],'--k')
hold on
b = boxplot(tmp);
for rep = 1:num_reps
    x = rep+linspace(-0.1,0.1,5);
    y = tmp(:,rep);
    scatter(x,y,20,'filled','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerFaceAlpha',0.3)
end
ylim([-2.5 5])
yticks([-6 -4 -2 0 2 4 6 8])
xlim([0.5 5.5])
xticklabels({'1-3','4-6','7-9','10-12','13-15'})
ylabel('walking speed change (cm/s)')
box off

%run cuzicks test for trend
x = reshape(tmp,[25 1]);
g = repmat([1 2 3 4 5],[5 1]);
g = reshape(g,[25 1]);
x = [x g];
cuzick(x)
%p = 0.37196

