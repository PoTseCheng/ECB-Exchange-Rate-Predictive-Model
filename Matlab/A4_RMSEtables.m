clear; clc;
load 'data_fct.mat'; % or data_fct_ner.mat for nominal exchange rate

% set to one if you want to export full sample coeffs and pvals of the forecasting reg. (DF & PanelDF models) 
exportCoeffs = 1;

% defining variables
M = size(ALLfct,2);            % number of models
for m = 1:M
    modelNam{m} = ALLfct{m}.description;
end
crncNam = opt.cnam;
N       = opt.N;
H       = opt.H;
ci      = 0; % =1 to run the Coroneo-Iacone (2018) version of the DM test

% loop

for m = 1:M
    mnm = modelNam{m};        
    for n=1:N
        cnm     = crncNam{n};        
        eval(['y  = ALLfct{m}.', cnm ,';'])         
        eval(['y0 = ALLfct{1}.', cnm ,';'])                 % benchmark model RW (for Clark - West statistic)
        fct        = y.fct;      fct0   = y0.fct;           % forecasts
        act        = y.act;      act0   = y0.act;           % actuals
        err        = act - fct;  err0   = act0 - fct0;      % forecast errors
        
        % checking for errors in actuals
        if act ~= act0
            aaa = [n m];
            display('Problem with actuals')
        end

        % statistics
        ME(n,:)     = nanmean(err);
        RMSE(n,:)   = sqrt(nanmean(err.^2));
        MSE(n,:)    = nanmean(err.^2);
        % Unbiasedness test for HO: ME(h)=0
        for h = 1:H
            x         = err(:,h); x = x(~isnan(x));
            temp      = NeweyWestSE(x);
            MEp(n,h)  = temp.prob;
        end
        % Diebold-Mariano / Clark-West test for HO: equal predictive  accuracy
        for h = 1:H
            a        = act(:,h);             
            f0       = fct0(:,h); f0 = f0(find(~isnan(a)));
            f1       = fct(:,h);  f1 = f1(find(~isnan(a)));  
            a        = a(find(~isnan(a))); 
            temp     = DMtest(f0, f1, a, ci, 0, 2); %DM
            DMp(n,h) = temp.prob;
            temp     = DMtest(f0, f1, a, ci, 1, 2); %CW for Clark-West
            CWp(n,h) = temp.prob;
            
            % forecasting regression coefficients and pvals for full sample
            % (exchange rate adjustment paramater)
            if (~isempty(regexp(mnm, regexptranslate('wildcard','*_DF'), 'once')) || ~isempty(regexp(mnm, regexptranslate('wildcard','*_PanelDF'), 'once')))
                coeffs(n,h) = y.estB(end,h);
                pvals(n,h)  = y.estP(end,h);
            end
        end

    end % end of loop for a model
        
    eval(['stat.',mnm,'.ME   = ME;']);
    eval(['stat.',mnm,'.MEp  = MEp;']);
    eval(['stat.',mnm,'.RMSE = RMSE;']);
    eval(['stat.',mnm,'.MSE  = MSE;']);
    eval(['stat.',mnm,'.DMp  = DMp;']);
    eval(['stat.',mnm,'.CWp  = CWp;']);
    
    if exportCoeffs && (~isempty(regexp(mnm, regexptranslate('wildcard','*_DF'), 'once')) || ~isempty(regexp(mnm, regexptranslate('wildcard','*_PanelDF'), 'once'))) 
        eval(['stat.',mnm,'.coeffs  = coeffs;']);
        eval(['stat.',mnm,'.pvals   = pvals;']);
    end

end % end of loop for a country

% Writes results to excel
horizons = [1 4 12 20]';

for m = 1:M
    disp(['Writing model #: ', int2str(m), ' of ', int2str(M)])
    mnm = modelNam{m};
    eval(['ME   = stat.',mnm,'.ME;']);    ME   = ME(:,horizons)';
    eval(['MEp  = stat.',mnm,'.MEp;']);   MEp  = MEp(:,horizons)';
    eval(['RMSE = stat.',mnm,'.RMSE;']);  RMSE = RMSE(:,horizons)'; 
    eval(['MSE  = stat.',mnm,'.MSE;']);  MSE  = MSE(:,horizons)'; 
    eval(['DMp  = stat.',mnm,'.DMp;']);   DMp  = DMp(:,horizons)';
    eval(['CWp  = stat.',mnm,'.CWp;']);   CWp  = CWp(:,horizons)';
    
    xlswrite('rmse',crncNam,              mnm, 'A3');
    xlswrite('rmse',{'Mean error'},       mnm, 'B1');
    xlswrite('rmse',horizons',             mnm ,'B2');
    xlswrite('rmse',ME',                  mnm ,'B3');
   
    xlswrite('rmse',{'Mean error prob.'}, mnm, 'G1');
    xlswrite('rmse',horizons',             mnm ,'G2');
    xlswrite('rmse',MEp',                 mnm ,'G3');
    
   xlswrite('rmse',{'RMSE'},             mnm, 'L1');
   xlswrite('rmse',horizons',             mnm ,'L2');
   xlswrite('rmse',RMSE',                mnm ,'L3');
    
    xlswrite('rmse',{'DM prob.'},         mnm, 'Q1');
    xlswrite('rmse',horizons',             mnm ,'Q2');
    xlswrite('rmse',DMp',                 mnm ,'Q3');
    
    xlswrite('rmse',{'CW prob.'},         mnm, 'V1');
    xlswrite('rmse',horizons',             mnm ,'V2');
    xlswrite('rmse',CWp',                 mnm ,'V3');
    
    if (~isempty(regexp(mnm, regexptranslate('wildcard','*_DF'), 'once')) || ~isempty(regexp(mnm, regexptranslate('wildcard','*_PanelDF'), 'once')))
        eval(['coeffs  = stat.',mnm,'.coeffs;']); coeffs  = coeffs(:,horizons)';
        eval(['pvals  = stat.',mnm,'.pvals;']);   pvals   = pvals(:,horizons)';
        
        xlswrite('rmse',{'coeff'},mnm, 'AA1');
        xlswrite('rmse',horizons', mnm ,'AA2');
        xlswrite('rmse',coeffs',  mnm ,'AA3');
        
        xlswrite('rmse',{'p-val (NW SE)'},mnm, 'AF1');
        xlswrite('rmse',horizons', mnm ,'AF2');
        xlswrite('rmse',pvals',  mnm ,'AF3');
    end
end
  