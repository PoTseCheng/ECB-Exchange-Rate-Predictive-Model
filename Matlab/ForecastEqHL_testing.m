%%testing for functions
clear; clc;

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