clear; clc;

%% LOAD DATA 
load('data_vars.mat') 
T     = opt.T;
N     = opt.N;
dates = opt.dates;
crncy_names = opt.cnam;

% start of sample
date0 = dates{1};
y0    = str2num(date0(1:4));
q0    = str2num(date0(7));

% obsevations in numeric format
qtrs = (y0 + (q0-1)/4 + (1:T)/4)'; opt.qtrs = qtrs;

% Set the first vintage to be used for forecast evaluation (1994Q4 in the IJCB article, so that foreast evaluation starts in 1995Q1)
y1 = 1994;
q1 = 4;
T1 = 4*(y1-y0)+(q1-q0)+1; opt.T1 = T1; % first vintage of data
% number of vintages (from T1 to T)
datesf    = dates(T1:T);  opt.datesf = datesf;
R         = T-T1+1;       opt.R      = R;

%% You need to make some choices about CA to RER reaction to estimate FEER %%
% In the paper this is given by parameter \nu in eq (4)

%
% Option 1: \nu=-0.2 for all countries and periods
% ca_elast = repmat(-0.2,opt.T,opt.N); % set all elasticities to 0.2
% ca_elast = -1*repmat(ca_elastIMF,opt.T,1); % use the elast. from 2018 IMF ext. sector report

% Option 2. Based on trade model and perfect pass-through: PCP
% elast_x = 0.71; elast_m = 0.92;                    % set elasticities of X and M (IMF 1998)
% ca_elast = share_m*(1-elast_m)-share_x*elast_x;

% Option 3. Our baseline described by equation (6) of the article
% The effect of 1% appreciation on CA/GDP is calculated as:
% nominal value of exports is increasing by (erpt_x + (erpt_x+1)*elast_x) 
% nominal value of imports is increasing by (erpt_m + erpt_m    *elast_m)
% dCA = X/Y dX - M/Y dM
erpt_x1    = 0;     erpt_m1  = -1;    % PT on prices in domestic currency
elast_x1   = -1;    elast_m1 = -1;    % set elasticities of X and M 
ca_elast   = share_x*(erpt_x1 + (erpt_x1+1)*elast_x1) - share_m*(erpt_m1 + erpt_m1*elast_m1);
% See column PCP in Table 8 of the article
mean(ca_elast(173:176,:))

% Imperfect pass-through: elasticities and pass-through of X and M (IMF 2017, table 5)
erpt_x2   = -0.5;     erpt_m2  = -0.5;      % PT on prices in domestic currency
elast_x2  = -0.5;     elast_m2 = -0.5;      % set elasticities of X and M (IMF 1998)
ca_elast2 = share_x*(erpt_x2 + (1+erpt_x2)*elast_x2) - share_m*(erpt_m2 + erpt_m2*elast_m2);
% See column IPT in Table 8 of the article
mean(ca_elast2(173:176,:))

%% EQ RER ROLLING - ESTIMATE EQUILIBRIUM EXCHANGE RATES
rer_ppp   = NaN(T,T,N);                        % recursive estimates for PPP

rer_gdp   = NaN(T,T,N); coef_gdp = NaN(T,1,3); % recursive estimates for BEER with GDP
rer_nfa   = NaN(T,T,N); coef_nfa = NaN(T,1,3); % recursive estimates for BEER with NFA
rer_tot   = NaN(T,T,N); coef_tot = NaN(T,1,3); % recursive estimates for BEER with TOT
rer_eba   = NaN(T,T,N); coef_eba = NaN(T,3,3); % recursive estimates for BEER with GDP, NFA and TOT

ca_eba    = NaN(T,T,N); coef_ebaCA = NaN(T,3); % recursive estimates for Target CA
feer_eba  = NaN(T,T,N);                        % recursive estimates for MB (TCA + PCP)
feer_eba2 = NaN(T,T,N);                        % recursive estimates for MB (TCA + IPT)
feer_eba3 = NaN(T,T,N);                        % recursive estimates for MB (TCA at 0 + PCP)

reg_results_eba = cell(4,1);                   % an objectto save full sample results (Table 3 in the article)

for tt = T1:T
  disp(['Iteration: ' int2str(tt) '/' int2str(T)])
  
  % Defining panel variables
  rerR            = rer(1:tt,:);
  gdpR            = rgdp(1:tt,:);
  nfaR            = rnfa(1:tt,:);
  totR            = rtot(1:tt,:);
  caR             = ca_y(1:tt,:);
  % hp filtered ToT for CA regression
  %[~,totcR] = hpfilter(rtot(1:tt,:), 1600); % if econometrics package a/v.
  totcR=nan(tt,opt.N);
  for id = 1:opt.N 
      trend = hpfilter2(rtot(1:tt,id),1600);
      totcR(:,id) = rtot(1:tt,id) - trend;
  end
   
  % 1. PPP  
  rer_ppp(tt,1:tt,:)  = repmat(mean(rerR),tt,1);
  
  % 2. BEER based on GDP
  x      = gdpR;
  xvec   = [gdpR(:)];
  fmR    = Panel_FMOLS(rerR,x);
  rer_gdp(tt,1:tt,:)   = reshape(xvec*fmR.betaFM,[tt,N]) + repmat(fmR.FE',tt,1);
  coef_gdp(tt,1,1)      = fmR.betaFM;
  coef_gdp(tt,1,2)      = fmR.betaFM - 1.96*fmR.stdFM;
  coef_gdp(tt,1,3)      = fmR.betaFM + 1.96*fmR.stdFM;
  if tt==T 
      reg_results_eba{1,1} = fmR; % save results for full sample regression table
  end
  
  % 3. BEER based on NFA
  x      = nfaR;
  xvec   = [nfaR(:)];
  fmR    = Panel_FMOLS(rerR,x);
  rer_nfa(tt,1:tt,:)  = reshape(xvec*fmR.betaFM,[tt,N]) + repmat(fmR.FE',tt,1);
  coef_nfa(tt,1,1)      = fmR.betaFM;
  coef_nfa(tt,1,2)      = fmR.betaFM - 1.96*fmR.stdFM;
  coef_nfa(tt,1,3)      = fmR.betaFM + 1.96*fmR.stdFM;
  if tt==T 
      reg_results_eba{2,1} = fmR; % save results for full sample regression table
  end
  
  % 4. BEER based on TOT
  x      = totR;
  xvec   = [totR(:)];
  fmR    = Panel_FMOLS(rerR,x);
  rer_tot(tt,1:tt,:)  = reshape(xvec*fmR.betaFM,[tt,N]) + repmat(fmR.FE',tt,1);
  coef_tot(tt,1,1)      = fmR.betaFM;
  coef_tot(tt,1,2)      = fmR.betaFM - 1.96*fmR.stdFM;
  coef_tot(tt,1,3)      = fmR.betaFM + 1.96*fmR.stdFM;
  if tt==T 
      reg_results_eba{3,1} = fmR; % save results for full sample regression table
  end
  
  % 5. BEER based on GDP NAF and TOT
  x      = [gdpR nfaR totR];
  xvec   = [gdpR(:) nfaR(:) totR(:)];
  fmR    = Panel_FMOLS(rerR,x);
  rer_eba(tt,1:tt,:)  = reshape(xvec*fmR.betaFM,[tt,N]) + repmat(fmR.FE',tt,1);
  coef_eba(tt,:,1)      = fmR.betaFM';
  coef_eba(tt,:,2)      = fmR.betaFM' - 1.96*fmR.stdFM';
  coef_eba(tt,:,3)      = fmR.betaFM' + 1.96*fmR.stdFM';
  if tt==T 
      reg_results_eba{4,1} = fmR; % save results for full sample regression table
  end
  
  % 6. Target CA regression
  y2      = caR(:);                     %vectorize matrix for FE estimation
  x2      = [gdpR(:) nfaR(:) totcR(:)];  %vectorize matrix for FE estimation
  
  feR     = NeweyWestSE(y2,x2); feR.coeff = feR.b; feR.pval = feR.prob; 
  % fe      = newey(y2,x2);
  ca_eba(tt,1:tt,:)       = reshape([ones(size(x2,1),1) x2]*feR.coeff,[tt,N]);
  coef_ebaCA(tt,:,1)      = feR.b(2:4)';
  coef_ebaCA(tt,:,2)      = feR.b(2:4)' - 1.96*feR.Se(2:4)';
  coef_ebaCA(tt,:,3)      = feR.b(2:4)' + 1.96*feR.Se(2:4)';
  if tt==T 
      reg_results_ca{1,1} = feR; % save results for full sample regression table
  end
  
  % MB based on TCA and PCP
  ca_gap        = ca_y(1:tt,:) - squeeze(ca_eba(tt,1:tt,:));
  adj_needed    = -1*ca_gap./ca_elast(1:tt,:);
  feer_eq       = rer(1:tt,:)+adj_needed;
  feer_eba(tt,1:tt,:) = feer_eq;
  
  % MB based on TCA and IPT(=DCP)
  ca_gap        = ca_y(1:tt,:) - squeeze(ca_eba(tt,1:tt,:));
  adj_needed    = -1*ca_gap./ca_elast2(1:tt,:);
  feer_eq2      = rer(1:tt,:)+adj_needed;
  feer_eba2(tt,1:tt,:) = feer_eq2;
  
  % MB based on TCA at 0 CA norm equal to 0) and PCP
  ca_gap        = ca_y(1:tt,:) - 0;
  adj_needed    = -1*ca_gap./ca_elast(1:tt,:);
  feer_eq3      = rer(1:tt,:)+adj_needed;
  feer_eba3(tt,1:tt,:) = feer_eq3;
end  

coefAll.gdp     = coef_gdp;
coefAll.nfa     = coef_nfa;
coefAll.tot     = coef_tot;
coefAll.eba     = coef_eba;
coefAll.ebaCA   = coef_ebaCA;

% save as a matlab data
save('data_eer.mat','rer_ppp','rer_gdp','rer_nfa','rer_tot','rer_eba','ca_eba','feer_eba','feer_eba2','feer_eba3','coefAll','reg_results_eba','opt');

%% Saving the results to excel
% export EBA regression tables
if 0 
    regNames = {'GDP','NFA','TOT','EBA'};
    regTable = NaN(6,2*4);
    for i=1:4
        res = reg_results_eba{i,1};
        regTable(1:3,i*2-1) = res.betaFM;
        regTable(4,i*2-1)   = res.N;
        regTable(5,i*2-1)   = res.N*res.T;
        regTable(6,i*2-1)   = res.r2;

        res.df      = res.N*res.T - res.N - length(res.betaFM);
        res.tstatFM = res.betaFM ./ res.stdFM;
        res.pval    = 2 * tcdf(-abs(res.tstatFM), repmat(res.df, size(res.tstatFM)));
        regTable(1:3,i*2) = res.pvalFM;

        %bic = res.N*log(res.RSS/res.N)+(res.k+res.n)*log(res.N);
    end
    xlswrite('regTable_eba.xlsx',regTable,'table','B2');
    clear res
end 

% export CA regression tables
if 0
  rtotc=nan(tt,opt.N);
  for id = 1:opt.N 
      trend = hpfilter2(rtot(:,id),1600);
      rtotc(:,id) = rtot(:,id) - trend;
  end
  reg_results_eba = cell(4,1);
  reg_results_ca{1,1} = NeweyWestSE(ca_y(:), rgdp(:));
  reg_results_ca{2,1} = NeweyWestSE(ca_y(:), rnfa(:));
  reg_results_ca{3,1} = NeweyWestSE(ca_y(:), rtotc(:));
  reg_results_ca{4,1} = NeweyWestSE(ca_y(:), [rgdp(:) rnfa(:) rtotc(:)]);
    
  %[coeff se ~] = fgls([rgdp(:) rnfa(:) rtot(:)], ca_y(:),'innovMdl','AR','arLags',1,'display','final');

    regTableCA  = NaN(7,2*2);
    for i=1:4
        regNames    = {'GDP','NFA','TOT','EBA'};
        res         = reg_results_ca{i,1};
        if i==4
            regTableCA(1:4,i*2-1)   = res.b;
            regTableCA(1:4,i*2)     = res.prob;
        else 
            regTableCA(1:2,i*2-1)   = res.b;
            regTableCA(1:2,i*2)     = res.prob;
        end
        regTableCA(5,i*2-1)   = opt.N;
        regTableCA(6,i*2-1)   = opt.N*opt.T;
        regTableCA(7,i*2-1)   = res.R2;

        %res.df      = res.N*res.T - res.N - length(res.betaFM);
        %res.t_stat  = res.coef ./ res.stderr;
        %res.pval    = 2 * tcdf(-abs(res.t_stat), repmat(res.df, size(res.t_stat)));
            %bic = res.N*log(res.RSS/res.N)+(res.k+res.n)*log(res.N);
    end
xlswrite('regTable_ca.xlsx',regTableCA,'table','B2');
clear res
end

% export estimated eq FX and actual rer and CA elast.
if 0
    c         = cell(3,2);
    c{1,1}    = rer; c{1,2} = 'rer';
    c{2,1}    = squeeze(rer_eba(end,:,:)); c{2,2} = 'rer_eba';
    c{3,1}    = squeeze(feer_eba(end,:,:)); c{3,2} = 'feer';
    for i = 1:size(c,1) 
        tmp_var        = c{i,1};
        tmp_out        = exp(tmp_var);
        tmp_out_reb    = 100*tmp_out./repmat(tmp_out(141,:),opt.T,1); % Q1 2010 = 100

        xlswrite('rer',tmp_out_reb, c{i,2}, 'B2');
        xlswrite('rer',opt.cnam', c{i,2}, 'B1');
        xlswrite('rer',opt.dates, c{i,2}, 'A2');
    end
end


