function output = Panel_FMOLS(y,x)

% **     Barlett kernel
% **     Newey-West bandwidth
% **
% **     Panel Fully-Modified
% **
% **     beta = Panel_FMOLS(y,x)
% **
% **     INPUT 
% **             T - number of time periods
% **             N - number of cross-sectional units
% **             y - T x N matrix, dependent variable 
% **             x - T x (kN) independent variables with multiple variables
% **
% **       beta - coefficients
% **
yStart = y;
xStart = x;
meanY  = mean(y);
meanX  = mean(x);

[T N]     = size(y);
K         = size(x,2)/N; % number of explanatory variables

dx        = x(2:T,:)-x(1:T-1,:);
yM        = demean(y);
xM        = demean(x);
dxM       = demean(dx);
y1M       = demean(y(2:T,:));
x1M       = demean(x(2:T,:));

% in a vectorized form
yMvec     = vec(yM);
y1Mvec    = vec(y1M);
xM_vec  = zeros(N*T,K);
dxM_vec  = zeros(N*(T-1),K);
x1M_vec = zeros(N*(T-1),K);
for i= 1:K
    xM_vec(:,i)  = vec(xM(:,(1+(i-1)*N):(i*N)));
    dxM_vec(:,i) = vec(dxM(:,(1+(i-1)*N):(i*N)));
    x1M_vec(:,i) = vec(x1M(:,(1+(i-1)*N):(i*N)));
end

% OLS
Z         = xM_vec;
betOLS    = inv(Z'*Z)*(Z'*yMvec);               
uOLS      = reshape(yMvec - Z*betOLS,T,N);

uOLS1     = uOLS(2:T,:); 

% long-run matrix
bw      = floor(4*(T/100)^(2/9));   % bandwidth
Tu      = T-1;
Sigma   = 0;
Omega   = 0;
Delta   = 0;

for n=1:N
        u     = demean([uOLS1(:,n) dx(:,(0:(K-1))*N+n)]);
        Gam = 0;
        for l=1:bw
                m  = 1 - abs(l)/(bw+1);
                t1 = u((l+1):Tu,:); 
                t2 = u(1:(Tu-l),:); 
                Gam  = Gam + m*(t1'*t2)/Tu;
        end
        Sigma_i  = u'*u/Tu; 
        Omega_i  = Sigma_i  + Gam + Gam';
        Delta_i  = Sigma_i  + Gam';
        
        Sigma   = Sigma + Sigma_i/N;
        Omega   = Omega + Omega_i/N;
        Delta   = Delta + Delta_i/N;
end
        

% FM OLS
Omega_uu = Omega(1,1);
Omega_uv = Omega(1,2:1+K);
Omega_vu = Omega(2:1+K,1);
Omega_vv = Omega(2:1+K,2:1+K);
Delta_uu = Delta(1,1);
Delta_uv = Delta(1,2:1+K);
Delta_vu = Delta(2:1+K,1);
Delta_vv = Delta(2:1+K,2:1+K);

Omega_vv_inv    = inv(Omega_vv);
Omega_vv_inv_vu = Omega_vv_inv*Omega_vu;
Omega_u_v       = Omega_uu - (Omega_uv * Omega_vv_inv_vu);
Delta_vuplus    = Delta_vu - (Delta_vv * Omega_vv_inv_vu);

%y_plus          = y(2:T)  - (xDelta * Omega_vv_inv_vu);
y_plus          = y1Mvec  - (dxM_vec * Omega_vv_inv_vu);
Zfm2s           = inv(x1M_vec'*x1M_vec); 
numerat         = y_plus' * x1M_vec - T * Delta_vuplus'; 
betFM           = Zfm2s * numerat';                         

% standard errors
uFM             = y1Mvec - x1M_vec * betFM;
uFM             = reshape(uFM,T-1,N);
varmat          = Omega_u_v(1,1) * Zfm2s;
sdFM            = sqrt(diag(varmat));                       
tFM             = betFM./sdFM;
df              = T*N - K;
pvalFM          = 2 * tcdf(-abs(tFM),df); 

% R squarred
RSS         = sum(sum(uFM.^2));
TSS         = sum(sum(y1M.^2));
Rsquare     = 1-RSS/TSS; %@ Rsquare within@

% Fixed effects
FE = zeros(N,1);
for i = 1:N
    FE(i) = meanY(i) - meanX((0:(K-1))*N+i)*betFM;
end

% saving results
output.betaLS  = betOLS;
output.betaFM  = betFM;
output.stdFM   = sdFM;
output.tFM     = tFM;
output.pvalFM  = pvalFM;
output.T       = T;
output.N       = N;
output.r2      = Rsquare;
output.FE      = FE;

% functions

% vectorization
function out = vec(y)  
out = y(:);

% demeaning
function out = demean(y)  
T = size(y,1);
out = y - repmat(mean(y),T,1);




