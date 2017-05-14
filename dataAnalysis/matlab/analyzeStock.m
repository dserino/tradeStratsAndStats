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
% iTry = 1; % plot multiple things 
iTry = 2; % seus using n-day moving average
% iTry = 3; % seus using linear regression

% make sure that dates agree for each symbol
CheckDates(data,symbols);

% get prices into high, low, close, and open data
[High,Low,Close,Open] = GetPrices(data,N,Ns);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iTry == 1
  % plot multiple things 
  
  %% plot stock prices
  fprintf('> figure 1 shows closing price as a function of time \n')
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
  fprintf('> figure 2 shows percent increase as a function of time \n')
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
  
  fprintf('> figure 3 shows the weighted average \n')
  figure(3);
  hold on;
  for k = 1:Ns
    plot(Mu(k,:));
  end
  
  xlabel('day')
  ylabel('mean')
  legend(leg)
  grid on
  title('10 day trailing price mean')
  
  % win loss ratio is calculated assuming you hold the stock for entire period 
  WinLossRatio = CalculateWinLossRatio(p_increase,Ns);

  %% get mean and standard deviation for p_increase
  for k = 1:Ns
    Mu_p_i(k) = sum(p_increase{k})/(N-1);
    Sigma_p_i(k) = sqrt(sum((p_increase{k}-Mu_p_i(k)).^2)/(N-1));
  end
  
  %% print
  fprintf(['> calculating win/loss ratio, mean percent increase, and ' ...
           'std deviation\n']);
  fprintf('%7s %6s %7s %7s \n','symbol','w/l','mu','sigma')
  for k = 1:Ns
    fprintf('%7s %6.2f %6.2f%% %6.2f%% \n',symbols{k},WinLossRatio(k),Mu_p_i(k),Sigma_p_i(k));
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif iTry == 2
  %% smooth, extrapolate, un-smooth
  % use Nlr-day moving average
  
  % pick stock index 1
  k = 1;
  
  %% smooth step
  Nlr = 50;
  fprintf('> smoothing data using %d day moving average \n',Nlr);

  % plot closing price
  fprintf('> figure 1 shows closing price as a function of time \n');
  figure(1);
  hold on;
  plot(Close(k,Nlr:N))
  
  % calculate moving average
  Mu = Close(k,:);
  I = 1:Nlr;
  for n = (Nlr):N
    Mu(n) = sum(Close(k,I+n-Nlr))/Nlr;
  end

  plot(Mu(Nlr:N),'m')
  grid on
  title('Close price and mean')

  %% extrapolate
  % reconstructed mu
  Mu_r = Mu;

  % number of samples
  Nt = 15;
  
  % stencil size
  n_level = 3;

  fprintf('> number of samples = %d\n',Nt);
  fprintf('> stencil size      = %d\n',n_level);
  
  err_sv = [];
  
  % reconstruct mu
  for n = (Nlr+Nt+1):N

    % compute data matrix
    % start from
    % Nlr+i to n-1
    X = zeros((Nt+1)+(1-n_level),n_level);
    i = n-Nt-1;
    for j = 1:n_level
      X(:,j) = Mu((n_level-j+i):((Nt+1)-j+i));
    end

    % compute SVD
    [U,Sigma,V] = svd(X,'econ');


    err_sv = [err_sv,Sigma(end,end)];
              
    % extract the approximate null space of data matrix
    a = V(:,end);

    % compute predicted mu
    Mu_r(n) = 0;
    for j = 2:n_level
      Mu_r(n) = Mu_r(n)-Mu(n-j+1)*a(j)/a(1);
    end
    
    % uncomment here to compare with pure extrapolation
    % Mu_r(n) = 4*Mu(n-1)-6*Mu(n-2)+4*Mu(n-3)-Mu(n-4);
  end
  
  % plot mu
  fprintf('> figure 2 plots mean and predicted mean\n');
  figure(2);
  hold on;
  plot(Mu  ((Nlr+Nt+1):N))
  plot(Mu_r((Nlr+Nt+1):N),'*m')
  grid on
  title('mean and reconstructed mean')
  
  % plot err
  fprintf('> figure 3 plots errors \n')
  figure(3);
  hold on;
  plot((Nlr+Nt+1):N,Mu((Nlr+Nt+1):N)-Mu_r((Nlr+Nt+1):N))
  plot((Nlr+Nt+1):N,err_sv,'r')
  grid on
  title('error of mean and reconstruction and lowest singular value')

  %% unsmooth step
  % reconstructed Mu
  Close_r = Close(k,:);
  I = 1:(Nlr-1);
  for n = Nlr:N
    Close_r(n) = Nlr*Mu_r(n)-sum(Close(k,I+n-Nlr ));
  end

  % plot close and predicted close
  fprintf('> figure 4 plots close and predicted close \n');
  figure(4);
  hold on;
  plot(Close(k,Nlr:N))
  plot(Close_r(Nlr:N),'m')
  title('Close price and predicted close price')
  grid on
  
  %% test performance
  percent_inc_r = (Close_r((Nlr+1):N)-Close(Nlr:(N-1)))./Close(Nlr:(N-1));
  percent_inc   = (Close((Nlr+1):N)  -Close(Nlr:(N-1)))./Close(Nlr:(N-1));
  
  n_ww = sum((percent_inc_r>0).*(percent_inc>0));
  n_ll = sum((percent_inc_r<0).*(percent_inc<0));
  n_wl = sum((percent_inc_r>0).*(percent_inc<0));
  n_lw = sum((percent_inc_r<0).*(percent_inc>0));
  
  n_w = sum(percent_inc>0);
  n_l = sum(percent_inc<0);
  
  err_ww = sum((abs(percent_inc-percent_inc_r)) ...
               .*(percent_inc_r>0).*(percent_inc>0)) / ...
           n_ww;
  err_ll = sum((abs(percent_inc-percent_inc_r)) ...
               .*(percent_inc_r<0).*(percent_inc<0)) / ...
           n_ll;
  err_wl = sum((abs(percent_inc-percent_inc_r)) ...
               .*(percent_inc_r>0).*(percent_inc<0)) / ...
           n_wl;
  err_lw = sum((abs(percent_inc-percent_inc_r)) ...
               .*(percent_inc_r<0).*(percent_inc>0)) / ...
           n_lw;

  n_tot = n_ww+n_ll+n_wl+n_lw;
  
  fprintf(['> assume investor buys when algorithm predicts a price ' ...
           'increase and sells the next day\n']);
  
  fprintf('correct w:  predicted increase but price increased (buy)\n');
  fprintf(['wrong w  :  predicted decrease but price increased ' ...
           '(don''t buy)\n']);
  fprintf(['correct l:  predicted decrease but price decreased ' ...
           '(dont'' buy)\n']);
  fprintf('wrong l  :  predicted increase but price decreased (buy)\n')
  
  fprintf('        %10s %10s %10s %10s \n', ...
          'correct w','wrong w','correct l','wrong l');
  fprintf('ratio:  %10.2f %10.2f %10.2f %10.2f \n',n_ww/n_w,n_lw/n_w,n_ll/n_l,n_wl/n_l);
  fprintf('total:  %10d %10d %10d %10d \n',n_ww,n_lw,n_ll,n_wl);
  
  wol = -sum(percent_inc.*(percent_inc_r>0).*(percent_inc>0))/ ...
        sum(percent_inc.*(percent_inc_r>0).*(percent_inc<0));
  fprintf('win/loss ratio: %6.2f\n',wol);
  
  % todo, add more metrics
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif iTry == 3
  % todo, trying to recreate iTry = 2 using least squares as a
  % smoother instead 
  
  %% smooth, extrapolate, unsmooth
  % use least squares
  
  % pick stock index 1
  k = 1;
  
  %% smooth step
  Nlr = 50;
  
  figure(1);
  hold on;
  plot(Nlr:N,Close(k,Nlr:N))
  
  slope = zeros(N,1);
  const = zeros(N,1);
  
  Mu = Close(k,:);
  I = 1:Nlr;
  for n = (Nlr):N
    A = [((n-Nlr+1):n)',ones(Nlr,1)];
    b = Close(k,(n-Nlr+1):n)';
    x_ = A\b;

    x = ((n-Nlr+1):n)';
    slope(n) = x_(1);
    const(n) = x_(2);
    y = x_(1)*x+x_(2);
    plot(x,y,'m')
  end

  grid on
  title('Close price and linear least squares')

  figure(2)
  hold on
  plot(Nlr:N,slope(Nlr:N))
  title('LS slope')
  
  figure(3);
  hold on
  plot(Nlr:N,const(Nlr:N))
  title('LS constant')
  
  %% extrapolate
  slope_r = slope;
  const_r = const;

  
  % number of samples
  Nt = 60;
  % stencil size
  n_level = 3;

  err_sv = [];
  
  
  % reconstruct mu
  for n = (Nlr+Nt+1):N

    % compute data matrix
    % start from
    % Nlr+i to n-1
    X = zeros((Nt+1)+(1-n_level),n_level);
    Y = zeros((Nt+1)+(1-n_level),n_level);
    i = n-Nt-1;
    for j = 1:n_level
      X(:,j) = slope((n_level-j+i):((Nt+1)-j+i));
      Y(:,j) = const((n_level-j+i):((Nt+1)-j+i));
    end

    % compute SVD
    [U ,Sigma ,V] = svd(X,'econ');
    [U_,Sigma_,V_] = svd(Y,'econ');
    esv = [Sigma(end,end);Sigma_(end,end)];
    err_sv = [err_sv,esv];
              
    % extract the approximate null space of data matrix
    a = V(:,end);
    b = V_(:,end);
    
    slope_r(n) = 0;
    const_r(n) = 0;
    for j = 2:n_level
      slope_r(n) = slope_r(n)-slope(n-j+1)*a(j)/a(1);
      const_r(n) = const_r(n)-const(n-j+1)*b(j)/b(1);
    end
    
  end
  
  figure(4);
  hold on;
  plot(slope  ((Nlr+Nt+1):N))
  plot(slope_r((Nlr+Nt+1):N),'*m')
  grid on
  title('slope reconstruction')
  
  figure(5);
  hold on;
  plot(const  ((Nlr+Nt+1):N))
  plot(const_r((Nlr+Nt+1):N),'*m')
  grid on
  title('const reconstruction')
  
  figure(6);
  hold on;
  plot((Nlr+Nt+1):N,slope((Nlr+Nt+1):N)-slope_r((Nlr+Nt+1):N))
  plot((Nlr+Nt+1):N,err_sv(1,:),'r')
  grid on
  title('slope reconstruction error')
  
  figure(7);
  hold on;
  plot((Nlr+Nt+1):N,const((Nlr+Nt+1):N)-const_r((Nlr+Nt+1):N))
  plot((Nlr+Nt+1):N,err_sv(2,:),'r')
  grid on
  title('const reconstruction error')
  return

  %% unsmooth step
  % reconstructed Mu

  Close_r = Close(k,:);
  I = 1:(Nlr-1);
  for n = Nlr:N
    Close_r(n) = Nlr*Mu_r(n)-sum(Close(k,I+n-Nlr ));
  end
  
  figure(4);
  hold on;
  plot(Close(k,Nlr:N))
  plot(Close_r(Nlr:N),'m')
  title('Close price and predicted close price')
  grid on
  
  %% test performance
  
else
  error('invalid input for iTry')
end

end















