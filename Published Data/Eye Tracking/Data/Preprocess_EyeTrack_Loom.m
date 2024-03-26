
%% Preprocess data for loom + eye tracking experiment from logged data and raw videos
%set the directory
base_dir = '\Eye Tracking\';
exp_num = 1; %preprocess 1 experiment at a time (for mouse folders 1-5)


%% set constant parameters for all experiments
exp_name = 'loom';
fps = 30; %fps of the raw video
fov = 54; %field of view of the camera (in degrees)
resolution = 800; %resolution of the raw video
redroi_resolution = 500; %resolution of zoomed-in view of the eye
dpp = fov/resolution; %camera degrees/pixel
ppd = 220/164.5; %pixels per degree of the MouseGoggles EyeTrack display
eye_center_yaw = 70; %yaw of the mouse eye optical axis, relative to straight ahead
eye_center_pitch = 10; %pitch of the mouse eye ""
eyepiece_yaw = 45; %yaw orientation of the eyepiece in MouseGoggles EyeTrack
eyepiece_pitch = 15; %pitch orientation ""
interpolation_method = 'linear';
exp_duration = 150; %loom experiment lasts 150 s

%set calibration parameters (manually found using camera_calibration.m)
leftparamater.lens_center_pos = [370 455];
leftparamater.ycam = -2.5; %position of camera
leftparamater.zcam = 10.7;
leftparamater.param_a = 0.08;
leftparamater.param_b = 1;

rightparamater.lens_center_pos = [450 445];
rightparamater.ycam = -5.5;
rightparamater.zcam = 10.7;
rightparamater.param_a = 0.09;
rightparamater.param_b = 1;

%From raw videos, these positions match the ROI positions used in the
%opencv_preprocess.py script to create the processed videos
redroipos_l(1,:) = [425,275];
redroipos_r(1,:) = [350, 400];
redroipos_l(2,:) = [375,300];
redroipos_r(2,:) = [350,350];
redroipos_l(3,:) = [325,275];
redroipos_r(3,:) = [325,375];
redroipos_l(4,:) = [400,300];
redroipos_r(4,:) = [400,375];
redroipos_l(5,:) = [375,325];
redroipos_r(5,:) = [375,375];


%% load bluemean for synchronizing left and right eye imaging
%use the camera's blue values (sensitive to looming stimuli) to synchronize
%eye imaging
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'processed video');

%load left eye imaging blue values
tmp_file = ls(fullfile(tmp_dir,['*eft_' exp_name num2str(exp_num) '_bluemean*.csv']));
t = readtable(fullfile(tmp_dir,tmp_file));
bluemean_l = table2array(t(:,2));
bluemean_l(isnan(bluemean_l)) = [];
time_video_l = (0:size(bluemean_l,1)-1)/fps;

%load right eye imaging blue values
tmp_file = ls(fullfile(tmp_dir,['*ight_' exp_name num2str(exp_num) '_bluemean*.csv']));
t = readtable(fullfile(tmp_dir,tmp_file));
bluemean_r = table2array(t(:,2));
bluemean_r(isnan(bluemean_r)) = [];
time_video_r = (0:size(bluemean_r,1)-1)/fps;

%plot both
figure()
plot(time_video_l,bluemean_l,'r')
hold on
plot(time_video_r,bluemean_r,'b')
legend({'left','right'})

%try finding the perfect temporal offset between the 2 cameras using xcorr 
% (or manually set the temporal offset if this isn't helpful)
shorter_video_length = min([length(bluemean_r) length(bluemean_l)]);
[r,lags] = xcorr(bluemean_l(1:shorter_video_length),bluemean_r(1:shorter_video_length),200,'unbiased');
figure()
plot(lags,r)

%synchronize the left/right eye videos by compensating for the offset
% eyelag_seconds = -86/fps %loom3
% eyelag_seconds = -47/fps %demo1
loom_lag_frames = [-33 -44 -34 -49 -5]; %loom 2-19-24
eyelag_seconds = loom_lag_frames(exp_num)/fps; %(seconds from R start to L start) (negative = right was first)
time_video_r_synced = time_video_r + eyelag_seconds;
time_video_l_synced = time_video_l;

%manually verify synchronization of left/right eye with plot
%plot synchronized figure
figure()
plot(time_video_l_synced,bluemean_l,'r')
hold on
plot(time_video_r_synced,bluemean_r,'b')


%% manually verify synchronization of left/right eye with video (optional)
%show synchronized blueframe video
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'processed video');
tmp_file = ls(fullfile(tmp_dir,['*ight_' exp_name num2str(exp_num) '_blueframe*.avi']));
vr = VideoReader(fullfile(tmp_dir,tmp_file));
tmp_file = ls(fullfile(tmp_dir,['*eft_' exp_name num2str(exp_num) '_blueframe*.avi']));
vl = VideoReader(fullfile(tmp_dir,tmp_file));

%get frames corresponding with experiment timepoints
frames_to_load_r = find(time_video_r_synced>=0 & time_video_r_synced<=150);
frames_to_load_l = find(time_video_l_synced>=0 & time_video_l_synced<=150);
num_frames = min([length(frames_to_load_r) length(frames_to_load_l)]);
time_videos = (0:(num_frames-1))/fps;

%plot frames like a video
figure('Position',[100 100 800 400]);
for f = 300:500
    current_time = time_videos(f);

    %get videos
    frame_r = read(vr,frames_to_load_r(f));
    frame_l = read(vl,frames_to_load_l(f));
    frame_b = [frame_l frame_r];
    imshow(frame_b)
    pause(0.03)
end


%% new load of gameplay video to process files
%load the Godot gameplay video and calculate blue values for upcoming
%synchronization (this section takes a few minutes)
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'game video');
tmp_file = ls(fullfile(tmp_dir,'*.mkv'));
v = VideoReader(fullfile(tmp_dir,tmp_file));
bluemean_gamevideo_l = nan(1,v.NumFrames);
bluemean_gamevideo_r = nan(1,v.NumFrames);
halfw = round(v.Width/2);
for i = 1:v.NumFrames
    frame = read(v,i);
    bluemean_gamevideo_r(1,i) = mean(frame(:,1:halfw,3),"all"); %video is left-right flipped
    bluemean_gamevideo_l(1,i) = mean(frame(:,halfw+1:end,3),"all");
end
time_gamevideo = (0:length(bluemean_gamevideo_r)-1)/v.FrameRate;

%save the values so this section doesn't need to be run again
save(fullfile(tmp_dir,'gamevideo.mat'),'bluemean_gamevideo_l', 'bluemean_gamevideo_r', 'time_gamevideo');


%% load previously processed gameplay files and synchronize
%load the game videos' blue values
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'game video');
load(fullfile(tmp_dir,'gamevideo.mat'),'bluemean_gamevideo_l', 'bluemean_gamevideo_r', 'time_gamevideo');

%synchronize gameplay video to eye videos
gamevideo_lag_seconds = [7.14 0.5 6.75 0.48 0];
time_gamevideo_synced = time_gamevideo + gamevideo_lag_seconds(exp_num);
figure()
plot(time_video_l_synced,bluemean_l,'r')
hold on
plot(time_video_r_synced,bluemean_r,'b')
plot(time_gamevideo_synced,30+bluemean_gamevideo_l,'--r')
plot(time_gamevideo_synced,30+bluemean_gamevideo_r,'--b')


%% load godot logs and synchronize
%load godot logs
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'logs');
tmp_file = ls(fullfile(tmp_dir,'*godotlogs.txt'));
log = [];
for i = 1:size(tmp_file,1)
    t = readtable(fullfile(tmp_dir,tmp_file(i,:)));
    log = [log; table2array(t)];
end
time_log = log(:,6)/1000;
walking_speed = log(:,2);
walking_speed(walking_speed>100) = 0;
loom_distance = log(:,5);
loom_distance(loom_distance>=20 | loom_distance<0.568) = nan;
loom_condition = log(:,4);
loom_condition(loom_distance>=20 | loom_distance<0.568) = nan;

%manually synchronize godot logs
godotlag_seconds = [12.37 3.98 9.4 3 2.5];
exp_start_times = [13 4.74 10.1 3.7 3.25];
time_log_synced = time_log + godotlag_seconds(exp_num);

%verify manual synchronization of godot logs with plot and set actual exp start time
exp_start_time = exp_start_times(exp_num);
exp_stop_time = exp_start_time + exp_duration;
figure()
plot(time_gamevideo_synced,bluemean_gamevideo_l,'--r')
hold on
plot(time_gamevideo_synced,bluemean_gamevideo_r,'--b')
plot(time_log_synced,walking_speed+130)
plot([exp_start_time exp_start_time],[0 100],'g','LineWidth',1)
plot([exp_stop_time exp_stop_time],[0 100],'g','LineWidth',1)


%% manually verify synchronization of godot logs with video (optional)
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'game video');
tmp_file = ls(fullfile(tmp_dir,'*.mkv'));
v = VideoReader(fullfile(tmp_dir,tmp_file));
figure('Position',[100 100 480 480])
starttime = time_log_synced(i);
startframe = find(time_gamevideo_synced>=starttime,1);
for frameind = startframe:v.NumFrames
    curt = time_gamevideo_synced(frameind);
    frame = read(v,frameind);
    subplot(2,1,1)
    imshow(frame)
    [~, cur_log_ind] = min(abs(time_log_synced-curt));
    subplot(2,1,2)
    plot(time_log_synced(1:cur_log_ind),log(1:cur_log_ind,2));
    xlim([curt-2 curt+2])
    pause(0.03)
end


%% load and process eye/pupil tracking coordinates
%set parameters
camera_pitch_angle = 15; %viewing angle of the camera
pupil_x = [2 5]; %column indices of left and right pupil x-coordinates from deeplabcut tracking
pupil_y = pupil_x + 1; %same, but for y coordinates
pupil_conf = pupil_x + 2; %tracking confidence score for each x,y coordinate

%column indices of left and right eyelid coordinates from deeplabcut tracking
lid_horiz_x = [14 17]; 
lid_horiz_y = lid_horiz_x + 1;
lid_horiz_conf = lid_horiz_x + 2;

%column indices of top and bottom eyelid coordinates from deeplabcut tracking
lid_vert_x = [20 23]; %up and down
lid_vert_y = lid_vert_x + 1;
lid_vert_conf = lid_vert_x + 2;

conf_threshold = 0.9; %minimum confidence score to include from tracked data
max_eyeopendist_fraction = 0.3; %minimum fraction eye has to be opened for pupil coordinates to be included
medfilt_n = 5; %median filter n points
avg_lid_length_mm = 2.6; %from observation: average eyelid length
avg_eye_pupil_radius_mm = 1.3; %from literature: average eyeball center-to-pupil distance

%load left eye tracking
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'dlc');
tmp_file = ls(fullfile(tmp_dir,'*eft*.csv'));
t = readtable(fullfile(tmp_dir,tmp_file));
datalen_l = size(t,1);

%get left horizontal eyelid tracking
leftlidhoriz_x = table2array(t(:,lid_horiz_x));
leftlidhoriz_y = table2array(t(:,lid_horiz_y));
tmp_conf = table2array(t(:,lid_horiz_conf));
leftlidhoriz_x(tmp_conf<conf_threshold) = nan;
leftlidhoriz_y(tmp_conf<conf_threshold) = nan;

%get left vertical eyelid tracking
leftlidvert_x = table2array(t(:,lid_vert_x));
leftlidvert_y = table2array(t(:,lid_vert_y));
tmp_conf = table2array(t(:,lid_vert_conf));
leftlidvert_x(tmp_conf<conf_threshold) = nan;
leftlidvert_y(tmp_conf<conf_threshold) = nan;

%get left pupil tracking
leftpupil_x = table2array(t(:,pupil_x));
leftpupil_y = table2array(t(:,pupil_y));
tmp_conf = table2array(t(:,pupil_conf));
leftpupil_x(tmp_conf<conf_threshold) = nan;
leftpupil_y(tmp_conf<conf_threshold) = nan;

%get right eye tracking
tmp_file = ls(fullfile(tmp_dir,'*ight*.csv'));
t = readtable(fullfile(tmp_dir,tmp_file));
datalen_r = size(t,1);

%get right horizontal eyelid tracking
rightlidhoriz_x = table2array(t(:,lid_horiz_x));
rightlidhoriz_y = table2array(t(:,lid_horiz_y));
tmp_conf = table2array(t(:,lid_horiz_conf));
rightlidhoriz_x(tmp_conf<conf_threshold) = nan;
rightlidhoriz_y(tmp_conf<conf_threshold) = nan;

%get right vertical eyelid tracking
rightlidvert_x = table2array(t(:,lid_vert_x));
rightlidvert_y = table2array(t(:,lid_vert_y));
tmp_conf = table2array(t(:,lid_vert_conf));
rightlidvert_x(tmp_conf<conf_threshold) = nan;
rightlidvert_y(tmp_conf<conf_threshold) = nan;

%get right pupil tracking
rightpupil_x = table2array(t(:,pupil_x));
rightpupil_y = table2array(t(:,pupil_y));
tmp_conf = table2array(t(:,pupil_conf));
rightpupil_x(tmp_conf<conf_threshold) = nan;
rightpupil_y(tmp_conf<conf_threshold) = nan;

%convert redroi coordinates to coordinates in original, uncropped image
x_in_pixels = nan(max([datalen_l datalen_r]),12);
y_in_pixels = nan(max([datalen_l datalen_r]),12);
x_in_pixels(1:datalen_l,1:6) = [leftlidhoriz_x leftlidvert_x leftpupil_x] + redroipos_l(exp_num,1) - redroi_resolution/2;
x_in_pixels(1:datalen_r,7:12) = [rightlidhoriz_x rightlidvert_x rightpupil_x] + redroipos_r(exp_num,1) - redroi_resolution/2;
y_in_pixels(1:datalen_l,1:6) = [leftlidhoriz_y leftlidvert_y leftpupil_y] + redroipos_l(exp_num,2) - redroi_resolution/2;
y_in_pixels(1:datalen_r,7:12) = [rightlidhoriz_y rightlidvert_y rightpupil_y] + redroipos_r(exp_num,2) - redroi_resolution/2;

%apply calibrated warping from camera view to eye plane 
% (see "manual_calibration.m" for details
ycam = nan(max([datalen_l datalen_r]),12);
zcam = nan(max([datalen_l datalen_r]),12);
param_a = nan(max([datalen_l datalen_r]),12);
param_b = nan(max([datalen_l datalen_r]),12);
ycam(1:datalen_l,1:6) = leftparamater.ycam;
zcam(1:datalen_l,1:6) = leftparamater.zcam;
param_a(1:datalen_l,1:6) = leftparamater.param_a;
param_b(1:datalen_l,1:6) = leftparamater.param_b;
ycam(1:datalen_r,7:12) = rightparamater.ycam;
zcam(1:datalen_r,7:12) = rightparamater.zcam;
param_a(1:datalen_r,7:12) = rightparamater.param_a;
param_b(1:datalen_r,7:12) = rightparamater.param_b;
cur_dx = deg2rad(x_in_pixels*dpp);
cur_dy = deg2rad(y_in_pixels*dpp);
cd = ycam.^2 + zcam.^2;
tmp = sin(cur_dx).^2./(1 - sin(cur_dx).^2);
a = 1 - sin(cur_dy).^2.*tmp - sin(cur_dy).^2;
b = 2*ycam.*(sin(cur_dy).^2.*tmp + sin(cur_dy).^2);
c = sin(cur_dy).^2.*(-cd.*tmp - cd);
cur_ly = (-b+sqrt(b.^2 - 4*a.*c))./(2*a);
cur_ly_neg = (-b-sqrt(b.^2 - 4*a.*c))./(2*a);
neg_idx = y_in_pixels<0;
cur_ly(neg_idx) = cur_ly_neg(neg_idx);
cur_ly = real(cur_ly);
cur_lx = sqrt((sin(cur_dx).^2).*(cur_ly.^2 - 2*cur_ly.*ycam + cd)./(1 - sin(cur_dx).^2));
neg_idx = x_in_pixels<0;
cur_lx(neg_idx) = -cur_lx(neg_idx);
cur_lr = sqrt(cur_lx.^2 + cur_ly.^2);
cur_ang = atan2((cur_ly),(cur_lx));
a = param_a;
b = param_b;
c = -cur_lr;
cur_er = ((-b+sqrt(b.^2 - 4*a.*c))./(2*a));
x_in_mm = cur_er.*cos(cur_ang);
y_in_mm = cur_er.*sin(cur_ang);

%get coordinates from array
leftlidhoriz_x_mm = x_in_mm(1:datalen_l,1:2);
leftlidvert_x_mm = x_in_mm(1:datalen_l,3:4);
leftpupil_x_mm = x_in_mm(1:datalen_l,5:6);
rightlidhoriz_x_mm = x_in_mm(1:datalen_r,7:8);
rightlidvert_x_mm = x_in_mm(1:datalen_r,9:10);
rightpupil_x_mm = x_in_mm(1:datalen_r,11:12);
leftlidhoriz_y_mm = y_in_mm(1:datalen_l,1:2);
leftlidvert_y_mm = y_in_mm(1:datalen_l,3:4);
leftpupil_y_mm = y_in_mm(1:datalen_l,5:6);
rightlidhoriz_y_mm = y_in_mm(1:datalen_r,7:8);
rightlidvert_y_mm = y_in_mm(1:datalen_r,9:10);
rightpupil_y_mm = y_in_mm(1:datalen_r,11:12);

%get eyelid length, angle, and center
dx = diff(leftlidhoriz_x_mm,1,2);
dy = diff(leftlidhoriz_y_mm,1,2);
eyelid_meanlength_l = mean(sqrt(dx.^2 + dy.^2),'omitnan');
eyelid_angle_l = atan2(dy,dx);
eyelid_meanangle_l = mean(-eyelid_angle_l,'omitnan');
eyelid_center_x_l = mean(leftlidhoriz_x_mm,2);
eyelid_center_y_l = mean(leftlidhoriz_y_mm,2);
dx = diff(rightlidhoriz_x_mm,1,2);
dy = diff(rightlidhoriz_y_mm,1,2);
eyelid_meanlength_r = mean(sqrt(dx.^2 + dy.^2),'omitnan');
eyelid_angle_r = atan2(dy,dx);
eyelid_meanangle_r = mean(-eyelid_angle_r,'omitnan');
eyelid_center_x_r = mean(rightlidhoriz_x_mm,2);
eyelid_center_y_r = mean(rightlidhoriz_y_mm,2);

%get eyelid open values
dx = diff(leftlidvert_x_mm,1,2);
dy = diff(leftlidvert_y_mm,1,2);
eyeopendist_l = sqrt(dx.^2 + dy.^2);
eyelidclosedbool_l = eyeopendist_l<(prctile(eyeopendist_l,99)*max_eyeopendist_fraction);
dx = diff(rightlidvert_x_mm,1,2);
dy = diff(rightlidvert_y_mm,1,2);
eyeopendist_r = sqrt(dx.^2 + dy.^2);
eyelidclosedbool_r = eyeopendist_r<(prctile(eyeopendist_r,99)*max_eyeopendist_fraction);

%center pupil coordinates to eyelid center and rotate to horizontal
leftpupil_relx_mm = leftpupil_x_mm - repmat(eyelid_center_x_l,[1 2]);
leftpupil_rely_mm = leftpupil_y_mm - repmat(eyelid_center_y_l,[1 2]);
rightpupil_relx_mm = rightpupil_x_mm - repmat(eyelid_center_x_r,[1 2]);
rightpupil_rely_mm = rightpupil_y_mm - repmat(eyelid_center_y_r,[1 2]);
[leftpupil_relx_mm, leftpupil_rely_mm, ~]  = rotate_coordinates(leftpupil_relx_mm, leftpupil_rely_mm, ones(size(leftpupil_relx_mm)),[-eyelid_meanangle_l 0 0]);
[rightpupil_relx_mm, rightpupil_rely_mm, ~]  = rotate_coordinates(rightpupil_relx_mm, rightpupil_rely_mm, ones(size(rightpupil_relx_mm)),[-eyelid_meanangle_r 0 0]);

%get pupil diameter and center
dx = diff(leftpupil_relx_mm,1,2);
dy = diff(leftpupil_rely_mm,1,2);
leftpupildiam = sqrt(dx.^2 + dy.^2);
leftpupilcenter_x = mean(leftpupil_relx_mm,2);
leftpupilcenter_y = mean(leftpupil_rely_mm,2);
dx = diff(rightpupil_relx_mm,1,2);
dy = diff(rightpupil_rely_mm,1,2);
rightpupildiam = sqrt(dx.^2 + dy.^2);
rightpupilcenter_x = mean(rightpupil_relx_mm,2);
rightpupilcenter_y = mean(rightpupil_rely_mm,2);

%delete pupil coordinates when eyelid is closed
leftpupildiam(eyelidclosedbool_l) = nan;
leftpupilcenter_x(eyelidclosedbool_l) = nan;
leftpupilcenter_y(eyelidclosedbool_l) = nan;
rightpupildiam(eyelidclosedbool_r) = nan;
rightpupilcenter_x(eyelidclosedbool_r) = nan;
rightpupilcenter_y(eyelidclosedbool_r) = nan;

%smooth remaining values
leftpupildiam = medfilt1(leftpupildiam,medfilt_n);
leftpupilcenter_x = medfilt1(leftpupilcenter_x,medfilt_n);
leftpupilcenter_y = medfilt1(leftpupilcenter_y,medfilt_n);
rightpupildiam = medfilt1(rightpupildiam,medfilt_n);
rightpupilcenter_x = medfilt1(rightpupilcenter_x,medfilt_n);
rightpupilcenter_y = medfilt1(rightpupilcenter_y,medfilt_n);

%convert eye movements from [x, y] in mm to [yaw, pitch] in deg
lefteye_yaw = rad2deg(atan2(leftpupilcenter_x,avg_eye_pupil_radius_mm));
lefteye_pitch = rad2deg(atan2(leftpupilcenter_y,avg_eye_pupil_radius_mm));
righteye_yaw = rad2deg(atan2(rightpupilcenter_x,avg_eye_pupil_radius_mm));
righteye_pitch = rad2deg(atan2(rightpupilcenter_y,avg_eye_pupil_radius_mm));

%interpolate missing values
leftpupildiam = fillmissing(leftpupildiam,interpolation_method,'MissingLocations',isnan(leftpupildiam));
lefteye_yaw = fillmissing(lefteye_yaw,interpolation_method,'MissingLocations',isnan(lefteye_yaw));
lefteye_pitch = fillmissing(lefteye_pitch,interpolation_method,'MissingLocations',isnan(lefteye_pitch));
rightpupildiam = fillmissing(rightpupildiam,interpolation_method,'MissingLocations',isnan(rightpupildiam));
righteye_yaw = fillmissing(righteye_yaw,interpolation_method,'MissingLocations',isnan(righteye_yaw));
righteye_pitch = fillmissing(righteye_pitch,interpolation_method,'MissingLocations',isnan(righteye_pitch));

%set game video optical centers
lefteye_center_x_pixels = 120 - ppd*(eye_center_yaw-eyepiece_yaw); %adjust for headset/eye yaw/pitch
lefteye_center_y_pixels = 120 + ppd*(eye_center_pitch-eyepiece_pitch);
righteye_center_x_pixels = 240+120 + ppd*(eye_center_yaw-eyepiece_yaw);
righteye_center_y_pixels = 120 + ppd*(eye_center_pitch-eyepiece_pitch);

%convert angle (deg) to pixels from center of each image
lefteye_x_rel_pix = lefteye_yaw*ppd + lefteye_center_x_pixels;
lefteye_y_rel_pix = lefteye_pitch*ppd + lefteye_center_y_pixels;
righteye_x_rel_pix = righteye_yaw*ppd + righteye_center_x_pixels;
righteye_y_rel_pix = righteye_pitch*ppd + righteye_center_y_pixels;


%% verify synchronization of eye and pupil tracking with video (optional)
%load annotated eye tracking videos from deeplabcut
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'dlc');
tmp_file = ls(fullfile(tmp_dir,'*ight*.mp4'));
vr = VideoReader(fullfile(tmp_dir,tmp_file));
tmp_file = ls(fullfile(tmp_dir,'*eft*.mp4'));
vl = VideoReader(fullfile(tmp_dir,tmp_file));

%plot eye images like a video
current_time = exp_start_time;
while current_time<current_time+10
    %get eye video
    [~,cur_ind_video_r] = min(abs(time_video_r_synced-current_time));
    frame_r = read(vr,cur_ind_video_r);
    [~,cur_ind_video_l] = min(abs(time_video_l_synced-current_time));
    frame_l = read(vl,cur_ind_video_l);

    %combine into a single frame
    frame_all = [frame_l frame_r];
    imshow(frame_all)
    hold on

    %create a scatterplot of tracking coordinates over annotated video
    scatter([leftlidhoriz_x(cur_ind_video_l,:) leftlidvert_x(cur_ind_video_l,:) leftpupil_x(cur_ind_video_l,:)],...
        [leftlidhoriz_y(cur_ind_video_l,:) leftlidvert_y(cur_ind_video_l,:) leftpupil_y(cur_ind_video_l,:)]);
    scatter([rightlidhoriz_x(cur_ind_video_r,:) rightlidvert_x(cur_ind_video_r,:) rightpupil_x(cur_ind_video_r,:)] + redroi_resolution,...
        [rightlidhoriz_y(cur_ind_video_r,:) rightlidvert_y(cur_ind_video_r,:) rightpupil_y(cur_ind_video_r,:)]);

    pause(0.5)
    cla(gca)
    current_time = current_time+0.5;
end


%% save all synchronized data, and save a comprehensive dataset resampled @ 60 Hz
%save all data
data.exp_startstop_times = [exp_start_time exp_stop_time];
data.time_log_synced = time_log_synced;
data.time_video_r_synced = time_video_r_synced;
data.time_video_l_synced = time_video_l_synced;
data.lefteye_yaw = lefteye_yaw;
data.lefteye_pitch = lefteye_pitch;
data.leftpupildiam = leftpupildiam;
data.righteye_yaw = righteye_yaw;
data.righteye_pitch = righteye_pitch;
data.rightpupildiam = rightpupildiam;
data.loom_distance = loom_distance;
data.loom_condition = loom_condition;
data.walking_speed = walking_speed;

%resample all data into a common set of timestamps
alignedTime = linspace(exp_start_time,exp_stop_time,(60*exp_duration)+1);
synced_data.datanames = {'lefteye_yaw', 'lefteye_pitch', 'leftpupildiam', 'righteye_yaw', 'righteye_pitch', 'rightpupildiam', 'loom_distance', 'loom_condition', 'walking_speed'};
synced_data.data(:,1) = align_data(lefteye_yaw',time_video_l_synced,alignedTime);
synced_data.data(:,2) = align_data(lefteye_pitch',time_video_l_synced,alignedTime);
synced_data.data(:,3) = align_data(leftpupildiam',time_video_l_synced,alignedTime);
synced_data.data(:,4) = align_data(righteye_yaw',time_video_r_synced,alignedTime);
synced_data.data(:,5) = align_data(righteye_pitch',time_video_r_synced,alignedTime);
synced_data.data(:,6) = align_data(rightpupildiam',time_video_r_synced,alignedTime);
synced_data.data(:,7) = align_data(loom_distance',time_log_synced',alignedTime);
synced_data.data(:,8) = align_data(loom_condition',time_log_synced',alignedTime);
synced_data.data(:,9) = align_data(walking_speed',time_log_synced',alignedTime);
synced_data.data = fillmissing(synced_data.data,interpolation_method,'MissingLocations',isnan(synced_data.data));
synced_data.time = linspace(0,exp_duration,(60*exp_duration)+1);
save(fullfile(base_dir,['mouse' num2str(exp_num)],'data.mat'),"data","synced_data")


%% create a composite video of eye tracking during looming stimuli, with plotted data
%load annotated eye tracking videos
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'dlc');
tmp_file = ls(fullfile(tmp_dir,'*ight*.mp4'));
vr = VideoReader(fullfile(tmp_dir,tmp_file));
tmp_file = ls(fullfile(tmp_dir,'*eft*.mp4'));
vl = VideoReader(fullfile(tmp_dir,tmp_file));

%load gameplay video
tmp_dir = fullfile(base_dir,['mouse' num2str(exp_num)],'game video');
tmp_file = ls(fullfile(tmp_dir,'game.mkv'));
vg = VideoReader(fullfile(tmp_dir,tmp_file));

%get indices of frames during experiment
frames_to_load_r = find(time_video_r_synced>=0 & time_video_r_synced<=150);
frames_to_load_l = find(time_video_l_synced>=0 & time_video_l_synced<=150);
frames_to_load_g = find(time_gamevideo_synced>=0 & time_gamevideo_synced<=150);
num_frames = min([length(frames_to_load_r) length(frames_to_load_l)]);
time_videos = (0:(num_frames-1))/fps;

%create figures for data plotting
plotheight = 500;
plotwidth = 500;
F1 = figure('OuterPosition',[0 100 0.8*plotwidth plotheight]);
F2 = figure('OuterPosition',[900 100 0.8*plotwidth plotheight]);
F3 = figure('OuterPosition',[900 100 0.8*plotwidth plotheight]);
FG = figure('InnerPosition',[100 100 480 240]);

%set plot parameters
pre_time = 4;
post_time = 2;
linewidth = 2;
fontsize = 12;

%create a video object to store the composite video
vout = VideoWriter(fullfile(base_dir,['mouse' num2str(exp_num)],'demo.avi'),'Motion JPEG AVI');
vout.Quality = 100;
open(vout);
vout_fps = 30;

%get loom start times (15 total)
loom_distance(isnan(loom_distance)) = 0;
rise_idx = [false; diff(loom_distance)>1];
loom_start_inds = find(diff(rise_idx)==1)+1;
loom_start_times = time_log_synced(loom_start_inds);

loom_dur = 0.78; %loom duration, in s
current_time = exp_start_time; %start video at beginning of experiment
waiting_for_loom_num = 1; %at the start, we're waiting for the 1st loom
while current_time<exp_start_time+30
    %get current eye tracking frames
    [~,cur_ind_video_r] = min(abs(time_video_r_synced-current_time));
    frame_r = read(vr,cur_ind_video_r);
    [~,cur_ind_video_l] = min(abs(time_video_l_synced-current_time));
    frame_l = read(vl,cur_ind_video_l);

    %rotate frames to match the eye angle
    frame_r = imrotate(frame_r,rad2deg(-eyelid_meanangle_r),'crop');
    frame_l = imrotate(frame_l,rad2deg(-eyelid_meanangle_l),'crop');
    frame_r = flipud(frame_r);
    frame_l = flipud(frame_l);

    %adjust brightness (optional)
    frame_r = frame_r*1.0;
    frame_l = frame_l*1.0;

    %resize images
    if size(frame_r)~=redroi_resolution
        frame_r = imresize(frame_r,[redroi_resolution redroi_resolution]);
        frame_l = imresize(frame_l,[redroi_resolution redroi_resolution]);
    end
    
    %add vignette?
    w = size(frame_r,1);
    mask_x = repmat(1:w,[w 1]) - (w/2) - 0.5;
    mask_y = repmat((1:w)',[1 w]) - (w/2) - 0.5;
    mask_r = sqrt(mask_x.^2 + mask_y.^2);
    vignette_mask = double(mask_r<(w/2));
    frame_r = uint8(double(frame_r).*vignette_mask);
    frame_l = uint8(double(frame_l).*vignette_mask);

    %get time indices for data plotting
    start_time = max([exp_start_time current_time-pre_time]);
    stop_time = start_time+pre_time+post_time;
    video_inds_l = time_video_l_synced>=start_time & time_video_l_synced<=current_time;
    video_inds_r = time_video_r_synced>=start_time & time_video_r_synced<=current_time;

    %load game video
    [~,cur_ind] = min(abs(time_gamevideo_synced-current_time));
    frame_g = read(vg,cur_ind);
    frame_g = fliplr(frame_g); %game video is l/r flipped
    [H,W,~] = size(frame_g);
    newH = size(frame_l,1);
    newW = round(W*(newH/H));
    figure(FG)
    cla(gca)
    imshow(frame_g)
    hold on
    axis off
    ax = gca;
    ax.InnerPosition = [0 0 1 1];
    ax.Units = 'normalized';
    ax.FontSize = fontsize;
    ax.LineWidth = linewidth;
    ax.FontWeight = "bold";
    %plot recent eye positions as a scatterplot, where older data fades away
    lposx = lefteye_x_rel_pix(video_inds_l); 
    lposy = (H-lefteye_y_rel_pix(video_inds_l)); %images are plotted upside-down
    alpha_vec = (time_video_l_synced(video_inds_l)-start_time)/(10*pre_time); %fadiing alpha values
    s = scatter(lposx,lposy,'r','MarkerEdgeColor','none','MarkerFaceColor','r');
    s.AlphaData = alpha_vec;
    s.MarkerFaceAlpha = 'flat';
    rposx = righteye_x_rel_pix(video_inds_r);
    rposy = (H-righteye_y_rel_pix(video_inds_r));
    alpha_vec = (time_video_r_synced(video_inds_r)-start_time)/(10*pre_time);
    s = scatter(rposx,rposy,'b','MarkerEdgeColor','none','MarkerFaceColor','b');
    s.AlphaData = alpha_vec;
    s.MarkerFaceAlpha = 'flat';
    %plot crosshairs around optical axis
    crosshair_length = 20;
    plot([lposx(end)-crosshair_length lposx(end)+crosshair_length],[lposy(end) lposy(end)],'k');
    plot([rposx(end) rposx(end)],[rposy(end)-crosshair_length rposy(end)+crosshair_length],'k');
    plot([rposx(end)-crosshair_length rposx(end)+crosshair_length],[rposy(end) rposy(end)],'k');
    plot([lposx(end) lposx(end)],[lposy(end)-crosshair_length lposy(end)+crosshair_length],'k');
    %convert figure frame to image
    frame_g_resized = getframe(gcf);
    frame_g_resized = imresize(frame_g_resized.cdata,[newH newW]);
    frame_g_resized([1:25 476:500],:,:) = 0; %black out border

    %plot walking speed data
    figure(F1)
    cla(gca)
    log_inds = time_log_synced>=start_time & time_log_synced>exp_start_time & time_log_synced<=current_time;
    plot([0 36],[0 0],'--k')
    hold on
    plot(time_log_synced(log_inds)-exp_start_time,walking_speed(log_inds),'k','LineWidth',linewidth)
    if waiting_for_loom_num>1 %plot previous looms
        for i = 1:waiting_for_loom_num-1
            %plot previous loom times
            ts = loom_start_times(i);
            te = ts+loom_dur;
            patch([ts te te ts]-exp_start_time,[-20 -20 40 40],'k','EdgeColor','none','FaceAlpha',0.15)
        end
    end
    if current_time>=loom_start_times(waiting_for_loom_num) %plot current loom
        ts = loom_start_times(waiting_for_loom_num);
        if current_time>=(ts + loom_dur) %plot entire loom
            waiting_for_loom_num = waiting_for_loom_num + 1;
            te = ts+loom_dur;
            patch([ts te te ts]-exp_start_time,[-20 -20 40 40],'k','EdgeColor','none','FaceAlpha',0.15)
        else  %plot partial loom\
            te = current_time;
            patch([ts te te ts]-exp_start_time,[-20 -20 40 40],'k','EdgeColor','none','FaceAlpha',0.15)
        end
    end
    xlim([start_time stop_time]-exp_start_time)
    ylabel('walking speed (cm/s)')
    xlabel('time (s)')
    box off
    ylim([-20 40])
    xticks(0:36)
    ax = gca;
    ax.OuterPosition = [0 0 1 1];
    ax.Units = 'normalized';
    ax.LineWidth = linewidth;
    ax.FontWeight = "bold";
    ax.FontSize = fontsize;
    frameplot1 = getframe(gcf);
    frameplot1 = imresize(frameplot1.cdata,[plotheight, plotwidth]);

    %draw plots for eye pitch
    figure(F2)
    cla(gca)
    plot(time_video_l_synced(video_inds_l)-exp_start_time,lefteye_pitch(video_inds_l),'r','LineWidth',linewidth)
    hold on
    plot(time_video_r_synced(video_inds_r)-exp_start_time,righteye_pitch(video_inds_r),'b','LineWidth',linewidth)
    if waiting_for_loom_num>1 %plot previous loom
        ts = loom_start_times(waiting_for_loom_num-1);
        te = ts+loom_dur;
        patch([ts te te ts]-exp_start_time,[-10 -10 20 20],'k','EdgeColor','none','FaceAlpha',0.15)
    end
    if current_time>=loom_start_times(waiting_for_loom_num) %plot current loom
        ts = loom_start_times(waiting_for_loom_num);
        if current_time>=(ts + loom_dur) %plot entire loom
            waiting_for_loom_num = waiting_for_loom_num + 1;
            te = ts+loom_dur;
            patch([ts te te ts]-exp_start_time,[-10 -10 20 20],'k','EdgeColor','none','FaceAlpha',0.15)
        else  %plot partial loom\
            te = current_time;
            patch([ts te te ts]-exp_start_time,[-10 -10 20 20],'k','EdgeColor','none','FaceAlpha',0.15)
        end
    end
    xlim([start_time stop_time]-exp_start_time)
    ylabel('eye pitch (deg)')
    xlabel('time (s)')
    xticks(0:36)
    box off
    legend({'left eye','right eye'},'Location','northeast');
    legend('boxoff')
    ylim([-5 15])
    ax = gca;
    ax.OuterPosition = [0 0 1 1];
    ax.Units = 'normalized';
    ax.LineWidth = linewidth;
    ax.FontWeight = "bold";
    ax.FontSize = fontsize;
    frameplot2 = getframe(gcf);
    frameplot2 = imresize(frameplot2.cdata,[plotheight, plotwidth]);

    %draw plots for pupil diameter
    figure(F3)
    cla(gca)
    plot(time_video_l_synced(video_inds_l)-exp_start_time,leftpupildiam(video_inds_l),'r','LineWidth',linewidth)
    hold on
    plot(time_video_r_synced(video_inds_r)-exp_start_time,rightpupildiam(video_inds_r),'b','LineWidth',linewidth)
    if waiting_for_loom_num>1 %plot previous loom
        ts = loom_start_times(waiting_for_loom_num-1);
        te = ts+loom_dur;
        patch([ts te te ts]-exp_start_time,[0 0 2 2],'k','EdgeColor','none','FaceAlpha',0.15)
    end
    if current_time>=loom_start_times(waiting_for_loom_num) %plot current loom
        ts = loom_start_times(waiting_for_loom_num);
        if current_time>=(ts + loom_dur) %plot entire loom
            waiting_for_loom_num = waiting_for_loom_num + 1;
            te = ts+loom_dur;
            patch([ts te te ts]-exp_start_time,[0 0 2 2],'k','EdgeColor','none','FaceAlpha',0.15)
        else  %plot partial loom\
            te = current_time;
            patch([ts te te ts]-exp_start_time,[0 0 2 2],'k','EdgeColor','none','FaceAlpha',0.15)
        end
    end
    xlim([start_time stop_time]-exp_start_time)
    ylabel('pupil diameter (mm)')
    xlabel('time (s)')
    xticks(0:36)
    box off
    legend({'left eye','right eye'},'Location','northeast');
    legend('boxoff')
    ylim([0.5 2])
    ax = gca;
    ax.OuterPosition = [0 0 1 1];
    ax.Units = 'normalized';
    ax.LineWidth = linewidth;
    ax.FontWeight = "bold";
    ax.FontSize = fontsize;
    frameplot3 = getframe(gcf);
    frameplot3 = imresize(frameplot3.cdata,[plotheight, plotwidth]);

    %combine into a single frame and save
    frame_all = [frame_l frame_r; frame_g_resized];
    frameplot_all = [frameplot1; frameplot2; frameplot3];
    [frame_all_h, frame_all_w, ~] = size(frame_all);
    [frameplot_all_h, frameplot_all_w, ~] = size(frameplot_all);
    new_w = frame_all_h*(frameplot_all_w/frameplot_all_h); %keep aspect ratio
    frameplot_all = imresize(frameplot_all,[frame_all_h new_w]);
    frame_all = [frame_all frameplot_all];
    writeVideo(vout,frame_all);

    %increment time
    current_time = current_time + (1/vout_fps);
end
close(vout)
close all
