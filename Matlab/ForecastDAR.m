function z = ForecastDAR2(x, xeq, opt_)

% Direct forecast for RER 
% x      - real echange rate (in logs)
% xeq    - equilibrium er series
% opt_   - setup of forecasting exercise; 

T    = opt_.T;    % total number of observations
T1   = opt_.T1;
K    = T-T1;      % number of forecasts
H    = opt_.H;

fctA       = NaN(K,H);
actA       = NaN(K,H);
estB       = NaN(K,H);
estP       = NaN(K,H);

%parfor k = 1:K
for k = 1:K    
   [estB(k,:) estP(k,:) actA(k,:) fctA(k,:)]= par_nw(k,x,xeq,H,T,T1);
end
% output
z.fct      = fctA;                % point forecast for NER
z.act      = actA;                % actuals
z.estB     = estB;                % estimates of adjustment param
z.estP     = estP;                % p-values

 