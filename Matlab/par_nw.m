function [coef pval act forecast] = par_nw(k,x,xeq,H,T,T1)
    t = T1+k-1;
    for h=1:H
        y0  = x((h+1):t,1) - x(1:(t-h),1);      % dependent variable
        mis = xeq(t,1:t)';                      % misalignment
        x0  = mis(1:(t-h),1);
        
        reg       = NeweyWestSE(y0,x0);
        estB(k,h) = reg.b(2);
        estP(k,h) = reg.prob(2);
        fctA(k,h) = x(t,1) + [1 mis(t,1)]*reg.b;
    end
    
    % actuals
    Hf    = H;
    if t+H > T; Hf = T-t; end
    actA(k,1:Hf) = x((t+1):(t+Hf),1);
    
    % output
    coef=estB(k,:);
    pval=estP(k,:);
    act=[actA(k,1:Hf) NaN(1,H-Hf)];
    forecast=fctA(k,:);
end