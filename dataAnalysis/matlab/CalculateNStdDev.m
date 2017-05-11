function [Mu,Sigma,Kappa] = CalculateNStdDev(Close,Open,N,Ns,Na)
  
% get Na day avg and stdDev of Close
  Mu = zeros(Ns,N);
  Sigma = zeros(Ns,N);
  Kappa = zeros(Ns,N);
for n = 1:N
  if n >= Na
    Mu(:,n)    = Close(:,(n-Na+1):n)*ones(Na,1)/Na;
    Sigma(:,n) = sqrt( (Close(:,(n-Na+1):n)-Mu(:,(n-Na+1):n)).^2 ...
                       *ones(Na,1)/Na );
    if n < N
      Kappa(:,n) = (Close(:,n+1)-Mu(:,n))./Sigma(:,n);
    end
  end
end
  
end