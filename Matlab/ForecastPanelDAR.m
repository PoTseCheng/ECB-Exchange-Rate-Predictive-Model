function z = ForecastPanelDAR(x,xeq, opt_)
% Direct forecast from FE panel model for RER 
% rer    - real echange rate (in logs) for all currencies
% opt_   - setup of forecasting exercise; 

T    = opt_.T;    % total number of observations
T1   = opt_.T1;
K    = T-T1;      % number of forecasts
H    = opt_.H;
N    = opt_.N;    % number of currencies
qtrs = opt_.qtrs;

fctA       = NaN(K,H,N);
actA       = NaN(K,H,N);
estB       = NaN(K,H);
estP      = NaN(K,H);
   
for k = 1:K
    t            = T1+k-1;
    for h=1:H
        y0           = x((h+1):t,:) - x(1:(t-h),:);     % dependent variable
        mis          = permute(xeq(t,1:t,:),[2 3 1]);         % misalignment
        x0           = mis(1:(t-h),:);
        % creating time and country identifiers
        IDt    = repmat(qtrs((h+1):t),N,1);   
        IDn    = repmat(1:N,t-h,1); IDn = IDn(:);
        %{
        % fe panel - fast method
        tempY = y0(:)- groupmeans(IDn,y0(:),'replicate',1);
        tempX = x0(:)- groupmeans(IDn,x0(:),'replicate',1);
        bet   = inv(tempX'*tempX)*tempX'*tempY;
        fe    = groupmeans(IDn,y0(:),'replicate',0) - bet* groupmeans(IDn,x0(:),'replicate',0);     % fixed effect
        %}
        % panel estimation - with panel toolbox
        temp = panel(IDn, IDt, y0(:), x0(:), 'fe');
        bet = temp.coef;        % beta
        fe  = ieffects(temp);
        
        temp.t_stat = temp.coef ./ temp.stderr;
        temp.pval = 2 * tcdf(-abs(temp.t_stat), repmat(temp.resdf, size(temp.t_stat)));
        
        % forecast
        fctA(k,h,:) = x(t,:) + fe' + mis(t,:)*bet;
        estB(k,h)   = bet;
        estP(k,h)  = temp.pval;
    end
    % check which actuals exist
    Hf    = H;
    if t+H > T; Hf = T-t; end
    actA(k,1:Hf,:)  = x((t+1):(t+Hf),:);
end

% crnc_name    = char(opt_.cnam(crncy))

for n = 1:N
            crnc_name    = char(opt_.cnam(n));
            eval(['z.',crnc_name,'.fct = fctA(:,:,n);'])
            eval(['z.',crnc_name,'.act = actA(:,:,n);'])
            eval(['z.',crnc_name,'.estB = estB;'])
            eval(['z.',crnc_name,'.estP = estP;'])
end

 