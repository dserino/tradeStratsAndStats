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
month1 = 4;
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
end

%% perform analysis
% we want to make a profit by buying at a close and selling at next open

% ideas:
%  - dynamic mode decomp on smoothed data. We may not have luck
%    with noisy data. If smoothed data is better to work with, we
%    need to go from smoothed data to noisy data afterwords (work
%    with probabilities).
%  - for a given stock look at all days with open(n+1)>close(n) and
%    see if there is common pattern (relation with technical indicators)
%