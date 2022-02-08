clear
format compact
addpath(genpath('Utils'));
addpath(genpath('PanelToolbox'));

load 'data_vars.mat' 
load 'data_eer.mat'

%% Settings for forecasting loop

H = 20; opt.H = H;              % forecast horion
mdlN_max = 8;                   % number of EER models (PPP, 4xBEER, 3xMB)

% Forecasting loop
m = 0; % model counter

% Random Walk 
if 1
    display('Random Walk is running...');
    m = m + 1;
    for n = 1:opt.N
        crnc_name    = char(opt.cnam(n));
        fcst         = ForecastRW(rer(:,n), opt);
        eval(['f.',crnc_name,'= fcst;'])
    end
    ALLfct{m} = f;
    ALLfct{m}.description = 'RW';
    clear f;
end

% Calibrated Half Life models
if 1
    display('HL models are running...');
    rho = 0.5^(1/12); % 12 quarters HL (3 years)
    for mdlN = 1:mdlN_max
        m = m + 1;
        switch(mdlN)
            case 1
                rer_eq = rer_ppp; desc = 'PPP_HL';
            case 2
                rer_eq = rer_gdp; desc = 'GDP_HL';
            case 3
                rer_eq = rer_nfa; desc = 'NFA_HL';
            case 4
                rer_eq = rer_tot; desc = 'TOT_HL';
            case 5
                rer_eq = rer_eba; desc = 'EBA_HL';
            case 6
                rer_eq = feer_eba; desc = 'FEER_HL';
            case 7
                rer_eq = feer_eba2; desc = 'FEER2_HL';
            case 8
                rer_eq = feer_eba3; desc = 'FEER3_HL';
        end
        % currency loop
        for n = 1:opt.N
            crnc_name    = char(opt.cnam(n));
            fcst         = ForecastEqHL(rer(:,n),rer_eq(:,:,n), opt, rho);
            eval(['f.',crnc_name,'= fcst;'])
        end
        ALLfct{m} = f;
        ALLfct{m}.description = desc;
        clear f;
    end
end

% Direct forecast regression models
if 1
    display('Individual direct forecast');
    for mdlN = 1:mdlN_max 
        m = m + 1;
        switch(mdlN)
            case 1
                rer_eq = rer_ppp; desc = 'PPP_DF';
            case 2
                rer_eq = rer_gdp; desc = 'GDP_DF';
            case 3
                rer_eq = rer_nfa; desc = 'NFA_DF';
            case 4
                rer_eq = rer_tot; desc = 'TOT_DF';
            case 5
                rer_eq = rer_eba; desc = 'EBA_DF';
            case 6
                rer_eq = feer_eba; desc = 'FEER_DF';
            case 7
                rer_eq = feer_eba2; desc = 'FEER2_DF';
            case 8
                rer_eq = feer_eba3; desc = 'FEER3_DF';
        end
        
        rer_gap = bsxfun(@minus,permute(rer,[3 1 2]),rer_eq);
        if 1 % set to 0 if only scatter plots need to be created (no fcst calc.)
            for n = 1:opt.N
                disp(['Model: ' desc ' (' int2str(mdlN) '/' int2str(mdlN_max) '); country: ' int2str(n) '/' int2str(opt.N)])
                crnc_name    = char(opt.cnam(n));
                fcst         = ForecastDAR(rer(:,n),rer_gap(:,:,n), opt);
                eval(['f.',crnc_name,'= fcst;'])
            end
            ALLfct{m} = f;
            ALLfct{m}.description = desc;
            clear f;
        end
    end 
end

% Panel Direct forecast models
if 1
    display('Panel direct forecast');
    for mdlN = 1:mdlN_max %_DF
        m = m + 1;
        
        switch(mdlN)
            case 1
                rer_eq = rer_ppp; desc = 'PPP_PanelDF';
            case 2
                rer_eq = rer_gdp; desc = 'GDP_PanelDF';
            case 3
                rer_eq = rer_nfa; desc = 'NFA_PanelDF';
            case 4
                rer_eq = rer_tot; desc = 'TOT_PanelDF';
            case 5
                rer_eq = rer_eba; desc = 'EBA_PanelDF';
                
            case 6
                rer_eq = feer_eba; desc = 'FEER_PanelDF';
            case 7
                rer_eq = feer_eba2; desc = 'FEER2_PanelDF';
            case 8
                rer_eq = feer_eba3; desc = 'FEER3_PanelDF';
        end
        rer_gap = bsxfun(@minus,permute(rer,[3 1 2]),rer_eq);        
        ALLfct{m} = ForecastPanelDAR(rer,rer_gap, opt);
        ALLfct{m}.description = desc;       
    end
end

% save all forecasts
save('data_fct.mat', 'ALLfct', 'opt')

