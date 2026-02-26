%% Coding for generating a partial least square regression (PSLR) to estimate heavy metal and nitrogen content on kale and basil
% Loading the files in two different tables
clear all
close all
% filename = "PLSR- SIDE VIEW-2 .xlsx";
filename = "PLS- top view-2.xlsx";
plant = 'kale';
opts = detectImportOptions(filename,'Sheet',plant,'NumHeaderLines',0);
T = readtable(filename,opts,'ReadVariableNames',true);

%% Some indices calculation

% For SIDE view
% 
% NDVI = (T.x860-T.x660)./(T.x860+T.x660);
% CIre = (T.x783./T.x705)-1;
% PSRI = (T.x681-T.x499)./T.x751;
% HMSSI = CIre./PSRI;


% % For TOP view
NDVI = (T.x860_3857-T.x661_0691)./(T.x860_3857+T.x661_0691);
CIre = (T.x783_8041./T.x705_5476)-1;
PSRI = (T.x680_0936-T.x499_7963)./T.x750_3343;
HMSSI = CIre./PSRI;

%% Determining the response variable and ploting the average spectrum
[row,col] = size(T);
% 
% % For SIDE view
% nWal = find(string(T.Properties.VariableNames) == "x998") - find(string(T.Properties.VariableNames) == "x500")+1;
% response = T.Cd;
% KaleNIR = T(:,find(string(T.Properties.VariableNames) == "x500"):find(string(T.Properties.VariableNames) == "x998"));

% For TOP view
nWal = find(string(T.Properties.VariableNames) == "x998_8418") - find(string(T.Properties.VariableNames) == "x501_0304")+1;
response = T.Cd;
KaleNIR = T(:,find(string(T.Properties.VariableNames) == "x501_0304"):find(string(T.Properties.VariableNames) == "x998_8418"));

WLs = linspace(500,998,nWal ); 
[dummy,h] = sort(response);
figure(1)
oldorder = get(gcf,'DefaultAxesColorOrder');
set(gcf,'DefaultAxesColorOrder',jet(row));
plot3(repmat(WLs,row,1)',repmat(response(h,:),1,nWal)',table2array(KaleNIR(h,:))');
set(gcf,'DefaultAxesColorOrder',oldorder);
xlabel('Wavelength Index'); ylabel('Nitrogen'); axis('tight');
grid on
%% Modeling

X = table2array(KaleNIR);
y = double(response);
indNA = find(isnan(y));
X(indNA,:)=[];
y(indNA)=[];

I = y > 2*std(y);
y(I) = [];
X(I,:)=[];

% Dividing the data between 70% training and 30% validation
[train,val,~] = dividerand(size(X,1),0.70,0.30,0);

[n,p] = size(X(val,:));

ncomp=4; % number of components to use in the model

% Creating the model with cross validation
[Xl,Yl,Xs,Ys,beta,pctVar,PLSmsep] = plsregress(X(train,:),y(train),ncomp,'cv',10);

yfitPLS = [ones(size(train,2),1) X(train,:)]*beta;
yvalPLS = [ones(size(val,2),1) X(val,:)]*beta;

figure(2)
subplot(2,1,1)
plot(1:(ncomp),cumsum(100*pctVar(2,:)),'k-o','MarkerFaceColor','blue');
xlabel('Number of Latent Variables');
ylabel('Percent Variance Explained in Y');
grid on

subplot(2,1,2)
plot(0:ncomp,sqrt(PLSmsep(2,:)),'k-o','MarkerFaceColor','blue')
% xlabel('Number of components');
ylabel('Estimated RMSE');
% legend({'PLSR' 'PCR'},'location','NE');
grid on
hold off

figure(3)

plot(y(train),yfitPLS,'ko','MarkerFaceColor','blue')
hold on
plot(y(val),yvalPLS,'ko','MarkerFaceColor','red')

xlabel('Observed Response');
ylabel('Fitted Response - PLSR Model');
legend({'Model training fit','Model validation fit'},...
	'location','NW');

[r,m,b] = regression(y(train),yfitPLS,'one');
line(y(train),m.*y(train)+b,'Color','blue')
grid on
xcoord = [0.7,0.77];
ycoord = [0.85,0.8];

annotation('textarrow',xcoord,ycoord,'String',strcat("R^2 = ",string(round(r*100,2)),"%"));

%% PCR
[PCALoadings,PCAScores,PCAVar,PCAt,PCAexp,PCAmu] = pca(X(train,:),'Economy',false);
% residuals = pcares(X);
% PCArmse1 = sqrt(mean(residuals.^2));
% PCArmse2 = std(residuals);
yTrain = y(train);
n = size(train,2);

for i =2:n/2
    
b1 = regress(yTrain-mean(yTrain), PCAScores(:,1:i));
b1 = PCALoadings(:,1:i)*b1;
b1 = [mean(yTrain) - mean(X(train,:))*b1; b1];
y1 = [ones(size(train,2),1) X(train,:)]*b1;
rmse(i) = sqrt(mean((y1-yTrain).^2));

end

n = size(train,2);
p = size(val,2);
ncomp = 4;
betaPCR = regress(yTrain-mean(yTrain), PCAScores(:,1:ncomp));
betaPCR = PCALoadings(:,1:ncomp)*betaPCR;
betaPCR = [mean(yTrain) - mean(X(train,:))*betaPCR; betaPCR];
% yfitPCR = [ones(n,1) X]*betaPCR;
yfitPCR = [ones(n,1) X(train,:)]*betaPCR;
yVal = [ones(size(val,2),1) X(val,:)]*betaPCR;


figure
plot(y(train),yfitPCR,'ko','MarkerFaceColor','blue');
hold on
plot(y(val),yVal,'ko','MarkerFaceColor','red');
xlabel('Observed Response');
ylabel('Fitted Response - PCR Model');
[rPCR,mPCR,bPCR] = regression(y(train),yfitPCR,'one');
line(y(train),mPCR.*y(train)+bPCR,'Color','blue')
grid on
xcoord = [0.7,0.77];
ycoord = [0.8,0.8];
annotation('textarrow',xcoord,ycoord,'String',strcat("R^2 = ",string(round(rPCR*100,2)),"%"));
legend({'Model Training Fit','Model Validation Fit'},'location','NE');
hold off


figure(2)
subplot(2,1,1)
hold on
plot(cumsum(PCAexp(1:n/2)),'k-^','MarkerFaceColor','red');
xlabel('Number of Principal Components');
ylabel('Percent Variance Explained in X');
legend({'PLSR','PCR'},'location','SE');
subplot(2,1,2)
hold on
% PCRmsep = sum(crossval(@pcrsse,X,y,'KFold',10),1) / row;
plot(rmse,'k-^','MarkerFaceColor','red');
xlabel('Number of components');
ylabel('Estimated RMSE');
legend({'PLSR','PCR'},'location','NE');
