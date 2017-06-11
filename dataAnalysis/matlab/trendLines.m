clear; close all;

% This code takes a time interval for a stock and plots trendlines
% that undercut and overcut the price (no touching) while
% minimizing the error of approximation. fmincon is used to solve
% this linear minimization problem

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

% range of days
n1 = 50;
n2 = 100;
I = n1:n2;

% inputs for fmincon
options = optimset('fmincon');
options.Display = 'off';

% fmincon inputs
b_low  = Low(k,I);
b_high = High(k,I);
f_low  = @(x) sum( abs(x(1)*I + x(2) - b_low ) );
f_high = @(x) sum( abs(x(1)*I + x(2) - b_high) );
A = [I',I'*0+1];

% generate initial guess
% start with line connecting b(1) and b(2)
a_ = (b_low(2)-b_low(1))/(n2-n1);
b_ = b_low(1)+a_*n1;
x0 = [a_;b_];

[x_low,fval,exitflag,output] = fmincon(f_high,x0,A,b_low,[],[],[],[],[],options);

% start with line connecting b(1) and b(2)
a_ = (b_high(2)-b_high(1))/(n2-n1);
b_ = b_high(1)+a_*n1;
x0 = [a_;b_];

[x_high,fval,exitflag,output] = fmincon(f_high,x0,-A,-b_high,[],[],[],[],[],options);

figure(1);

hold on;
CandlestickPlot(I,Close(k,:),Open(k,:),High(k,:),Low(k,:));
plot(I,x_low(1)*I+x_low(2),'m--')
plot(I,x_high(1)*I+x_high(2),'m--')

xlabel('days')
ylabel('price')
title(symbols{k})