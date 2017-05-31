function analyzeMFs()
close all;
% need to change this
dir = '~/tradeStratsAndStats/dataAnalysis/matlab/';

%% filename and save data for symbols
% filename = 'symbolFiles/MFFixedIncome.txt';
% SaveFile = 'saveFiles/MFFixedIncome.mat';

filename = 'symbolFiles/MFInternational.txt';
SaveFile = 'saveFiles/MFInternational.mat';

% filename = 'symbolFiles/MFLargeBlend.txt';
% SaveFile = 'saveFiles/MFLargeBlend.mat';

% filename = 'symbolFiles/MFLargeGrowth.txt';
% SaveFile = 'saveFiles/MFLargeGrowth.mat';

% filename = 'symbolFiles/MFLargeValue.txt';
% SaveFile = 'saveFiles/MFLargeValue.mat';

% filename = 'symbolFiles/MFMidBlend.txt';
% SaveFile = 'saveFiles/MFMidBlend.mat';

% filename = 'symbolFiles/MFMidGrowth.txt';
% SaveFile = 'saveFiles/MFMidGrowth.mat';

% filename = 'symbolFiles/MFMidValue.txt';
% SaveFile = 'saveFiles/MFMidValue.mat';

% filename = 'symbolFiles/MFSmallBlend.txt';
% SaveFile = 'saveFiles/MFSmallBlend.mat';

% filename = 'symbolFiles/MFSmallGrowth.txt';
% SaveFile = 'saveFiles/MFSmallGrowth.mat';

% filename = 'symbolFiles/MFSmallValue.txt';
% SaveFile = 'saveFiles/MFSmallValue.mat';

%% inputs
doLoad = true;

% start date
year0 = 2012;
month0 = 1;
day0 = 1;

% end date
year1 = 2017;
month1 = 5;
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
n_volume    = 5;
n_adj_close = 6;


%% calculate win/loss ratio for each stock
wol1 = zeros(Ns,1);
wol10 = zeros(Ns,1);
wol50 = zeros(Ns,1);
wol200 = zeros(Ns,1);
%% calculate annulized (200 day) mean p_increase for each stock
ar1 = zeros(Ns,1);
ar10 = zeros(Ns,1);
ar50 = zeros(Ns,1);
ar200 = zeros(Ns,1);
%% calculate std dev of ar for each stock
std1 = zeros(Ns,1);
std10 = zeros(Ns,1);
std50 = zeros(Ns,1);
std200 = zeros(Ns,1);
for k = 1:Ns
  Price = data{k}(:,n_adj_close);
  
  try
    
  % w/l 1
  p_increase = (Price(2:end)-Price(1:(end-1)))./Price(1:(end-1));
  wol1(k) = -sum((p_increase>0).*p_increase)/ ...
      sum((p_increase<0).*p_increase);
  ar1(k) = sum(p_increase)/length(p_increase)*200;
  std1(k) = sqrt( sum((200*p_increase-ar1(k)).^2 / length(p_increase)) );
  
  % w/l 10
  N = 10;
  p_increase = (Price((1+N):end)-Price(1:(end-N)))./Price(1:(end-N));
  wol10(k) = -sum((p_increase>0).*p_increase)/ ...
      sum((p_increase<0).*p_increase);
  ar10(k) = sum(p_increase)/length(p_increase)*20;
  std10(k) = sqrt( sum((20*p_increase-ar10(k)).^2 / length(p_increase)) );

  % w/l 50
  N = 50;
  p_increase = (Price((1+N):end)-Price(1:(end-N)))./Price(1:(end-N));
  wol50(k) = -sum((p_increase>0).*p_increase)/ ...
      sum((p_increase<0).*p_increase);
  ar50(k) = sum(p_increase)/length(p_increase)*4;
  std50(k) = sqrt( sum((4*p_increase-ar50(k)).^2 / length(p_increase)) );

  % w/l 200
  N = 200;
  p_increase = (Price((1+N):end)-Price(1:(end-N)))./Price(1:(end-N));
  wol200(k) = -sum((p_increase>0).*p_increase)/ ...
      sum((p_increase<0).*p_increase);
  ar200(k) = sum(p_increase)/length(p_increase);
  std200(k) = sqrt( sum((p_increase-ar200(k)).^2 / length(p_increase)) );
  
  catch
  end
  
end

% [~,I] = sort(wol200);
% [~,I] = sort(ar200);
[~,I] = sort(std1);
fprintf('%8s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s\n', ...
        'symbol','wol1','wol10','wol20','wol200', ...
        'ar1','ar10','ar20','ar200', ...
        'std1','std10','std20','std200');
for k_ = 1:Ns
  k = I(k_);
  fprintf('%8s %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n', ...
          symbols{k}, ...
          wol1(k),wol10(k),wol50(k),wol200(k), ...
          ar1(k),ar10(k),ar50(k),ar200(k), ...
          std1(k),std10(k),std50(k),std200(k));
          
end


% figure(1)
% plot3(1./std1,ar200,1:Ns,'*')

end