function [DIp,DIm,DX,ADX] = GetDMI(High,Low,adjClose,N,Ns)
  TR1 = High(:,2:end)-Low(:,2:end);
  TR2 = abs(High(:,2:end)-adjClose(:,1:(end-1)));
  TR3 = abs(Low(:,2:end)-adjClose(:,1:(end-1)));
  
  TrueRange = zeros(Ns,N);
  DIp = zeros(Ns,N);
  DIm = zeros(Ns,N);
  ADX = zeros(Ns,N);

  TrueRange(:,2:end) = ...
       TR1.*(TR1>TR2).*(TR1>TR3) ...
      +TR2.*(TR2>=TR1).*(TR2>TR3) ...
      +TR3.*(TR3>=TR1).*(TR3>=TR2);
  
  DIp(:,2:end) = ...
      (High(:,2:end) - High(:,1:(end-1))).* ...
      (High(:,2:end) - High(:,1:(end-1)) > 0);
  DIm(:,2:end) = ...
      (Low(:,1:(end-1)) - Low(:,2:end)).* ...
      (Low(:,1:(end-1)) - Low(:,2:end) > 0);
  
  DIp = DIp./TrueRange;
  DIm = DIm./TrueRange;
  
  DX = (DIp-DIm)./((DIp+DIm)+(DIp==0).*(DIm==0));
  
  for n = 1:N
    if n >= 10
      ADX(:,n) = DX(:,(n-9):n)*ones(10,1)/10;
    end
  end
  
end