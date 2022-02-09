%%testing for functions
clear; clc;

format compact
addpath(genpath('Utils'));
addpath(genpath('PanelToolbox'));

load 'data_vars.mat' 
load 'data_eer.mat'

%% Settings for forecasting loop

H = 20; opt.H = H;              % forecast horion


% Forecasting loop
m = 0; % model counter


% Calibrated Half Life models

 display('HL models are running...');
 rho = 0.5^(1/12); % 12 quarters HL (3 years)
 
 rer_eq = rer_ppp; desc = 'PPP_HL';
 %rer_eq = rer_eba; desc = 'EBA_HL';
 
 %for n = 1:opt.N
 %    crnc_name    = char(opt.cnam(n));
 %    fcst         = ForecastEqHL(rer(:,n),rer_eq(:,:,n), opt, rho);
 %    eval(['f.',crnc_name,'= fcst;'])
 %end
 fcst         = ForecastEqHL(rer(:,1),rer_eq(:,:,1), opt, rho);
 %ALLfct{1} = f;
 %ALLfct{1}.description = desc;
 %clear f;
