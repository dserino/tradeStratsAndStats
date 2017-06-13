function [High,Low,Close,Open] = GetPrices(data,N,Ns)
  High     = zeros(Ns,N);
  Low      = zeros(Ns,N);
  adjClose = zeros(Ns,N);
  Open     = zeros(Ns,N);
  
  for s = 1:Ns
    High(s,:)     = data{s}(:,2);
    Low(s,:)      = data{s}(:,3);
    Close(s,:)    = data{s}(:,6);
    Open(s,:)     = data{s}(:,1);
  end
  % High(end,1:4)
  % Low(end,1:4)
  % adjClose(end,1:4)
  % pause
end