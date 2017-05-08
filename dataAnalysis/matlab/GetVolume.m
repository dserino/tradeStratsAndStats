function [vol1,vol10,vol50] = GetVolume(data,N,Ns)
% return matrices (N x Ns)
% 1 day
% 10 day avg
% 50 day avg
% -1 for not available
  vol1  = zeros(Ns,N);
  vol10 = zeros(Ns,N);
  vol50 = zeros(Ns,N);
  
  % populate vol1 matrix
  for s = 1:Ns
    vol1(s,:) = data{s}(:,5);
  end
  
  for n = 1:N
    if n >= 10
      vol10(:,n) = vol1(:,(n-9):n)*ones(10,1)/10;
    end
    if n >= 50
      vol50(:,n) = vol1(:,(n-49):n)*ones(50,1)/50;
    end
  end
end