function CandlestickPlot(I,Close,Open,High,Low, ...
                         lw,w,alpha)
  % create a candlestick plot. A bar from open to close is
  % created and is red if Close < Open and green if Open < Close.
  % A line from high to low is drawn.
  %
  % I:     days data is available for (integers)
  % lw:    line width for high to low
  % w;     width of rectangle
  % alpha: transparency
  
  % figure(1);
  hold on;

  if ~exist('alpha','var')
    alpha = 1;
  end

  n_green = [];
  n_red   = [];
  v_green = [];
  v_red   = [];

  w_green = [];
  w_red = [];
  
  for n = I
    if Close(n) >= Open(n)
      n_green = [n_green,n];
      v0 = [Open(n);Close(n)];
      v_green = [v_green,v0];
      w0 = [Low(n);High(n)];
      w_green = [w_green,w0];
      % plot([n,n],w0,'g','LineWidth',lw)
    else
      n_red   = [n_red  ,n];
      v0 = [Close(n);Open(n)];
      v_red   = [v_red  ,v0];
      w0 = [Low(n);High(n)];
      w_red = [w_red,w0];
      % plot([n,n],w0,'r','LineWidth',lw)
    end
  end

  g_x = [n_green+.5-w;
         n_green+.5+w;
         n_green+.5+w;
         n_green+.5-w;
         n_green+.5-w];
  g_y = [v_green(1,:);
         v_green(1,:);
         v_green(2,:);
         v_green(2,:);
         v_green(1,:)];

  r_x = [n_red+.5-w;
         n_red+.5+w;
         n_red+.5+w;
         n_red+.5-w;
         n_red+.5-w];
  r_y = [v_red(1,:);
         v_red(1,:);
         v_red(2,:);
         v_red(2,:);
         v_red(1,:)];

  plot([n_green;n_green]+.5,w_green,'g','LineWidth',lw);
  plot([n_red  ;n_red  ]+.5,w_red  ,'r','LineWidth',lw);
  
  patch(g_x,g_y,'g','FaceAlpha',alpha)
  patch(r_x,r_y,'r','FaceAlpha',alpha)

  grid on

end