
%% manually set values for calibration
%adjust settings to calibrate left camera
% view_center_pos = [370 425]; %center position (in pixels) of viewable region
% view_radius = 350; %radius (in pixels) to exclude from the distortion field
% lens_center_pos = [370 455]; %center position (in pixels) of lens
% ycam = -2.5; %y (vertical) position of camera relative to lens center
% zcam = 10.7; %z (depth) position relative to lens surface
% param_a = 0.08; %fitting parameter a
% param_b = 1; %fitting parameter b
% image_filename = "\left calib.png";

%settings for right camera
view_center_pos = [450 415];
view_radius = 350;
lens_center_pos = [450 445];
ycam = -5.5;
zcam = 10.7;
param_a = 0.09;
param_b = 1;
image_filename = "\right calib.png";

%% load calibration image and draw gridlines
%load the calibration image
I = imread(image_filename);
I = I(:,:,1);
fov = 54; %field of view of the camera
resolution = 800;
dpp = fov/resolution;

%create an array of coordinates for a 5 x 5 mm grid
linerange = 5;
horiz_eyelines_y = (-linerange:0.1:linerange)';
horiz_eyelines_y = repmat(horiz_eyelines_y,[1 11]);
horiz_eyelines_x = -linerange:linerange;
horiz_eyelines_x = repmat(horiz_eyelines_x,[size(horiz_eyelines_y,1) 1]);

vert_eyelines_x = (-linerange:0.1:linerange)';
vert_eyelines_x = repmat(vert_eyelines_x,[1 11]);
vert_eyelines_y = -linerange:linerange;
vert_eyelines_y = repmat(vert_eyelines_y,[size(vert_eyelines_x,1) 1]);

all_eyelines_x = [horiz_eyelines_x vert_eyelines_x];
all_eyelines_y = [horiz_eyelines_y vert_eyelines_y];

%plot the mm grid
figure()
plot(all_eyelines_x,all_eyelines_y,'b','LineWidth',2)


%% warp coordinates from eye plane (in mm) to image coordinates (in pixels)
%get eye plane polar coordinates
cur_er = sqrt(all_eyelines_x.^2 + all_eyelines_y.^2); %radial position on eye plane
cur_ang = atan2(all_eyelines_y,all_eyelines_x);

%perform a radial transformation to simulate the lens)
cur_lr = param_a*cur_er.^2 + param_b*cur_er; %radial position on lens
cur_lx = cur_lr.*cos(cur_ang);
cur_ly = cur_lr.*sin(cur_ang);

%perform a transformation to simulate camera tilt
cur_camdist = sqrt(cur_lx.^2 + (cur_ly-ycam).^2 + zcam^2);

cur_dx = asin(cur_lx./cur_camdist); %deg position from camera's perspective
cur_dy = asin(cur_ly./cur_camdist);

%convert from radians to degrees to pixels
all_pixellines_x = rad2deg(cur_dx)/dpp;
all_pixellines_y = rad2deg(cur_dy)/dpp;

%display the warped pixel map overlayed on the calibrated image, to verify
%reasonable calibration
figure()
imshow(I)
hold on
% delete grid coordinates outside viewable region
all_pixellines_r = sqrt((all_pixellines_x + lens_center_pos(1) - view_center_pos(1)).^2 + (all_pixellines_y + lens_center_pos(2) - view_center_pos(2)).^2);
all_pixellines_x(all_pixellines_r>view_radius) = nan;
all_pixellines_y(all_pixellines_r>view_radius) = nan;
plot(all_pixellines_x+lens_center_pos(1),all_pixellines_y+lens_center_pos(2),'r','LineWidth',2)


%% de-warp pixel coordiates back to eye plane mm coordinates
% Once the calibration is finished, this section validates the de-warping 
% code, which is used to convert actual eye/pupil tracking coordinates (in
% pixels) to the absolute position (in mm) along the eye plane.

%calculate degrees from pixels
cur_dx = deg2rad(all_pixellines_x.*dpp);
cur_dy = deg2rad(all_pixellines_y.*dpp);

%quadratic equation to calculate lens [x,y] coordinates from camera
cd = ycam.^2 + zcam.^2;
% cur_lx = sqrt((cur_ly^2 - 2*cur_ly*ycam + cd)/(1/sin(cur_dx)^2 - 1)); %deg position from camera's perspective
% cur_ly^2/sin(cur_dy)^2 = cur_lx^2 + cur_ly^2 - 2*cur_ly*ycam + cd; 
% cur_ly^2*tmp2 = (cur_ly^2 - 2*cur_ly*ycam + cd)*tmp1 + cur_ly^2 - 2*cur_ly*ycam + cd; 
% cur_ly^2*tmp2 = cur_ly^2/tmp1 - 2*cur_ly*ycam/tmp + cd/tmp + cur_ly^2 - 2*cur_ly*ycam + cd;
% zero = cur_ly^2*(1 - sin(cur_dy)^2*tmp1 - sin(cur_dy)^2) +  cur_ly*2*ycam*(sin(cur_dy)^2*tmp1 + sin(cur_dy)^2) + sin(cur_dy)^2*(-cd*tmp1 - cd);
tmp = sin(cur_dx).^2./(1 - sin(cur_dx).^2);
a = 1 - sin(cur_dy).^2.*tmp - sin(cur_dy).^2;
b = 2*ycam*(sin(cur_dy).^2.*tmp + sin(cur_dy).^2);
c = sin(cur_dy).^2.*(-cd*tmp - cd);
cur_ly = (-b+sqrt(b.^2 - 4*a.*c))./(2*a);
cur_ly_neg = (-b-sqrt(b.^2 - 4*a.*c))./(2*a);
neg_idx = all_pixellines_y<0;
cur_ly(neg_idx) = cur_ly_neg(neg_idx);
cur_ly = real(cur_ly);
cur_lx = sqrt((sin(cur_dx).^2).*(cur_ly.^2 - 2*cur_ly*ycam + cd)./(1 - sin(cur_dx).^2));
neg_idx = all_pixellines_x<0;
cur_lx(neg_idx) = -cur_lx(neg_idx);

%calculate eye plane coordinates from lens coordinates
cur_lr = sqrt(cur_lx.^2 + cur_ly.^2);
cur_ang = atan2(cur_ly,cur_lx);
a = param_a;
b = param_b;
c = -cur_lr;
cur_er = (-b+sqrt(b.^2 - 4*a.*c))./(2*a);
dewarped_eyelines_x = cur_er.*cos(cur_ang);
dewarped_eyelines_y = cur_er.*sin(cur_ang);

%plot de-warped grid to validate de-warping procedure
figure()
plot(dewarped_eyelines_x,dewarped_eyelines_y,'b','LineWidth',2)
