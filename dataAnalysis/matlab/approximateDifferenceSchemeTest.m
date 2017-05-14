clear; close all;
% approximate difference scheme
% see notes.pdf. Works very well for smooth functions


%% test function that we sample
f = @(t) sin(t+cos(sqrt(t)).*.75).^5.*exp(cos(t)) ...
    +log(2*exp(-t.^2)+sin(t).^2+1) ...
    +0*sin(t).*(t<pi) ...
    +0*(t-pi).*(t>=pi) ...
    +0*(t<.5) ...
    +0*(t>=.5);

%% final sampling time and number of sampled points
tf0 = 1;
Nt = 30;

%% final reconstruction time
tf1 = 10;

%% stencil size
n_level = 10;

%% calculations
% time step
dt = tf0/Nt;

% time vector to end of sampling time
t = 0:dt:tf1;

% compute test function
F = f(t);

% compute data matrix
X = zeros((Nt+1)+(1-n_level),n_level);
I = 1:(Nt+1);
for j = 1:n_level
  X(:,j) = F((n_level+1-j):((Nt+1)+(1-j)));
end

% compute SVD
[U,Sigma,V] = svd(X,'econ');

% extract the approximate null space of data matrix
a = V(:,end);

% a = X(:,1:(n_level-1))\X(:,n_level);
% a = [a;-1]

%% predict future values 
% given: we know the true solution at before time level n and 
% vector a. we compute the approximation at the next time level.
F_reco = F;
for n = (Nt+2):length(t)
  
  F_reco(n) = 0;
  for j = 2:n_level
    F_reco(n) = F_reco(n)-F(n-j+1)*a(j)/a(1);
  end
end

%% get scheme residual
res = 0;
for j = 1:n_level
  res = res+a(j)*F((n_level+1-j):((end)+(1-j)));
end

% plot test function and reconstruction
figure(1);
hold on;
plot(t,F)
plot(t((Nt+2):(end)), F_reco((Nt+2):(end)),'*r')
xlabel('t')
grid on

% plot errors
figure(2)
hold on;
plot(t((Nt+2):(end)), F((Nt+2):(end)) - F_reco((Nt+2):(end)))
xlabel('t')
title('error')
grid on

% plot scheme residual
figure(3)
hold on;
plot(t(n_level:end),res)
xlabel('t')
title('scheme residual')
grid on

% get errors
sv_err = Sigma(end,end);
max_err = max(abs((F_reco-F)));

fprintf('number of levels:        %10d \n'  ,n_level);
fprintf('number of sample points: %10d \n'  ,Nt);
fprintf('lowest singular value:   %10.2e \n',sv_err);
fprintf('maximum error:           %10.2e \n',max_err);
fprintf('maximum scheme residual: %10.2e \n',max(abs(res)));

