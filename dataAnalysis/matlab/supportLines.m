clear; close all;

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

%% figure out trailing max/min
Nlr = 10; % 10 day trailing max and min

TMax = High(k,:);
TMin = Low(k,:);
Mu = Close(k,:);
I = 1:Nlr;
for n = (Nlr):N
  TMax(n) = max(High(k,I+n-Nlr));
  TMin(n) = min(Low(k,I+n-Nlr));
  Mu(n)    = sum(Open(k,I+n-Nlr) + Close(k,I+n-Nlr))/(2*Nlr);
end


%% plot
figure(1);
hold on
CandlestickPlot(1:N,Close(k,:),Open(k,:),High(k,:),Low(k,:));
plot(Nlr:N,TMax(Nlr:N),'--m')
plot(Nlr:N,TMin(Nlr:N),'--m')
plot(Nlr:N,Mu(Nlr:N),'--m')

% buy when moving max increases, sell when moving max decreases
% cap loss at certain percent
pLoss = -.005;
pMinChangeBuffer = 0;
pWin = .005;
win = 0;
loss = 0;
nWin = 0;
nLoss = 0;

havePositions = false;
costBasis = 0;
buyTime = 0;
for n = (Nlr+1):N

  if havePositions
    % should I sell
    pGain = (Close(k,n)-costBasis)/Close(k,n);
    pMinChange = (TMin(n)-TMin(n-1))/TMin(n-1);
    pMaxChange = (TMax(n)-TMax(n-1))/TMax(n-1);
    if (pMinChange < pMinChangeBuffer) || (pGain < pLoss) || ...
          (pGain > pWin)
      % sell
      havePositions = false;
      if pGain > 0
        win = win+pGain;
        nWin = nWin+1;
      else
        loss = loss+pGain;
        nLoss = nLoss+1;
      end
      plot([buyTime,n]+0.5,[costBasis,Close(k,n)],'k-o','LineWidth',2)
    end
  else
    % should I buy
    if (TMax(n) > TMax(n-1))
      % buy
      havePositions = true;
      costBasis = Close(k,n);
      buyTime = n;
    end
  end
end

wol = -win/loss;
fprintf('wol:   %6.2f\n',wol);
fprintf('nWin:  %6.2f\n',nWin);
fprintf('nLoss: %6.2f\n',nLoss);