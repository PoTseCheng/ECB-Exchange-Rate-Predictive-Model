% This file enables to replicate Figure 1-5 from the article 

close all
clear all
clc
format compact
%addpath('C:\Programy\MatlabUtils');

load data_vars;
load data_eer;

N    = opt.N;
T    = opt.T;
T1   = opt.T1;
qtrs = opt.qtrs;
crncy_names = opt.cnam;

%% Figures 1, 3 and 5 from the article. 
% RER vs Full sample EER vs Recursive EER
% Choose a model from: rer_ppp, rer_gdp, rer_nfa, rer_tot, rer_eba, feer_eba, feer_eba2 or feer_eba3
%rer_eq = rer_ppp; desc = 'PPP';    % Figure 1 in the article
%rer_eq = rer_eba; desc = 'BEER';   % Figure 3 in the article
rer_eq  = feer_eba; desc = 'MB';    % Figure 5 in the article
 
    smp = T1:T; % sample (between 1 and T)
    figure1 = figure('Color',[1 1 1]);
    axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
    hold(axes1,'all');        
    for n = 1:N
        subplot1 = subplot(5,2,n,'Parent',figure1,'FontName','Times New Roman', 'FontSize', 10);
        hold(subplot1,'all');
        plot(qtrs(smp,1),rer(smp,n),'LineWidth',2)
        xlim([1995 2019])
        ylim([min(min(rer(smp,n)),min(rer_eq(T,smp,n)))-0.01,max(max(rer(smp,n)),max(rer_eq(T,smp,n)))+0.01]) 
        hold on
        plot(qtrs(smp,1),rer_eq(T,smp,n)','LineStyle',':','Color',[0.25 0.25 0.25],'LineWidth',2)
        rec_eq = NaN(T,1);
        for t=T1:T
            rec_eq(t,1) =  rer_eq(t,t,n);
        end
        plot(qtrs(smp,1),rec_eq(smp,1)','LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',2)
        if n==N 
            lgd = legend({'rer','full sample equilibrium rer','recursive equilibrium rer'},'FontSize',13);
            lgd.Position = [0.65 0.1 0.15 0.1];
        end
        title(crncy_names{n})
    end

%% Figure 2 from the articles
% Recursive parameter estimates
% plot EBA regression coefficients (recursive)
coef_nam = [{'GDP'} {'NFA'} {'ToT'}];
mdl_nam  = [{'BEER'} {'CA norm'}];

coef_eba   = coefAll.eba;
coef_ebaCA = coefAll.ebaCA;

figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
hold(axes1,'all');        
for m = 1:2
   for k = 1:3
        subplot1 = subplot(2,3,k+(m-1)*3,'Parent',figure1,'FontName','Times New Roman', 'FontSize', 10);        
        hold(subplot1,'all');
        %n = R; % vintage number  (between 1 and R)
        if m==1; 
            plot(qtrs(T1:T,1),coef_eba(T1:T,k,1),'LineWidth',2); 
            ylim([min(min(coef_eba(T1:T,k,:)))-0.01,max(max(coef_eba(T1:T,k,:)))+0.01])
            title(coef_nam{k})
            hold on
            plot(qtrs(T1:T,1),coef_eba(T1:T,k,2),'LineStyle',':','Color',[0.25 0.25 0.25],'LineWidth',1)
            plot(qtrs(T1:T,1),coef_eba(T1:T,k,3),'LineStyle',':','Color',[0.25 0.25 0.25],'LineWidth',1)
        end
        if m==2; 
            plot(qtrs(T1:T,1),coef_ebaCA(T1:T,k,1),'LineWidth',2); 
            ylim([min(min(coef_ebaCA(T1:T,k,:)))-0.01,max(max(coef_ebaCA(T1:T,k,:)))+0.01])
            hold on
            plot(qtrs(T1:T,1),coef_ebaCA(T1:T,k,2),'LineStyle',':','Color',[0.25 0.25 0.25],'LineWidth',1)
            plot(qtrs(T1:T,1),coef_ebaCA(T1:T,k,3),'LineStyle',':','Color',[0.25 0.25 0.25],'LineWidth',1)
        end
        if k==1;
            ylabel(mdl_nam{m});
        end
        xlim([1995 2019])
     end
end


%% Figure 4 from the article. Current account norm
    smp = T1:T; % sample (between 1 and T)
    figure1 = figure('Color',[1 1 1]);
    axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
    hold(axes1,'all');        
    for n = 1:N
        subplot1 = subplot(5,2,n,'Parent',figure1,'FontName','Times New Roman', 'FontSize', 10);
        hold(subplot1,'all');
        plot(qtrs(smp,1),ca_y(smp,n),'LineWidth',2)
          xlim([1995 2018])
          ylim([min(min(ca_y(smp,n)),min(ca_eba(T,smp,n)))-0.02,max(max(ca_y(smp,n)),max(ca_eba(T,smp,n)))+0.02]) 
        hold on
        plot(qtrs(smp,1),ca_eba(T,smp,n)','LineStyle',':','Color',[0.25 0.25 0.25],'LineWidth',2)
        rec_eq = NaN(T,1);
        for t=T1:T
            rec_eq(t,1) =  ca_eba(t,t,n);
        end
        plot(qtrs(smp,1),rec_eq(smp,1)','LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',2)
        if n==N 
            lgd = legend({'ca','full sample CA norm','recursive CA norm'},'FontSize',11);
            lgd.Position = [0.65 0.1 0.15 0.1]; 
        end
        title(crncy_names{n})
    end
    
   


