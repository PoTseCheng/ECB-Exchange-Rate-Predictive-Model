close all
clear all
clc
format compact
load data_fct;


%% ALL countries plot

crncy_names = opt.cnam;
% select the benchmark, 1 - RW
mBench = 1; 
% select 3 models, 18 - PPP_PDF, 22 - BEER_PDF, 23 - MB_PDF
mSet  = [18 22 23];                      
%modelNames = [{ALLfct{mSet(1)}.description} {ALLfct{mSet(2)}.description} {ALLfct{mSet(3)}.description}];
modelNames = [{'PPP'} {'BEER'} {'MB'}];
% Horizon
H = 20;
% set scale
ylim0 = [0.7 1.2];
% RMSE for the benchmark
figure('Name','RMSEratio','Color',[1 1 1]);
figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
hold(axes1,'all');  

for n=1:10
    cnm = crncy_names{n};

    eval(['y0  = ALLfct{mBench}.', cnm ,';']) 
    act  = y0.act; fct0   = y0.fct; err0   = act - fct0; RMSE0  = sqrt(nanmean(err0.^2));

    % RMSE for EqRER models
    RMSE = NaN(20,3);
    for m=1:3
        eval(['y   = ALLfct{mSet(m)}.', cnm ,';']) 
        fct    = y.fct; 
        err    = act - fct;  
        RMSE(:,m)   = sqrt(nanmean(err.^2))./RMSE0;
    end
    
    ylim0 = [min(min(RMSE))-0.02; max([max(RMSE)+0.02,1.02]) ];

    subplot1 = subplot(5,2,n,'Parent',figure1,'FontName','Times New Roman', 'FontSize', 10);
    hold(subplot1,'all');
    plot(1:H,RMSE(:,1)','LineWidth',2,'Color',[0 0 0])
    ylim(ylim0) 
    hold on
    plot(1:H,RMSE(:,2)','LineStyle','--','Color',[0.25 0.25 0.25],'LineWidth',2)
    plot(1:H,RMSE(:,3)','LineStyle',':','Color',[0.5 0.5 0.5],'LineWidth',2)
    line([1, H], [1, 1],'LineWidth',0.5,'Color',[1 0 0]);
    title([cnm])
    % legend(modelNames,'FontSize',15,'Location','southwest'); legend boxoff             

end

%% Individual country plot
if 0
    % select a currency from USA EA JPN GBR CHE CAN AUS NZL NOR SWE
    cnm    = 'EA';
    % select the benchmark, 1 - RW
    mBench = 1; 
    % select 3 models, 18 - PPP_PDF, 22 - BEER_PDF, 23 - MB_PDF
    mSet  = [18 22 23];                      
    %modelNames = [{ALLfct{mSet(1)}.description} {ALLfct{mSet(2)}.description} {ALLfct{mSet(3)}.description}];
    modelNames = [{'PPP'} {'BEER'} {'MB'}];
    % Horizon
    H = 20;
    % set scale
    ylim0 = [0.7 1.2];
    % RMSE for the benchmark
    eval(['y0  = ALLfct{mBench}.', cnm ,';']) 
    act  = y0.act; fct0   = y0.fct; err0   = act - fct0; RMSE0  = sqrt(nanmean(err0.^2));

    % RMSE for EqRER models
    RMSE = NaN(20,3);
    for m=1:3
        eval(['y   = ALLfct{mSet(m)}.', cnm ,';']) 
        fct    = y.fct; 
        err    = act - fct;  
        RMSE(:,m)   = sqrt(nanmean(err.^2))./RMSE0;
    end

    figure('Name','RMSEratio','Color',[1 1 1]);
    figure1 = figure('Color',[1 1 1]);
    axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
    hold(axes1,'all');        
    subplot1 = subplot(1,1,1,'Parent',figure1,'FontName','Times New Roman', 'FontSize', 10);
    hold(subplot1,'all');
    plot(1:H,RMSE(:,1)','LineWidth',2,'Color',[0 0 0])
    ylim(ylim0) 
    hold on
    plot(1:H,RMSE(:,2)','LineStyle','--','Color',[0.25 0.25 0.25],'LineWidth',2)
    plot(1:H,RMSE(:,3)','LineStyle',':','Color',[0.5 0.5 0.5],'LineWidth',2)
    line([1, H], [1, 1],'LineWidth',0.5,'Color',[1 0 0]);
    title([cnm])
    legend(modelNames,'FontSize',15,'Location','southwest'); legend boxoff             
end 