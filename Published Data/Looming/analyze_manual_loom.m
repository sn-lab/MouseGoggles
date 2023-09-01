%load the data table
data_dir = "C:\Users\Published Data\Looming\Reaction Log-Combined.xlsx";

t1 = readtable(data_dir,'Sheet','eyepiece_old','Range','K3:M19');
t2 = readtable(data_dir,'Sheet','eyepiece_new','Range',"K3:M56");
t3 = readtable(data_dir,'Sheet','projector_new','Range',"K3:M60");

te = table2array([t1;t2]); %table-eyepiece
tp = table2array(t3); %table-projector


%% calculate/plot
%count the number of samples for each repetition, and count how many were
%scored as a startle
numsamples = zeros(2,10); %first row is eyepiece, 2nd is projector
numstartles = zeros(2,10);
for rep = 1:10
    reprows = find(te(:,2)==rep);
    numsamples(1,rep) = length(reprows);
    numstartles(1,rep) = sum(te(reprows,3)>=1.5);

    reprows = find(tp(:,2)==rep);
    numsamples(2,rep) = length(reprows);
    numstartles(2,rep) = sum(tp(reprows,3)>=1.5);
end

numstartles = numstartles./numsamples;


%% plot exponential decay
%plot the data as a scatterplot, as well as fitted exponential decay curves
figure('Position',[100 100 200 200])
markersize = 15;
x = 1:10;
sx = 1:0.1:10;
y = numstartles;
ft = fittype('a*exp(-b*(x-1)) + c');
fitopts = fitoptions('METHOD','NonlinearLeastSquares','Lower',[0 0.1 0],'Upper',[1 5 1],'Robust','on','StartPoint',[0.8 1 0.25]);

[curve, goodness] = fit(x',y(1,:)',ft,fitopts);
sy = curve.a*exp(-curve.b*(sx-1)) + curve.c;
scatter(1:10,100*y(1,:),markersize,'b','filled');
hold on
plot(sx,100*sy,'Color',[0.3 0.3 1],'LineWidth',1)
curve
[curve, goodness] = fit(x',y(2,:)',ft,fitopts);
sy = curve.a*exp(-curve.b*sx) + curve.c;
scatter(1:10,100*y(2,:),markersize,'r','filled');
hold on
plot(sx,100*sy,'Color',[1 0.3 0.3],'LineWidth',1)

legend({"headset VR","","projector VR"})
ylabel('startle response (%)')
xlabel('stimulus repetition')
ylim([0 85])
xticks([1 10])
xlim([0.5 10.5])

