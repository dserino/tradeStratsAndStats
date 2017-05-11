function [pK,pD] = GetStochastics(High,Low,adjClose,N,Ns)
  
  pK = (adjClose-Low)./(High-Low)*100;
  pD = zeros(Ns,N);
  
  for n = 1:N
    if n >= 3
      pD(:,n) = pK(:,(n-2):n)*ones(3,1)/3;
    end
  end

end