clear; clc;

%% LOAD DATA FROM EXCEL

% USD rate
fileIn     = 'EERdatabase.xlsx'; %insert datafile name here
fileOut    = 'data_vars.mat';

% You need to updat this line if you plan to use newer data!!!
range        = 'A1:L177';

% You can select NER and NFA definition
[cpi names]  = xlsread(fileIn,'cpi',range);
USD          = xlsread(fileIn,'ner_eop',range);
% USD          = xlsread(fileIn,'ner_avg',range);  
gdp          = xlsread(fileIn,'gdppc_ppp',range);
nfa          = xlsread(fileIn,'nfa2gdp',range);
%nfa          = xlsread(fileIn,'nfa2exports',range);
tot          = xlsread(fileIn,'tot_all',range);
ca           = xlsread(fileIn,'ca',range);
ca_elastIMF  = xlsread(fileIn,'ca_elast','B2:L2');
share_x      = xlsread(fileIn,'xm_shares_gs',range);
share_m      = xlsread(fileIn,'xm_shares_gs','N1:X177');


T      = size(cpi,1);          % time dimension
N      = size(cpi,2);          % currency dimension
opt.T  = T;
opt.N  = N;

crncy_names  = names(1,[2:(N+1)])'; 
dates        = names(2:end,1);
opt.cnam     = crncy_names;
opt.dates    = dates;

% weights
[wghts wnam] = xlsread(fileIn,'weights_static','A1:M12');
temp         = [10 7 6 3 9 2 8 4 11 5 1];
w            = wghts(temp,temp);
w(isnan(w)) = 0;
w            = w./repmat(nansum(w),N,1);

% to gain the logic of weighting
% junk = wnam(2:12,1); [junk(temp) crncy_names] 


%% DEFINE VARIABLES
% log of relative CPI
rpi          = log(cpi) - log(cpi)*w;
% log of USD rate (increase stands for appreciation of dom. currency)
ner          = log(USD)*w - log(USD);
% log of USD real rate (increase stands for appreciation)
rer          = ner + rpi;
% log of relative gdp per capita
rgdp         = log(gdp) - log(gdp)*w;  
% log of relative terms of trade
rtot         = log(tot) - log(tot)*w;  
% relative nfa (choose which one)
rnfa         = nfa - nfa*w;  

% current account to gdp ratio
ca_y         = ca(1:T,1:N)/100;
%% removing Denmark
cnt_list = [1:3 5:N];
if 1
    rpi    = rpi(:,cnt_list);
    ner    = ner(:,cnt_list);
    rer    = rer(:,cnt_list);
    rgdp   = rgdp(:,cnt_list);
    rtot   = rtot(:,cnt_list);
    rnfa   = rnfa(:,cnt_list);
    ca_y   = ca_y(:,cnt_list);
    share_x   = share_x(:,cnt_list);
    share_m   = share_m(:,cnt_list);
    ca_elastIMF  = ca_elastIMF(:,cnt_list);
    crncy_names = crncy_names(cnt_list);
    opt.cnam    = crncy_names;
    opt.N       = opt.N - 1;
end

% save as a matlab data
save(fileOut,'rpi','ner','rer','rgdp','rnfa','rtot','ca_y','ca_elastIMF','share_x','share_m','opt')