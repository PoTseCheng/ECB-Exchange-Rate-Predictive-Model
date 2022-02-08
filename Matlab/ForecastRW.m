function z = ForecastRW(x, opt_)

T    = opt_.T;    % total number of observations
T1   = opt_.T1;
K    = T-T1;      % number of forecasts
H    = opt_.H;

fctA      = NaN(K,H);
actA      = NaN(K,H);
    
for k = 1:K
    t            = T1+k-1;
    % forecasts
    fctA(k,:)    = x(t,1)*ones(1,H);   
    % actuals
    Hf    = H;
    if t+H > T; Hf = T-t; end
    actA(k,1:Hf) = x((t+1):(t+Hf),1);
end
z.fct      = fctA;                % point forecast for RER only
z.act      = actA;                % actuals


 