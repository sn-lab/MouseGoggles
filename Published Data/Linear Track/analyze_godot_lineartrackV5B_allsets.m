
%% settings
fps = 60;
num_mice = 10;
num_reps = 40;
num_days = 5;
max_trial_duration = 60;
guaranteed_rewards = 3; %# of rewards which are automatically given, even on "lick_required" days
reward_zones = [-0.5 -0.5 0 0 0,  -0.5 -0.5 -0.5 0 0]; %start of reward zones, for mouse 1-10
control_zones = -0.5 - reward_zones; %start of control zones for mouse 1-10
reward_zone_size = 0.5;
anticipation_zone_size = 0.25;
base_dir{1} = "C:\Users\Published Data\Linear Track\linear track V5 set1"; %folder for data set 1
base_dir{2} = "C:\Users\Published Data\Linear Track\linear track V5 set2"; %folder for data set 2
mice_per_set = 5;

%colors
blue_color = [0 0 1];
orange_color = [1 0.5 0];
green_color = [0 0.8 0];
grey_color = [0.6 0.6 0.6];
magenta_color = [1 0 1];


%% load data
%parameters for data inclusion
min_track_end_position = 0.7; %how far down the track the mouse has to get before timeout, to be included in analysis (track ends are [-0.75 0.75]

trial_timeout = false(num_reps,num_mice,num_days); %to keep track of # of trial timeouts
zoneAmice = find(reward_zones==-0.5);
zoneBmice = find(reward_zones==0);
for set = 1:2
    for d = 1:num_days
        cur_dir = fullfile(base_dir{set},['day' num2str(d)]); %directory of day's data
        data_dir = dir(fullfile(cur_dir,'*godotlogs.txt')); %list of log files
        num_trials = length(data_dir);
        mousenum = nan(num_trials,1); %to store mouse ID #
        repnum = nan(num_trials,1); %to store repetition #
        rewardnum = nan(num_trials,1); %to store whether the trial was rewarded or not
        daynum = nan(num_trials,1); %to store the day/date the trial was run
        minutenum = nan(num_trials,1); %to store the minute the trial started (used for chronologically sorting trials from the same mouse/day)

        %get metadata from filename for all trials in this folder
        for t = 1:num_trials
            cur_trial_name = fullfile(data_dir(t).folder,data_dir(t).name);
            repnum(t) = str2double(extractBetween(data_dir(t).name,'rep','_'));
            rewardnum(t) = str2double(extractBetween(data_dir(t).name,'reward','_'));
            mousenum(t) = str2double(extractBetween(data_dir(t).name,'mouse','_'));
            datestrend = strfind(data_dir(t).name,'_linear')-1;
            datestr = data_dir(t).name(1:datestrend);
            datecell = strsplit(datestr,'_');
            datearray = cellfun(@str2double,datecell);
            if t==1
                t1 = datetime(datearray);
                minutenum(t) = 0;
            else
                t2 = datetime(datearray);
                minutenum(t) = ceil(minutes(time((between(t1,t2,'Time')))));
            end
        end

        %fix repnums for separate experiments (e.g. if an exp ended early and was restarted to get more reps)
        for m = unique(mousenum)'
            m_inds = mousenum==m;
            if length(unique(minutenum(m_inds)))>1
                new_repnums = 1:sum(m_inds);
                for cur_min = sort(unique(minutenum(m_inds)))'
                    min_inds = minutenum==cur_min & m_inds;
                    num_reps_at_min = sum(min_inds);
                    repnums_at_min = repnum(min_inds);
                    [~,o] = sort(repnums_at_min);
                    repnums_at_min(o) = new_repnums(1:num_reps_at_min);
                    repnum(min_inds) = repnums_at_min;
                    new_repnums(1:num_reps_at_min) = [];
                end
            end
        end

        %to give multiple sets of "mice 1-N" unique ID #s
        mousenum = mousenum+((set-1)*mice_per_set);
        
        %pre-allocate space for data
        if set==1 && d==1
            data = nan(1,10,num_days,num_reps,num_mice);
        end

        %load data
        for t = 1:num_trials
            cur_trial_name = fullfile(data_dir(t).folder,data_dir(t).name);
            rawdata = csvread(cur_trial_name);

            %make sure trial does not exceed max trial duration (godot/pi hangups can cause rare issues here)
            start_t = rawdata(1,9); %first timestamp
            end_t = start_t+(1000*max_trial_duration)-1;
            rawdata((rawdata(:,9)>end_t),:) = [];
            rawdata_length = size(rawdata,1);
            data_length = size(data,1);

            %only include data if the mouse traversed the entire track within the trial period
            if max(rawdata(:,5))>=min_track_end_position
                if rawdata_length>data_length
                    data(data_length+1:rawdata_length,:,:,:,:) = nan;
                end
                
                %data columns: [yaw, pitch, roll, x, z, ang, reward, lick, time] 
                data(1:rawdata_length,1:9,d,repnum(t),mousenum(t)) = rawdata;
                data(1:rawdata_length,10,d,repnum(t),mousenum(t)) = rewardnum(t); %add whether trial was rewarded to a new column
            else
                trial_timeout(repnum(t),mousenum(t),d) = true;
            end
        end
    end
end


%% quick look at some raw data
%plot amount of trial timeouts
plot(squeeze(mean(trial_timeout))');

%walking speed histogram
dz = diff(data(:,5,:,:,:)); %m/step
dt = diff(data(:,9,:,:,:)); %ms/step
cm_per_s = (100*dz)./(dt/1000); %cm/s
histogram(cm_per_s(:))


%% bin the data based on position along the track
%parameters for binning data by position
% num_zbins = 50;
% bins_to_exclude = [1 2 num_zbins-1 num_zbins];
num_zbins = 30;
bins_to_exclude = [1 num_zbins];

%parameters for removing reward-licks
omit_lick_dur = 3; %always remove licks for this amount of time after reward
omit_lick_dist = 0; %always remove licks this amount to distance "" 
omit_lick_freq = 1; %remove licks until it drops below this freq
omit_lick_freq_window = 0.5; %(s rolling avg)

%for plotting an example mouse trajectory
example_mouse = 1;
example_day = 3;
example_rep = 10; 
%some good examples: 
%mouse 1, day 1, rep 6 (unlearned, random licking) 
%mouse 1, day 3, rep 10 (fast, not so learned)
%mouse 1, day 5, rep 25 (place learned, rewarded trial)
%mouse 1, day 5, rep 26 (place learned, unrewarded trial)
%mouse 3, dat 1, rep __
%mouse 3, day 5, rep 26 (rewarded)
%mouse 3, day 5, rep 39 (unrewarded) 

zstep = 1.5/num_zbins;
zbins = -0.75+(zstep/2):zstep:0.75-(zstep/2);
lick_bin = zeros([num_reps num_zbins num_mice num_days]); %all licks
lick_bin_omit = zeros([num_reps num_zbins num_mice num_days]); %licks excluded for being right after rewarded
lick_bin_include = zeros([num_reps num_zbins num_mice num_days]); %what's left after omitting reward licks
reward_bin = nan([num_reps num_zbins num_mice num_days]); %reward bin
time_bin = nan([num_reps num_zbins num_mice num_days]); %mean time at each bin
dur_bin = zeros([num_reps num_zbins num_mice num_days]); %duration bin
dur_bin_omit = zeros([num_reps num_zbins num_mice num_days]); %duration bin, only of reward licks
dur_bin_include = zeros([num_reps num_zbins num_mice num_days]); %duration bin, excluding reward-lick duration
for m = 1:num_mice
    for d = 1:num_days
        for r = 1:num_reps
            zpos = data(:,5,d,r,m);
            reward = data(:,7,d,r,m);
            reward = [reward(1); diff(reward)==1];
            lick = data(:,8,d,r,m)>0;
            lick = [lick(1); diff(lick)==1];
            timex = data(:,9,d,r,m);
            timex = (timex-timex(1))/1000; %from ms to s
            
            %check for licks to omit (reward-licking)
            omit_inds = [];
            omit_log = false(size(lick));
            reward_inds = find(reward==1);
            if ~isempty(reward_inds)
                postreward_ind = reward_inds(1)+1;
                %omit by duration after reward
                if omit_lick_dur>0
                    omit_inds = postreward_ind:min([length(omit_log) (postreward_ind+(omit_lick_dur*fps))]); 
                    omit_log(omit_inds) = true;
                end
                
                %omit by lick frequency
                if omit_lick_freq<fps
                    lick_freq = fps*movmean(lick,omit_lick_freq_window*fps);
                    omit_log = omit_log | (lick_freq>omit_lick_freq);
                    omit_log(1:(postreward_ind-1)) = false; %don't omit pre-reward licks
                    includeagain_ind = find(diff(omit_log)==-1,1)+1;
                    omit_log(includeagain_ind:end) = false; %include licks after frequency drops below threshold)
                end
                
                %omit by distance after reward
                if omit_lick_dist>0
                    includeagain_dist = zpos(postreward_ind) + omit_lick_dist;
                    includeagain_ind = find(zpos>=includeagain_dist,1);
                    omit_log(postreward_ind:(includeagain_ind-1)) = true; %omit until mouse reaches certain distance after reward
            
                end
            end
            lick_include = lick & ~omit_log;
            lick_omit = lick & omit_log;
            
            %check that acquired data is OK before including it (framerate regular enough)
            measured_fps = 1./diff(timex(~isnan(timex)));
            if abs(mean(measured_fps)-60)>10 || any(measured_fps<0)
                fprintf(['Problem with data: m' num2str(m) '-d' num2str(d) '-r' num2str(r) '\n'])
            else
                %bin data by zpos
                for z = 1:num_zbins
                    rel_zpos = zpos-zbins(z);
                    bin_inds = rel_zpos>=-(zstep/2) & rel_zpos<(zstep/2);
                    lick_bin(r,z,m,d) = sum(lick(bin_inds),'omitnan');
                    lick_bin_omit(r,z,m,d) = sum(lick_omit(bin_inds),'omitnan');
                    lick_bin_include(r,z,m,d) = sum(lick_include(bin_inds),'omitnan');
                    reward_bin(r,z,m,d) = sum(reward(bin_inds),'omitnan');
                    time_bin(r,z,m,d) = mean(timex(bin_inds),'omitnan'); %average time
                    dur_bin(r,z,m,d) = sum(bin_inds)/mean(measured_fps);
                    dur_bin_omit(r,z,m,d) = sum(bin_inds & omit_log)/mean(measured_fps);
                    dur_bin_include(r,z,m,d) = sum(bin_inds & ~omit_log)/mean(measured_fps);
                end
            end
            
            %plot an example mouse trajectory
            if m==example_mouse && d==example_day && r==example_rep 
                figure('Position',[100 100 350 200])
                axes('Position',[0.1 0.35 0.88 0.6]);
                plot(zpos+.75,timex,'k','LineWidth',1)
                hold on
                patch([reward_zones(m) reward_zones(m)+reward_zone_size reward_zones(m)+reward_zone_size reward_zones(m)]+0.75,...
                    [0 0 60 60],'b','EdgeColor','none','FaceAlpha',0.3);
                patch([control_zones(m) control_zones(m)+reward_zone_size control_zones(m)+reward_zone_size control_zones(m)]+0.75,...
                    [0 0 60 60],'k','FaceColor',grey_color,'EdgeColor','none','FaceAlpha',0.3);
                scatter(zpos(reward==1)+0.75,timex(reward==1),200,'ok','MarkerEdgeColor',magenta_color,'LineWidth',1)
                scatter(zpos(lick_include)+0.75,timex(lick_include),100,'xk','Marker','square','MarkerEdgeColor',green_color,'LineWidth',1)
                scatter(zpos(lick_omit)+0.75,timex(lick_omit),100,'_k','MarkerEdgeColor',grey_color,'LineWidth',0.25)
                scatter(zpos(reward==1)+0.75,timex(reward==1),200,'ok','MarkerEdgeColor',magenta_color,'LineWidth',1)
                
                xlim([0 1.5])
                ylim([0 27])
                yticks([0 5 10 15 20 25])
                ylabel('time from start (s)')
                xlabel('position along track (m)')
                box off
                [~,i] = legend({'mouse trajectory','reward zone','control zone','reward','licks','reward licks'},'Location','NorthEastOutside','FontSize',8);
                i(11).Children.MarkerSize = 10;
                i(12).Children.MarkerSize = 10;
                i(13).Children.MarkerSize = 10;
                i(11).Children.LineWidth = 1;
                i(12).Children.LineWidth = 1;
                i(13).Children.LineWidth = 1;
                i(9).FaceAlpha = 0.4;
                i(10).FaceAlpha = 0.4;
                
                
                %lick rate
                axes('Position',[0.1 0.05 0.8 0.1]);  
                lr = lick_bin(r,:,m,d)./dur_bin(r,:,m,d);
                lri = lick_bin_include(r,:,m,d)./dur_bin(r,:,m,d);
                lro = lick_bin_omit(r,:,m,d)./dur_bin(r,:,m,d);
                binx = zbins+0.75;
                plot(binx,lri,'Color',green_color,'LineWidth',1);
                hold on
                plot(binx,lro,'Color',grey_color,'LineWidth',0.5);
                box off
                ylim([0 11])
                xticks([0 0.5 1 1.5])
                yticks([0 10])
                xticklabels([])
                [~,ii] = legend({'licks','reward licks'},'Location','NorthEastOutside');

            end
        end
    end
end
%calculate binned lick rates
lickrate_bin = lick_bin./dur_bin;
lickrate_bin_omit = lick_bin_omit./dur_bin;
lickrate_bin_include = lick_bin_include./dur_bin;
            
% exclude specified bins
lick_bin(:,bins_to_exclude,:,:) = nan;
lick_bin_omit(:,bins_to_exclude,:,:) = nan;
lick_bin_include(:,bins_to_exclude,:,:) = nan;
lickrate_bin(:,bins_to_exclude,:,:) = nan;
lickrate_bin_omit(:,bins_to_exclude,:,:) = nan;
lickrate_bin_include(:,bins_to_exclude,:,:) = nan;
reward_bin(:,bins_to_exclude,:,:) = nan;
time_bin(:,bins_to_exclude,:,:) = nan;
dur_bin(:,bins_to_exclude,:,:) = nan;

%remove data from timeout trials
%lickbin = [reps z-bin mice days]
data_timeouts = permute(trial_timeout,[1 4 2 3]);
data_timeouts = repmat(data_timeouts,[1 num_zbins 1 1]);
lick_bin(data_timeouts) = nan;
lick_bin_omit(data_timeouts) = nan;
lick_bin_include(data_timeouts) = nan;
lickrate_bin(data_timeouts) = nan;
lickrate_bin_omit(data_timeouts) = nan;
lickrate_bin_include(data_timeouts) = nan;
reward_bin(data_timeouts) = nan;
time_bin(data_timeouts) = nan;
dur_bin(data_timeouts) = nan;

%separate rewarded/unrewarded trials
rewarded_trials = false([num_reps, num_mice, num_days]);
for d = 1:num_days
    for m = 1:num_mice
        rewardnums = squeeze(data(1,10,d,:,m));
        rewarded_reps = rewardnums==1;
        rewarded_trials(:,m,d) = rewarded_reps;
    end
end


%% lick RATE distribution plots, across days
trials_to_include = 1:40;
%lickbin: [trials(40), bins, mice(10), days(5)]

%only look at rewarded trials
rewarded_bins = permute(rewarded_trials,[1 4 2 3]);
rewarded_bins = repmat(rewarded_bins,[1 num_zbins 1 1]);
lickrate_bin_include_rewarded = lickrate_bin_include;
lickrate_bin_include_rewarded(~rewarded_bins) = nan;
lickrate_bin_omit_rewarded = lickrate_bin_omit;
lickrate_bin_omit_rewarded(~rewarded_bins) = nan;

lickrate_includebinnorm = squeeze(mean(lickrate_bin_include(trials_to_include,:,:,:),'omitnan'));
lickrate_omitbinnorm = squeeze(mean(lickrate_bin_omit(trials_to_include,:,:,:),'omitnan'));

%lickrate_binnorm = [bins, mice, days]
mean_licks_include_A = squeeze(mean(lickrate_includebinnorm(:,zoneAmice,:),2,'omitnan'));
mean_licks_omit_A = squeeze(mean(lickrate_omitbinnorm(:,zoneAmice,:),2,'omitnan'));
std_licks_include_A = squeeze(std(lickrate_includebinnorm(:,zoneAmice,:),0,2,'omitnan'));
std_licks_omit_A = squeeze(std(lickrate_omitbinnorm(:,zoneAmice,:),0,2,'omitnan'));
sem_licks_include_A = std_licks_include_A/sqrt(length(zoneAmice));
sem_licks_omit_A = std_licks_omit_A/sqrt(length(zoneAmice));

mean_licks_include_B = squeeze(mean(lickrate_includebinnorm(:,zoneBmice,:),2,'omitnan'));
mean_licks_omit_B = squeeze(mean(lickrate_omitbinnorm(:,zoneBmice,:),2,'omitnan'));
std_licks_include_B = squeeze(std(lickrate_includebinnorm(:,zoneBmice,:),0,2,'omitnan'));
std_licks_omit_B = squeeze(std(lickrate_omitbinnorm(:,zoneBmice,:),0,2,'omitnan'));
sem_licks_include_B = std_licks_include_B/sqrt(length(zoneBmice));
sem_licks_omit_B = std_licks_omit_B/sqrt(length(zoneBmice));

%mean_licks/std_licks = [mice, days]
figure('Position',[100 100 100 200])
% chance_level = 1/(num_zbins-length(bins_to_exclude));
x = zbins+0.75;
ysep = 3.5;
yzeros = fliplr(0:ysep:ysep*4);
% yzeros = [1 0.8 0.6 0.4 0.2];
patch([reward_zones(1) reward_zones(1)+reward_zone_size reward_zones(1)+reward_zone_size reward_zones(1)]+0.75,...
    [-2 -2 50 50],'k','FaceColor',blue_color,'EdgeColor','none','FaceAlpha',0.15);
hold on
patch([control_zones(1) control_zones(1)+reward_zone_size control_zones(1)+reward_zone_size control_zones(1)]+0.75,...
    [-2 -2 50 50],'k','FaceColor',orange_color,'EdgeColor','none','FaceAlpha',0.15);
%plot days 1-5 training data
x(bins_to_exclude) = [];
for d = 1:5
    %plot included licks
    y0 = yzeros(d);
%     plot(x,y0+(zeros(size(x))),'--k')
    
    y = mean_licks_omit_A(:,d)';
    s = sem_licks_omit_A(:,d)';
    y(bins_to_exclude) = [];
    s(bins_to_exclude) = [];
    patch([x fliplr(x)],y0+[(y+s) fliplr(y-s)],'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none','FaceAlpha',0.3);
    plot(x,y0+y,'Color',[0.7 0.7 0.7],'LineWidth',1)
    
    y = mean_licks_include_A(:,d)';
    s = sem_licks_include_A(:,d)';
    y(bins_to_exclude) = [];
    s(bins_to_exclude) = [];
%     plot(x,y0+mean(y)*ones(size(x)),'--k')
    plot(x,y0*ones(size(x)),'--k')
    patch([x fliplr(x)],y0+[(y+s) fliplr(y-s)],'k','FaceColor',[1 1 1],'EdgeColor','none','FaceAlpha',1);
    patch([x fliplr(x)],y0+[(y+s) fliplr(y-s)],'k','FaceColor',green_color,'EdgeColor','none','FaceAlpha',0.4);
    plot(x,y0+y,'Color',green_color,'LineWidth',1.5)
end
xlabel('position along track (m)')

ylim([-ysep/2 max(yzeros)+1.2*ysep])
ax1 = gca;                  
ax1.YAxis.Visible = 'off'; 
xlim([-0 1.5])


%% lick RATE distribution plots, probe trials only
%rewarded_trials: [num_reps, num_mice, num_days]
%lickbin: [trials(40), bins, mice(10), days(5)]
rewarded_bins = permute(rewarded_trials,[1 4 2 3]);
rewarded_bins = repmat(rewarded_bins,[1 num_zbins 1 1]);
lickrate_includebin_unrewarded = lickrate_bin_include;
lickrate_includebin_unrewarded(logical(rewarded_bins)) = nan;
lickrate_includebin_unrewarded_norm = squeeze(mean(lickrate_includebin_unrewarded(trials_to_include,:,:,:),'omitnan'));
lickrate_includebin_unrewarded_norm = lickrate_includebin_unrewarded_norm./repmat(max(lickrate_includebin_unrewarded_norm),[num_zbins 1 1]);

lickrate_includebin_unrewarded_norm_day4 = mean(lickrate_includebin_unrewarded_norm(:,:,4),3,'omitnan');
mean_licks_include_unrewarded_A_day4 = squeeze(mean(lickrate_includebin_unrewarded_norm_day4(:,zoneAmice),2,'omitnan'));
std_licks_include_unrewarded_A_day4 = squeeze(std(lickrate_includebin_unrewarded_norm_day4(:,zoneAmice),0,2,'omitnan'));
sem_licks_include_unrewarded_A_day4 = std_licks_include_unrewarded_A_day4/sqrt(length(zoneAmice));
mean_licks_include_unrewarded_B_day4 = squeeze(mean(lickrate_includebin_unrewarded_norm_day4(:,zoneBmice),2,'omitnan'));
std_licks_include_unrewarded_B_day4 = squeeze(std(lickrate_includebin_unrewarded_norm_day4(:,zoneBmice),0,2,'omitnan'));
sem_licks_include_unrewarded_B_day4 = std_licks_include_unrewarded_B_day4/sqrt(length(zoneBmice));

lickrate_includebin_unrewarded_norm_day5 = mean(lickrate_includebin_unrewarded_norm(:,:,5),3,'omitnan');
mean_licks_include_unrewarded_A_day5 = squeeze(mean(lickrate_includebin_unrewarded_norm_day5(:,zoneAmice),2,'omitnan'));
std_licks_include_unrewarded_A_day5 = squeeze(std(lickrate_includebin_unrewarded_norm_day5(:,zoneAmice),0,2,'omitnan'));
sem_licks_include_unrewarded_A_day5 = std_licks_include_unrewarded_A_day5/sqrt(length(zoneAmice));
mean_licks_include_unrewarded_B_day5 = squeeze(mean(lickrate_includebin_unrewarded_norm_day5(:,zoneBmice),2,'omitnan'));
std_licks_include_unrewarded_B_day5 = squeeze(std(lickrate_includebin_unrewarded_norm_day5(:,zoneBmice),0,2,'omitnan'));
sem_licks_include_unrewarded_B_day5 = std_licks_include_unrewarded_B_day5/sqrt(length(zoneBmice));

lickrate_includebin_unrewarded_norm_day45 = mean(lickrate_includebin_unrewarded_norm(:,:,4:5),3,'omitnan');
mean_licks_include_unrewarded_A_day45 = squeeze(mean(lickrate_includebin_unrewarded_norm_day45(:,zoneAmice),2,'omitnan'));
std_licks_include_unrewarded_A_day45 = squeeze(std(lickrate_includebin_unrewarded_norm_day45(:,zoneAmice),0,2,'omitnan'));
sem_licks_include_unrewarded_A_day45 = std_licks_include_unrewarded_A_day45/sqrt(length(zoneAmice));
mean_licks_include_unrewarded_B_day45 = squeeze(mean(lickrate_includebin_unrewarded_norm_day45(:,zoneBmice),2,'omitnan'));
std_licks_include_unrewarded_B_day45 = squeeze(std(lickrate_includebin_unrewarded_norm_day45(:,zoneBmice),0,2,'omitnan'));
sem_licks_include_unrewarded_B_day45 = std_licks_include_unrewarded_B_day45/sqrt(length(zoneBmice));

figure('Position',[100 100 100 200])
ax = axes('Position',[0.1 0.55 0.8 0.4]);
patch([reward_zones(1) reward_zones(1)+reward_zone_size reward_zones(1)+reward_zone_size reward_zones(1)]+0.75,...
    [-2 -2 10 10],'k','FaceColor',[0 0 1],'EdgeColor','none','FaceAlpha',0.15);
hold on
patch([control_zones(1) control_zones(1)+reward_zone_size control_zones(1)+reward_zone_size control_zones(1)]+0.75,...
    [-2 -2 10 10],'k','FaceColor',[1 0.5 0],'EdgeColor','none','FaceAlpha',0.15);
x = zbins+0.75;
x(bins_to_exclude) = [];
y = mean_licks_include_unrewarded_A_day45(:)';
s = sem_licks_include_unrewarded_A_day45(:)';
y(bins_to_exclude) = [];
s(bins_to_exclude) = [];
y0 = 0;
plot(x,y0+mean(y)*ones(size(x)),'--k','Color',[0.6 0.6 0.6]);
patch([x fliplr(x)],y0+[(y+s) fliplr(y-s)],'k','FaceColor',[0 0 1],'EdgeColor','none','FaceAlpha',0.3);
plot(x,y0+y,'Color',[0 0 1],'LineWidth',1)
ylim([0 0.9])
xticks([])
yticks([0 0.5])

ax = axes('Position',[0.1 0.1 0.8 0.4]);
patch([reward_zones(1) reward_zones(1)+reward_zone_size reward_zones(1)+reward_zone_size reward_zones(1)]+0.75,...
    [-2 -2 10 10],'k','FaceColor',[0 0 1],'EdgeColor','none','FaceAlpha',0.15);
hold on
patch([control_zones(1) control_zones(1)+reward_zone_size control_zones(1)+reward_zone_size control_zones(1)]+0.75,...
    [-2 -2 10 10],'k','FaceColor',[1 0.5 0],'EdgeColor','none','FaceAlpha',0.15);
y = mean_licks_include_unrewarded_B_day45(:)';
s = sem_licks_include_unrewarded_B_day45(:)';
y(bins_to_exclude) = [];
s(bins_to_exclude) = [];
y0 = 0;
plot(x,y0+mean(y)*ones(size(x)),'--k','Color',[0.6 0.6 0.6]);
patch([x fliplr(x)],y0+[(y+s) fliplr(y-s)],'k','FaceColor',[1 0.5 0],'EdgeColor','none','FaceAlpha',0.3);
plot(x,y0+y,'Color',[1 0.5 0],'LineWidth',1)
yticks([0 0.5])
ylim([0 1])
xlim([0 1.5])


%% fraction of licking in reward and control zones
trials_to_include = 1:40;
zone_lick_include = nan(num_reps,num_days,num_mice,4);
for m = 1:num_mice
    reward_bins = find(zbins>=(reward_zones(m)) & zbins<(reward_zones(m)+reward_zone_size));
    anticipatory_bins = find(zbins>=reward_zones(m) & zbins<(reward_zones(m)+anticipation_zone_size));
    control_bins = find(zbins>=(control_zones(m)) & zbins<(control_zones(m)+reward_zone_size));
    all_bins = 1:num_zbins;
    for d = 1:num_days
        %get amount of licking in each of 3 zones
        zone_lick_include(:,d,m,1) = sum(lick_bin_include(:,reward_bins,m,d),2,'omitnan');
        zone_lick_include(:,d,m,2) = sum(lick_bin_include(:,anticipatory_bins,m,d),2,'omitnan');
        zone_lick_include(:,d,m,3) = sum(lick_bin_include(:,control_bins,m,d),2,'omitnan');
        zone_lick_include(:,d,m,4) = sum(lick_bin_include(:,all_bins,m,d),2,'omitnan');
    end
end
zone_lick_include_fraction = zone_lick_include./repmat(zone_lick_include(:,:,:,4),[1 1 1 4]);
mean_zone_lick_include_fraction = squeeze(mean(zone_lick_include_fraction(trials_to_include,:,:,:),'omitnan'));

%fraction of licks at reward zone
zone = 1;
figure('Position',[100 100 350 200])
y = 100*mean(mean_zone_lick_include_fraction(:,zoneAmice,zone),2,'omitnan')';
ys = 100*std(mean_zone_lick_include_fraction(:,zoneAmice,zone),0,2,'omitnan')';
ys = ys/sqrt(length(zoneAmice));
chance_level = 100*length(reward_bins)/(num_zbins-length(bins_to_exclude));
x = 1:5;
patch([x fliplr(x)],[(y+ys) fliplr(y-ys)],'k','FaceColor','b','EdgeColor','none','FaceAlpha',0.3);
% plot(repmat(x',[1 5]),100*mean_zone_lick_include_fraction(:,zoneAmice,zone),'b','LineWidth',0.25)
hold on
plot(x,chance_level*ones(1,5),'--k')
plot(x,y,'b','LineWidth',2)
xticks(1:5)
xlim([0.75 5.25])
ylim([0 100])
ylabel('licks in reward zone (%)')
xlabel('day of training')

%fraction of licks at control zone
zone = 3;
y = 100*mean(mean_zone_lick_include_fraction(:,zoneAmice,zone),2,'omitnan')';
ys = 100*std(mean_zone_lick_include_fraction(:,zoneAmice,zone),0,2,'omitnan')';
ys = ys/sqrt(length(zoneAmice));
x = 1:5;
patch([x fliplr(x)],[(y+ys) fliplr(y-ys)],'k','FaceColor',[1 0.5 0],'EdgeColor','none','FaceAlpha',0.3);
% plot(repmat(x',[1 5]),100*mean_zone_lick_include_fraction(:,zoneAmice,zone),'Color',[1 0.5 0],'LineWidth',0.25)
plot(x,chance_level*ones(1,5),'--k')
plot(x,y,'Color',[1 0.5 0],'LineWidth',2)
xticks(1:5)
xlim([0.75 5.25])
ylim([0 100])
ylabel('licks (%)')
xlabel('day of training')

[~,iii] = legend({'','','reward zone','','','control zone'},'Location','NorthEastOutside');

%unrewarded trials
zone_lick_include_fraction_unrewarded = zone_lick_include_fraction;
rewarded_zones = permute(rewarded_trials,[1 3 2]);
rewarded_zones = logical(repmat(rewarded_zones,[1 1 1 4]));
zone_lick_include_fraction_unrewarded(rewarded_zones) = nan;
mean_zone_lick_include_fraction_unrewarded = squeeze(mean(zone_lick_include_fraction_unrewarded,'omitnan'));

zone_lick_fraction_unrewarded_day45 = squeeze(mean(mean_zone_lick_include_fraction_unrewarded(:,:,:),1,'omitnan'));
zone_lick_fraction_unrewarded_day4 = squeeze(mean_zone_lick_include_fraction_unrewarded(4,:,:));
zone_lick_fraction_unrewarded_day5 = squeeze(mean_zone_lick_include_fraction_unrewarded(5,:,:));
% zone_lick_fraction_unrewarded_day45: [mice=10, zone=4(reward,anticipatory,control,all)]

%lick fraction selectivity index 
figure('Position',[100 100 350 200])
i_r = mean_zone_lick_include_fraction(:,:,1);
i_c = mean_zone_lick_include_fraction(:,:,3);
lfsi = (i_r-i_c)./(i_r+i_c);
y = mean(lfsi(:,zoneAmice),2,'omitnan')';
ys = std(lfsi(:,zoneAmice),0,2,'omitnan')';
ys = ys/sqrt(length(zoneAmice));
x = 1:5;
patch([x fliplr(x)],[(y+ys) fliplr(y-ys)],'k','FaceColor',green_color,'EdgeColor','none','FaceAlpha',0.3);
hold on
% plot(repmat(x',[1 5]),100*mean_zone_lick_include_fraction(:,zoneAmice,zone),'Color',[1 0.5 0],'LineWidth',0.25)
plot(x,zeros(1,5),'--k')
plot(x,y,'Color',green_color,'LineWidth',2)
xticks(1:5)
xlim([0.75 5.25])
ylim([-0.7 1])
ylabel('selectivity index')
xlabel('day of training')
[~,iii] = legend({'','','reward zone','','','control zone'},'Location','NorthEastOutside');


%lick fraction selectivity index, both mouse groups
figure('Position',[100 100 350 200])
i_r = mean_zone_lick_include_fraction(:,:,1);
i_c = mean_zone_lick_include_fraction(:,:,3);
lfsi = (i_r-i_c)./(i_r+i_c);
y = mean(lfsi(:,zoneAmice),2,'omitnan')';
ys = std(lfsi(:,zoneAmice),0,2,'omitnan')';
ys = ys/sqrt(length(zoneAmice));
x = 1:5;
patch([x fliplr(x)],[(y+ys) fliplr(y-ys)],'k','FaceColor',blue_color,'EdgeColor','none','FaceAlpha',0.3);
hold on
% plot(repmat(x',[1 5]),100*mean_zone_lick_include_fraction(:,zoneAmice,zone),'Color',[1 0.5 0],'LineWidth',0.25)
plot(x,zeros(1,5),'--k')
plot(x,y,'Color',blue_color,'LineWidth',2)

y = -mean(lfsi(:,zoneBmice),2,'omitnan')';
ys = std(lfsi(:,zoneBmice),0,2,'omitnan')';
ys = ys/sqrt(length(zoneBmice));
x = 1:5;
patch([x fliplr(x)],[(y+ys) fliplr(y-ys)],'k','FaceColor',orange_color,'EdgeColor','none','FaceAlpha',0.3);
hold on
% plot(repmat(x',[1 5]),100*mean_zone_lick_include_fraction(:,zoneAmice,zone),'Color',[1 0.5 0],'LineWidth',0.25)
plot(x,zeros(1,5),'--k')
plot(x,y,'Color',orange_color,'LineWidth',2)
xticks(1:5)
xlim([0.75 5.25])
ylim([-0.7 1])
ylabel('selectivity index')
xlabel('day of training')
[~,iii] = legend({'','','reward zone','','','control zone'},'Location','NorthEastOutside');



%% scatter and box plot of unrewarded lick fraction
%unrewarded licks at reward zone
figure('Position',[100 100 300 220])
jitterscale = 0;
marker_size = 10;
chance_level = 100*length(reward_bins)/(num_zbins-length(bins_to_exclude))
y = 100*[zone_lick_fraction_unrewarded_day4(:,[3 1])  zone_lick_fraction_unrewarded_day5(:,[3 1])];
x = jitterscale*((rand([1,num_mice])*2)-1);
plot([0 10],chance_level*ones(1,2),'--k','Color',[0.6 0.6 0.6])
hold on
y = [y(:,1:2) nan(num_mice,1) y(:,3:4)];
x0 = 1;
scatter(x0+x(zoneAmice),y(zoneAmice,1),marker_size,'MarkerEdgeColor',blue_color,'LineWidth',1)
scatter(x0+x(zoneBmice),y(zoneBmice,1),marker_size,'MarkerEdgeColor',orange_color,'LineWidth',1)

x0 = 2;
scatter(x0+x(zoneAmice),y(zoneAmice,2),marker_size,'MarkerEdgeColor',blue_color,'LineWidth',1)
scatter(x0+x(zoneBmice),y(zoneBmice,2),marker_size,'MarkerEdgeColor',orange_color,'LineWidth',1)

x0 = 4;
scatter(x0+x(zoneAmice),y(zoneAmice,4),marker_size,'MarkerEdgeColor',blue_color,'LineWidth',1)
scatter(x0+x(zoneBmice),y(zoneBmice,4),marker_size,'MarkerEdgeColor',orange_color,'LineWidth',1)

x0 = 5;
scatter(x0+x(zoneAmice),y(zoneAmice,5),marker_size,'MarkerEdgeColor',blue_color,'LineWidth',1)
scatter(x0+x(zoneBmice),y(zoneBmice,5),marker_size,'MarkerEdgeColor',orange_color,'LineWidth',1)

boxplot(y,'colors','k');
xticks([1 2 4 5])
% xticklabels({'reward zone','control zone'})
xtickangle(30) 
xticklabels({'control','reward','control','reward'})
xlim([0.25 5.75])
ylim([-10 110])
yticks(0:20:100)
% title('unrewarded trials')
ylabel('licks (%)')
[~,i] = legend({'','group A','group B'},'Location','NorthEastOutside','FontSize',8);
i(3).Children.LineWidth = 1;
i(4).Children.LineWidth = 1;
box off

%day 4+5
figure('Position',[100 100 250 220])
jitterscale = 0;
marker_size = 20;
% chance_level = 100*length(reward_bins)/(num_zbins-length(bins_to_exclude))
y = 100*zone_lick_fraction_unrewarded_day45(:,[3 1]);
x = jitterscale*((rand([1,num_mice])*2)-1);
plot([0 10],chance_level*ones(1,2),'--k','Color',[0.6 0.6 0.6])
hold on
x0 = 1;
scatter(x0+x(zoneAmice),y(zoneAmice,1),marker_size,'MarkerEdgeColor',blue_color,'LineWidth',1)
scatter(x0+x(zoneBmice),y(zoneBmice,1),marker_size,'MarkerEdgeColor',orange_color,'LineWidth',1)

x0 = 2;
scatter(x0+x(zoneAmice),y(zoneAmice,2),marker_size,'MarkerEdgeColor',blue_color,'LineWidth',1)
scatter(x0+x(zoneBmice),y(zoneBmice,2),marker_size,'MarkerEdgeColor',orange_color,'LineWidth',1)

boxplot(y,'colors','k');
xticks([1 2])
% xticklabels({'reward zone','control zone'})
xtickangle(30) 
xticklabels({'control','reward'})
xlim([0.25 2.75])
ylim([-10 110])
yticks(0:20:100)
% title('unrewarded trials')
ylabel('licks (%)')
[~,i] = legend({'','group A','group B'},'Location','NorthEastOutside','FontSize',8);
i(3).Children.LineWidth = 1;
i(4).Children.LineWidth = 1;
box off


%% statistical test of unrewarded lick fraction at reward vs control zone
pvalue = signrank(zone_lick_fraction_unrewarded_day45(:,1),zone_lick_fraction_unrewarded_day45(:,3),'tail','both')


%% (zone B) fraction of licking in reward and control zones
%fraction of licks at reward zone
zone = 1;
figure('Position',[100 100 350 200])
y = 100*mean(mean_zone_lick_include_fraction(:,zoneBmice,zone),2,'omitnan')';
ys = 100*std(mean_zone_lick_include_fraction(:,zoneBmice,zone),0,2,'omitnan')';
chance_level = 100*length(reward_bins)/(num_zbins-length(bins_to_exclude));
x = 1:5;
patch([x fliplr(x)],[(y+ys) fliplr(y-ys)],'k','FaceColor','b','EdgeColor','none','FaceAlpha',0.3);
% plot(repmat(x',[1 5]),100*mean_zone_lick_include_fraction(:,zoneAmice,zone),'b','LineWidth',0.25)
hold on
plot(x,chance_level*ones(1,5),'--k')
plot(x,y,'b','LineWidth',2)
xticks(1:5)
xlim([0.75 5.25])
ylim([0 100])
ylabel('licks in reward zone (%)')

%fraction of licks at control zone
zone = 3;
y = 100*mean(mean_zone_lick_include_fraction(:,zoneBmice,zone),2,'omitnan')';
ys = 100*std(mean_zone_lick_include_fraction(:,zoneBmice,zone),0,2,'omitnan')';
x = 1:5;
patch([x fliplr(x)],[(y+ys) fliplr(y-ys)],'k','FaceColor',[1 0.5 0],'EdgeColor','none','FaceAlpha',0.3);
% plot(repmat(x',[1 5]),100*mean_zone_lick_include_fraction(:,zoneAmice,zone),'Color',[1 0.5 0],'LineWidth',0.25)
plot(x,chance_level*ones(1,5),'--k')
plot(x,y,'Color',[1 0.5 0],'LineWidth',2)
xticks(1:5)
xlim([0.75 5.25])
ylim([0 100])
ylabel('licks (%)')
xlabel('day of training')

[~,iii] = legend({'','','reward zone','','','control zone'},'Location','NorthEastOutside');

%unrewarded trials
zone_lick_include_fraction_unrewarded = zone_lick_include_fraction;
rewarded_zones = permute(rewarded_trials,[1 3 2]);
rewarded_zones = logical(repmat(rewarded_zones,[1 1 1 4]));
zone_lick_include_fraction_unrewarded(rewarded_zones) = nan;
mean_zone_lick_include_fraction_unrewarded = squeeze(mean(zone_lick_include_fraction_unrewarded,'omitnan'));

zone_lick_fraction_unrewarded_day45 = squeeze(mean(mean_zone_lick_include_fraction_unrewarded(:,:,:),1,'omitnan'));
% zone_lick_fraction_unrewarded_day45: [mice=10, zone=4(rew,ant,con,all)]



%% How long do mice take to traverse the track?
%average of all mice (excluding timeouts)
tmp = time_bin;
tmp(data_timeouts) = nan;
colors = parula(num_reps);
figure()
for d = 1:num_days
    subplot(1,num_days,d)
    for r = 1:num_reps
        plot(zbins,mean(tmp(r,:,:,d),3,'omitnan'),'k','Color',colors(r,:))
        hold on
    end
    ylim([0 40])
end

%% correlation between licking and time spent
figure('Position',[100 100 300 300])
x = dur_bin(:);
naninds = isnan(x);
x(naninds) = [];
y = lick_bin(:);
y(naninds) = [];
scatter(x,y,5,'ok','filled','MarkerEdgeColor','none','MarkerFaceAlpha',0.3)
hold on
[rho,pval] = corr(x,y);
slope = x\y;
plot([0 max_trial_duration],[0 slope*max_trial_duration],'--k')
xlabel('time spent at location (s)')
ylabel('licks at location')
xlim([0 45])
ylim([0 100])




