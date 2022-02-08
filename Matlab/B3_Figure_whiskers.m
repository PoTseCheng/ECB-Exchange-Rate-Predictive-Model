close all
clear all
clc
format compact
load data_fct;
load data_vars;

% rescaling 

E      = 80;                      % size of estimation sample
evs    = 96;                      % size of evaluation sample
H      = 20;                      % forecast horizon

% Figure 9
cntryNames = [{'USA'} {'EA'} {'JPN'} {'GBR'} {'CHE'}];
cntryInd   = [10 4 6 5 3];
% Figure 10 
%cntryNames = [{'CAN'} {'AUS'} {'NZL'} {'NOR'}  {'SWE'}];
%cntryInd   = [2 1 8 7 9];

% select models, 18 - PPP_PDF, 22 - BEER_PDF, 23 - MB_PDF
mSet  = [18 22 23]; 
modelNames = [{'PPP'} {'BEER'} {'MB'}];

n = 0;

figure('Name','Whiskers','Color',[1 1 1]);

for cN = 1:5   
    y      = rer(:,cntryInd(cN));  % observable
    cNam   = cntryNames{cN};

for mN = mSet % loop for models in ALLfct
    n = n+1; % counter
    subplot(5,3,n)
    
    y_lim = [min(rer(:,cntryInd(cN)))-0.03 max(rer(:,cntryInd(cN)))+0.03];
    %y_lim = [min(rer(:,cntryInd(cN)))-0.1 max(rer(:,cntryInd(cN)))+0.07];
     % Generating forecast and past actuals
        eval(['temp  = ALLfct{1, mN}.',cNam,'.fct;']);
        q_fct = NaN(evs,E+evs+H);

        for i=1:evs
            q_fct(i,1:E+i-1)     = y(1:1:E+i-1);
            q_fct(i,E+i:E+i+H-1) = temp(i,1:H); %temp(i,1:H) + y(E+i-1);
        end
        %q_fct = exp(q_fct/100)/ ylevel(1);
        
        plot(1975:0.25:2023.75,q_fct,'Color',[0.5 0.5 0.5]); 
        if n<4; title(modelNames{n}); end
        if mN==18; ylabel(cNam); end
                
        ylim(y_lim); 
        xlim([1985 2023]); 
        hold on;
      
        plot(1975:0.25:2018.75,y,'-k','LineWidth',2); hold off;
        set(gca, 'XTick', [1990 2000 2010 2020])
        box('off')
end
end
    
   
    

 