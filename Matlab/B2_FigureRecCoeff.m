% This file enables to replicate Figure 7 from the article

close all
clear all
clc
format compact

load data_fct;

T    = opt.T;
T1   = opt.T1;
qtrs = opt.qtrs;

% select horizons
hSet  = [1 4 12 20];
% select models, 18 - PPP_PDF, 22 - BEER_PDF, 23 - MB_PDF
mSet  = [18 22 23]; 
modelNames = [{'PPP'} {'BEER'} {'MB'}];


smp = T1:(T-1); % sample (between 1 and T)
figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
hold(axes1,'all');        
ylim0 = [-0.1 0.01; -0.4 0.05; -1 0.05; -1.2 0.05];

for n = 1:4
        subplot1 = subplot(2,2,n,'Parent',figure1,'FontName','Times New Roman', 'FontSize', 10);
        hold(subplot1,'all');
        plot(qtrs(smp,1),ALLfct{mSet(1)}.AUS.estB(:,hSet(n)),'LineWidth',2,'Color',[0 0 0])
        xlim([1995 2019])
        ylim(ylim0(n,:)) 
        hold on
        plot(qtrs(smp,1),ALLfct{mSet(2)}.AUS.estB(:,hSet(n)),'LineStyle','--','Color',[0.25 0.25 0.25],'LineWidth',2)
        plot(qtrs(smp,1),ALLfct{mSet(3)}.AUS.estB(:,hSet(n)),'LineStyle',':','Color',[0.5 0.5 0.5],'LineWidth',2)
        line([qtrs(T1), qtrs(T-1)], [0, 0],'LineWidth',0.5,'Color',[1 0 0]);
        title(['H=',num2str(hSet(n))])
end

