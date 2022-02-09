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
 
T    = opt.T;    % total number of observations
T1   = opt.T1;
K    = T-T1;      % number of forecasts
H  = opt.H;

fctA      = NaN(K,H);
actA      = NaN(K,H);

k = 1
t            = T1+k-1;
RW  = rer(t,1);                       % last observation
Eq  = rer_eq(t,t);                     % equilibrium 
fctA(k,:) = (RW-Eq)*rho.^(1:H)+Eq;

