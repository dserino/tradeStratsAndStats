function analyzeStock()
close all;
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
  load([dir,SaveFile]);
end

n_open      = 1;
n_high      = 2;
n_low       = 3;
n_close     = 4;
n_volume    = 6;
n_adj_close = 7;

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

% iTry will determine what analysis we want to run.
% this will keep things organized and reduce the need to copy above
% code for each file
% iTry = 1; plot multiple things 
iTry = 2; % linear regression

% make sure that dates agree for each symbol
CheckDates(data,symbols);

% get prices into high, low, close, and open data
[High,Low,Close,Open] = GetPrices(data,N,Ns);

%%
if iTry == 1
  % plot multiple things 
  
  %% plot stock prices
  figure(1);
  hold on
  for k = 1:Ns
    plot(data{k}(:,n_close));
    leg{k} = symbols{k};
  end
  
  xlabel('day')
  ylabel('price')
  legend(leg)
  grid on
  title('closing price')
  
  %% plot percent increase close->open
  figure(2);
  hold on
  for k = 1:Ns
      p_increase{k} = (data{k}(2:end,n_open)-data{k}(1:(end-1),n_close)) ...
          ./data{k}(1:(end-1),n_close)*100.;
      plot(2:N,p_increase{k})
  end
  
  xlabel('day')
  ylabel('percent increase (%)')
  legend(leg)
  grid on
  title('percent increase')

  %% mu sigma kappa
  [Mu,Sigma,Kappa] = CalculateNStdDev(Close,Open,N,Ns,10);
  
  figure(3);
  hold on;
  for k = 1:Ns
    plot(Mu(k,:));
  end
  
  xlabel('day')
  ylabel('kappa (%)')
  legend(leg)
  grid on
  title('10 day trailing price mean')
  
  %% 
  WinLossRatio = CalculateWinLossRatio(p_increase,Ns);

  %% get mean and standard deviation for p_increase
  for k = 1:Ns
    Mu_p_i(k) = sum(p_increase{k})/(N-1);
    Sigma_p_i(k) = sqrt(sum((p_increase{k}-Mu_p_i(k)).^2)/(N-1));
  end
  

  
  %% print
  fprintf('%7s %6s %7s %7s \n','symbol','w/l','mu','sigma')
  for k = 1:Ns
    fprintf('%7s %6.2f %6.2f%% %6.2f%% \n',symbols{k},WinLossRatio(k),Mu_p_i(k),Sigma_p_i(k));
  end
elseif iTry == 2
  k = 1;
  
  Nlr = 100;
  
  figure(1);
  hold on;
  plot(Close(k,:))
  
  slope = zeros(N,1);
  
  for n = (Nlr):N
    A = [((n-Nlr+1):n)',ones(Nlr,1)];
    b = Close(k,(n-Nlr+1):n)';
    x_ = A\b;
    
    slope(n) = x_(1);
    
    x = ((n-Nlr+1):n)';
    y = x_(1)*x+x_(2);
    plot(x,y,'m')
  end
  grid on
  title(sprintf('plot of close price and linear regressions, N=%d',Nlr))
  
  figure(2)
  plot(Nlr:N,slope(Nlr:N));
  grid on
  title('plot of the slope of regression at point')
  
  figure(3)
  N_ = (Nlr+2):N;
  plot(N_,(1.5*slope(N_)-2*slope(N_-1)+0.5*slope(N_-2)))
  grid on
  title('plot of BDF FD of slope')
  
  % Close_r = Close;
  % for n = (Nlr+1):N
  %   % Close_r(k,n) = Close(k,n-1)+slope(n-1);
  %   Close_r(k,n) = Close(k,n-1)+0.5*(3*slope(n-1)-slope(n-2));
  % end
  
  % figure(3);
  % hold on;
  % plot(Close(k,:))
  % plot((Nlr+1):N,Close_r(k,(Nlr+1):N))
  
  
else
  error('invalid input for iTry')
end

end















