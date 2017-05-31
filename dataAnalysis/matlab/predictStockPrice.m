clear; close all;

%% inputs
Nlr = 20; % smooth data using this many days
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
Mu_r_H = Mu_H;
Mu_r_L = Mu_L;
Mu_r_C = Mu_C;
Mu_r_O = Mu_O;

%% predict Xi
Xi_r_H = Xi_H;
Xi_r_L = Xi_L;
Xi_r_C = Xi_C;
Xi_r_O = Xi_O;

%% get stock price predictions
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

figure(1);
hold on;

lw = 2;

n_green = [];
n_red   = [];
v_green = [];
v_red   = [];

for n = 1:N
  if Close(k,n) >= Open(k,n)
    n_green = [n_green,n];
    v0 = [Open(k,n);Close(k,n)];
    v_green = [v_green,v0];
    w0 = [Low(k,n);High(k,n)];
    plot([n,n],w0,'g','LineWidth',lw)
  else
    n_red   = [n_red  ,n];
    v0 = [Close(k,n);Open(k,n)];
    v_red   = [v_red  ,v0];
    w0 = [Low(k,n);High(k,n)];
    plot([n,n],w0,'r','LineWidth',lw)
  end
end

w = .25;

g_x = [n_green-w;
        n_green+w;
        n_green+w;
        n_green-w;
        n_green-w];
g_y = [v_green(1,:);
        v_green(1,:);
        v_green(2,:);
        v_green(2,:);
        v_green(1,:)];

r_x = [n_red-w;
        n_red+w;
        n_red+w;
        n_red-w;
        n_red-w];
r_y = [v_red(1,:);
        v_red(1,:);
        v_red(2,:);
        v_red(2,:);
        v_red(1,:)];

patch(g_x,g_y,'g')
patch(r_x,r_y,'r')

grid on