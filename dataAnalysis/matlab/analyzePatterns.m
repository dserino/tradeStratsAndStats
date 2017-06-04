clear; close all;

% In this file, a stock symbol is inputted. This code searched a
% range of dates and finds the largest gains in a search region of time.

%% inputs
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

% Go through each day and find the largest percent gainers
% for a given time interval N1 <= n_days_held <= N2.
% Buy at close, sell at open
N1 = 10;
N2 = 10;

% record p_inc for each day, each n_days_held
p_inc = zeros(N-N2,N2-N1+1);
days_held = N1:N2;
for n = 1:(N-N2)
  for i = 1:length(days_held)
    n_days_held = days_held(i);
    p_inc(n,i) = (Open(k,n+n_days_held)-Close(k,n))/Close(k,n);
  end
end

%% plot
% todo, input figure number
CandlestickPlot(1:N,Close(k,:),Open(k,:),High(k,:),Low(k,:),1,.25,1.0);

figure(1);
hold on;

% mark all times when p_inc > min_p_inc
min_p_inc = .1;
for i = 1:length(days_held)
  [~,I] = sort(p_inc(:,i),'descend');
  
  j = 1;
  while p_inc(I(j),i) > min_p_inc
    plot([I(j),I(j)+days_held(i)], ...
         [Close(k,I(j)),Open(k,I(j)+days_held(i))],'-ok','MarkerSize',10)
    j = j+1;
  end
end


