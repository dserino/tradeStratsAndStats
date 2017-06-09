clear; close all;

%% inputs
Nlr =  20; % smooth data using this many days
Nte =   3; % number of look back points for extrapolation
Ne  = 100; % length of extrapolation data matrix 
Ntr =  10; % number of look back points for regression
Nr  = 400; % length of regression data matrix

predictMu = false;
predictXi = false;

% need to change this
dir = '~/tradeStratsAndStats/dataAnalysis/matlab/';

%% filename for symbols
filename = 'symbolFiles/testSymbols.txt';

%% save data
SaveFile = 'saveFiles/testDataAnalysis.mat';

%% inputs
doLoad = true;

% start date
year0 = 2014;
month0 = 1;
day0 = 1;

% end date
year1 = 2017;
month1 = 6;
day1 = 21;

%% read in all symbols
if doLoad
  try
    load([dir,SaveFile]);
    fprintf('> Successfully loaded data from %s \n',[dir,SaveFile]);
    fprintf('> Read %d symbols \n',Ns);
  catch
    fprintf('> Cannot load %s \n',[dir,SaveFile]);
    doLoad = false;
  end
end

if ~doLoad
  ReadInYahooFinanceData(dir,filename,SaveFile, ...
                         year0,month0,day0, ...
                         year1,month1,day1);
  load([dir,SaveFile]);
end

n_open      = 1;
n_high      = 2;
n_low       = 3;
n_close     = 4;
n_volume    = 6;
n_adj_close = 7;

% make sure that dates agree for each symbol
CheckDates(data,symbols);

% get prices into high, low, close, and open data
[High,Low,Close,Open] = GetPrices(data,N,Ns);
[Volume] = GetVolume(data,N,Ns);

%% perform analysis
% just look at first index
k = 1;

%% smooth data
% represent data as
% f_n = mu_n + xi_n
% Ideally, 
%  - mu is very smooth and can be extrapolated
%  - xi can be explained from previous data


Mu_H = Close(k,:);
Mu_L = Close(k,:);
Mu_C = Close(k,:);
Mu_O = Close(k,:);

Xi_H = Close(k,:);
Xi_L = Close(k,:);
Xi_C = Close(k,:);
Xi_O = Close(k,:);

I = 1:Nlr;
for n = (Nlr):N
  Mu_H(n)    = sum(High (k,I+n-Nlr))/Nlr;
  Mu_L(n)    = sum(Low  (k,I+n-Nlr))/Nlr;
  Mu_C(n)    = sum(Close(k,I+n-Nlr))/Nlr;
  Mu_O(n)    = sum(Open (k,I+n-Nlr))/Nlr;
  
  Xi_H(n) = High (k,n)-Mu_H(n);
  Xi_L(n) = Low  (k,n)-Mu_L(n);
  Xi_C(n) = Close(k,n)-Mu_C(n);
  Xi_O(n) = Open (k,n)-Mu_O(n);
end

%% predict mu
% mu is smooth and can be extrapolated to a future time
Mu_r_H = Mu_H;
Mu_r_L = Mu_L;
Mu_r_C = Mu_C;
Mu_r_O = Mu_O;

if predictMu
  % data matrices
  % Nte: number of look back points for extrapolation
  % Ne:  length of extrapolation data matrix 
  X_H = zeros(Ne,Nte);
  X_L = zeros(Ne,Nte);
  X_C = zeros(Ne,Nte);
  X_O = zeros(Ne,Nte);
  
  err_sv = [];
  
  for n = (Nlr+Ne+Nte):N

    % compute data matrix
    jStart = n-Ne+1;
    jEnd   = n;
    for j = 1:Nte
      X_H(:,j) = Mu_H( (jStart-j):(jEnd-j) );
      X_L(:,j) = Mu_L( (jStart-j):(jEnd-j) );
      X_C(:,j) = Mu_C( (jStart-j):(jEnd-j) );
      X_O(:,j) = Mu_O( (jStart-j):(jEnd-j) );
    end
    
    % compute SVD
    [~,Sigma_H,V_H] = svd(X_H,'econ');
    [~,Sigma_L,V_L] = svd(X_L,'econ');
    [~,Sigma_C,V_C] = svd(X_C,'econ');
    [~,Sigma_O,V_O] = svd(X_O,'econ');
    
    % lowest singular value
    err_sv = [err_sv,max([Sigma_H(end,end),Sigma_L(end,end), ...
                          Sigma_C(end,end),Sigma_O(end,end)])];
    
    % extract the approximate null space of data matrix
    a_H = V_H(:,end);
    a_L = V_L(:,end);
    a_C = V_C(:,end);
    a_O = V_O(:,end);

    % compute predicted mu
    Mu_r_H(n) = 0;
    Mu_r_L(n) = 0;
    Mu_r_C(n) = 0;
    Mu_r_O(n) = 0;
    for j = 2:Nte
      Mu_r_H(n) = Mu_r_H(n)-Mu_H(n-j+1)*a_H(j)/a_H(1);
      Mu_r_L(n) = Mu_r_L(n)-Mu_L(n-j+1)*a_L(j)/a_L(1);
      Mu_r_C(n) = Mu_r_C(n)-Mu_C(n-j+1)*a_C(j)/a_C(1);
      Mu_r_O(n) = Mu_r_O(n)-Mu_O(n-j+1)*a_O(j)/a_O(1);
    end
    
  end
end

%% predict Xi
Xi_r_H = Xi_H;
Xi_r_L = Xi_L;
Xi_r_C = Xi_C;
Xi_r_O = Xi_O;

if predictXi
  % data matrices
  % Ntr: number of look back points for regression
  % Nr:  length of regression data matrix 
  X_H = zeros(Nr,Ntr);
  X_L = zeros(Nr,Ntr);
  X_C = zeros(Nr,Ntr);
  X_O = zeros(Nr,Ntr);

  % r^2 values for each day
  r_sqr = [];
  
  for n = (Nlr+Nr+Ntr):N
    % compute data matrix
    jStart = n-Nr+1;
    jEnd   = n;
    for j = 1:Ntr
      X_H(:,j) = Xi_H( (jStart-j):(jEnd-j) );
      X_L(:,j) = Xi_L( (jStart-j):(jEnd-j) );
      X_C(:,j) = Xi_C( (jStart-j):(jEnd-j) );
      X_O(:,j) = Xi_O( (jStart-j):(jEnd-j) );
    end
    
    X = [X_H,X_L,X_C,X_O,ones(Nr,1)];

    % regressor
    b_H  = Xi_H(jStart:jEnd)';
    b_L  = Xi_L(jStart:jEnd)';
    b_C  = Xi_C(jStart:jEnd)';
    b_O  = Xi_O(jStart:jEnd)';
    
    % solve for fit
    a_H = X(1:(end-1),:)\b_H(1:(end-1));
    a_L = X(1:(end-1),:)\b_L(1:(end-1));
    a_C = X(1:(end-1),:)\b_C(1:(end-1));
    a_O = X(1:(end-1),:)\b_O(1:(end-1));
    
    % predict Xi
    Xi_r_H(n) = X(end,:)*a_H;
    Xi_r_L(n) = X(end,:)*a_L;
    Xi_r_C(n) = X(end,:)*a_C;
    Xi_r_O(n) = X(end,:)*a_O;
    
    % compute fit parameters
    b_bar_H  = sum(b_H)             /length(b_H);
    SS_tot_H = sum((b_H-b_bar_H).^2)/length(b_H);
    SS_res_H = sum((X*a_H-b_H).^2)  /length(b_H);
    r_sqr_H  = 1-SS_res_H/SS_tot_H;

    b_bar_L  = sum(b_L)             /length(b_L);
    SS_tot_L = sum((b_L-b_bar_L).^2)/length(b_L);
    SS_res_L = sum((X*a_L-b_L).^2)  /length(b_L);
    r_sqr_L  = 1-SS_res_L/SS_tot_L;

    b_bar_C  = sum(b_C)             /length(b_C);
    SS_tot_C = sum((b_C-b_bar_C).^2)/length(b_C);
    SS_res_C = sum((X*a_C-b_C).^2)  /length(b_C);
    r_sqr_C  = 1-SS_res_C/SS_tot_C;

    b_bar_O  = sum(b_O)             /length(b_O);
    SS_tot_O = sum((b_O-b_bar_O).^2)/length(b_O);
    SS_res_O = sum((X*a_O-b_O).^2)  /length(b_O);
    r_sqr_O  = 1-SS_res_O/SS_tot_O;

    % take minimum r^2
    r_sqr = [r_sqr,min([r_sqr_H,r_sqr_L,r_sqr_C,r_sqr_O])];
    
  end
  
end

%% get stock price predictions
% add up both predictions
% need to check that High > Low,Open,Close and Low < High,Open,Close
H_r = High (k,:);
L_r = Low  (k,:);
O_r = Open (k,:);
C_r = Close(k,:);
for n = (Nlr+1):N
  H_r(n) = Mu_r_H(n)+Xi_r_H(n);
  L_r(n) = Mu_r_L(n)+Xi_r_L(n);
  O_r(n) = Mu_r_O(n)+Xi_r_O(n);
  C_r(n) = Mu_r_C(n)+Xi_r_C(n);
end

%% plot
% todo, input figure number
% figure(1);
% CandlestickPlot(1:N,C_r(k,:),O_r(k,:),H_r(k,:),L_r(k,:),2,.5,0.5);
% CandlestickPlot(1:N,Close(k,:),Open(k,:),High(k,:),Low(k,:),1,.25,1.0);
InteractiveStockChart(symbols,dates,Close,Open,High,Low,Volume);


if predictXi
  % todo, r_sqr is very good, but not enough data is being represented
  figure(2);
  plot(r_sqr)
end