function WinLossRatio = CalculateWinLossRatio(p_increase,Ns)
  WinLossRatio = zeros(Ns,1);
  for k = 1:Ns
    WinLossRatio(k) = -sum((p_increase{k}>0).*p_increase{k})/ ...
        sum((p_increase{k}<0).*p_increase{k});
  end
end