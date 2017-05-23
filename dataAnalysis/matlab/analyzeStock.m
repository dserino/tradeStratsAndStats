function analyzeStock()
close all;
% need to change this
dir = '~/tradeStratsAndStats/dataAnalysis/matlab/';

% iTry will determine what analysis we want to run.
% this will keep things organized and reduce the need to copy above
% code for each file
% iTry = 1; % plot multiple things 
% iTry = 2; % seus using n-day moving average
% iTry = 3; % seus using linear regression
% iTry = 4; % regression on whole data
iTry = 5; % regression and simulation

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

%% perform analysis
% make sure that dates agree for each symbol
CheckDates(data,symbols);

% get prices into high, low, close, and open data
[High,Low,Close,Open] = GetPrices(data,N,Ns);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  percent_inc_r = (Close_r((Nlr+1):N)-Close(k,Nlr:(N-1)))./Close(k,Nlr:(N-1))
  percent_inc   = (Close(k,(Nlr+1):N)  -Close(k,Nlr:(N-1)))./Close(k,Nlr:(N-1));
  % todo, play around with high here
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
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif iTry == 4
  %% use regression to determine p_inc
  % We guess that p_inc is correlated with the time history of
  % technical indicators. Look at data and come up with a least
  % squares fit for p_inc
  
  % pick stock index 1
  k = 1;

  %% smooth step
  % average this many points to determine moving average and std dev
  Nlr = 50;

  % number of samples for linear regression
  Nt = N-Nlr-1; % use all data available
  % Nt = 200;
  
  % number of days to use in regression for tech indicators
  n_level = 4;
  
  fprintf('> smoothing data using %d day moving average \n',Nlr);

  % plot closing price
  figure(1);
  hold on;
  plot(Close(k,Nlr:N))
  
  % calculate moving average
  Mu = Close(k,:);
  Sigma = Close(k,:);
  Kappa = Close(k,:);
  p_increase = [0,(Open(k,2:end)-Close(k,1:(end-1)))./(Close(k,1:(end-1)))];
  
  I = 1:Nlr;
  for n = (Nlr):N
    Mu(n)    = sum(Open(k,I+n-Nlr))/Nlr;
    Sigma(n) = sqrt(sum((Open(k,I+n-Nlr)-Mu(n)).^2)/(Nlr));
    Kappa(n) = (Close(k,n)-Mu(n))/Sigma(n);
  end

  % plot moving average
  plot(Mu(Nlr:N),'m')
  grid on
  xlabel('Time (days)')
  title(sprintf('stock closing price and %d day moving average',Nlr))
  grid on
  
  % plot number of std deviations ahead of mean
  figure(2)
  plot(Kappa(Nlr:N))
  xlabel('Time (days)')
  title('Number of standard deviations ahead of mean')
  ylabel('\kappa')
  grid on
  
  %% regression
  % compute data matrix
  n = Nlr+Nt+1;
  X = zeros((Nt+1)+(1-n_level),n_level);
  i = n-Nt-1;
  for j = 1:n_level
    X(:,j) = Kappa((n_level-j+i):((Nt+1)-j+i));
    % X(:,j) = (Kappa((n_level-j+i):((Nt+1)-j+i)) ...
    %          -Kappa((n_level-j+i-1):((Nt+1)-j+i-1)))./ ...
    %          Kappa((n_level-j+i-1):((Nt+1)-j+i-1));
  end
  X = [X.^3,X.^2,X,ones(Nt+2-n_level,1)];
  b = p_increase((n_level+i):((Nt+1)+i))';

  a = X\b;
  
  figure(3)
  hold on
  plot(X*a,b,'*')
  ylabel('predicted p_{inc}')
  xlabel('p_{inc}')
  title(sprintf('Nlr = %d, Nt = %d, n_{level} = %d',Nlr,Nt,n_level));
  grid on
  
  %% estimate r^2
  b_bar = sum(b)/length(b);
  SS_tot = sum((b-b_bar).^2)/length(b);
  SS_res = sum((X*a-b).^2)/length(b);
  r_sqr = 1-SS_res/SS_tot;
  fprintf('r_sqr = %6.4f\n',r_sqr);
  fprintf('n/N   = %6.4f\n',n_level/Nt);

  b0 = min(X*a);
  b1 = max(X*a);

  % plot fit and one std deviation away from fit
  plot([b0,b1],[b0,b1],'m')
  plot([b0,b1],[b0,b1]+sqrt(SS_tot),'--m');
  plot([b0,b1],[b0,b1]-sqrt(SS_tot),'--m');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif iTry == 5
  % use least squares in a moving simulation to determine predicted p_inc
  
  % pick stock index 1
  k = 1;

  %% smooth step
  % average
  Nlr = 50;
  % number of samples
  Nt = 200;
  % stencil size
  n_level = 4;
  
  % buy security if predicted p_inc is higher than p_buy
  p_buy = .005;
  % don't buy if predicted is higher than p_end
  p_end = 1;
  
  fprintf('> smoothing data using %d day moving average \n',Nlr);

  % plot closing price
  figure(1);
  hold on;
  plot(Close(k,Nlr:N))
  
  % calculate moving average
  Mu = Close(k,:);
  Sigma = Close(k,:);
  Kappa = Close(k,:);
  p_increase = [0,(Open(k,2:end)-Close(k,1:(end-1)))./(Close(k,1:(end-1)))];
  
  I = 1:Nlr;
  for n = (Nlr):N
    Mu(n)    = sum(Open(k,I+n-Nlr))/Nlr;
    Sigma(n) = sqrt(sum((Open(k,I+n-Nlr)-Mu(n)).^2)/(Nlr));
    Kappa(n) = (Close(k,n)-Mu(n))/Sigma(n);
  end

  plot(Mu(Nlr:N),'m')
  grid on
  title('Close price and mean')
  xlabel('Time (days)')
  title(sprintf('stock closing price and %d day moving average',Nlr))

  figure(2)
  plot(Kappa(Nlr:N))
  xlabel('Time (days)')
  title('Number of standard deviations ahead of mean')
  ylabel('\kappa')
  grid on

  %% run simple simulation to calculate strategy performance
  % 
  win = 0;
  loss = 0;
  
  % number of opportunities 
  n_opps = 0;
  % number of trading days
  n_trade = (N-Nlr-Nt);
  % number of possible wins
  n_win = sum(p_increase((Nlr+Nt+1):(N))>0);
  
  for n = (Nlr+Nt+1):N

    % compute data matrix
    % start from
    % Nlr+i to n-1
    X = zeros((Nt+1)+(1-n_level),n_level);
    i = n-Nt-1;
    for j = 1:n_level
      X(:,j) = Kappa((n_level-j+i):((Nt+1)-j+i));
      % X(:,j) = p_increase((n_level-j+i):((Nt+1)-j+i));
      % X(:,j) = (Kappa((n_level-j+i):((Nt+1)-j+i)) ...
      %           -Kappa((n_level-j+i-1):((Nt+1)-j+i-1)))./ ...
      %          Kappa((n_level-j+i-1):((Nt+1)-j+i-1));
    end
    X = [X.^3,X.^2,X,ones(Nt+2-n_level,1)];
    b = p_increase((n_level+i):((Nt+1)+i))';
  
    % solve for fit
    a = X(1:(end-1),:)\b(1:(end-1));
    
    % predict p_inc
    p_pred = X(end,:)*a;
    
    % compute fit parameters
    b_bar = sum(b)/length(b);
    SS_tot = sum((b-b_bar).^2)/length(b);
    SS_res = sum((X*a-b).^2)/length(b);
    r_sqr = 1-SS_res/SS_tot;
  
    % if r_sqr < 8
      
    %   b0 = min(X*a);
    %   b1 = max(X*a);

    %   % plot fit and one std deviation away from fit
    %   figure(3)
    %   hold on
    %   plot(X*a,b,'*')
    %   plot([b0,b1],[b0,b1],'m')
    %   plot([b0,b1],[b0,b1]+sqrt(SS_tot),'--m');
    %   plot([b0,b1],[b0,b1]-sqrt(SS_tot),'--m');

    %   pause
    % end
    
    % if conditions are right, buy security
    if p_pred > p_buy && p_pred < p_end 
      
      fprintf('p_pred: %6.2f%%, p_true: %6.2f%%, r_sqr: %6.2f\n', ...
              p_pred*100,p_increase(n)*100,r_sqr);
      if p_increase(n) > 0
        win = win + p_increase(n);
      else
        loss = loss + p_increase(n);
      end
      n_opps = n_opps+1;
    end
    
    
    % uncomment if sample size should change with day
    % Nt = Nt+1;
  end
  
  % calculate performance
  % wol assuming you buy and sell everyday (should be bad)
  wol_0 = -sum(p_increase.*(p_increase>0))/ ...
          sum(p_increase.*(p_increase<0));
  fprintf('blind wol = %6.2f \n',wol_0)

  % wol using regression above
  wol=-win/loss;
  fprintf('wol       = %6.2f \n',wol)

  % number of opportunities
  fprintf('n_opps  = %d \n',n_opps);
  fprintf('n_win   = %d \n',n_win);
  fprintf('n_trade = %d \n',n_trade);
  
  
else
  error('invalid input for iTry')
end

end















