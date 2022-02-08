clear
format compact
addpath(genpath('PanelToolbox'));

load 'data_vars.mat' 
load 'data_eer.mat'

%% Settings for forecasting loop

H = 20; opt.H = H;              % forecast horion
mdlN_max = 8;                   % number of EER models (PPP, 4xBEER, 3xMB)

% Forecasting loop

% Forecasting loop
m = 0; % model counter

% Random Walk 
if 1
    display('Random Walk is running...');
    m = m + 1;
    for n = 1:opt.N
        crnc_name    = char(opt.cnam(n));
        fcst         = ForecastRW(ner(:,n), opt);
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
            fcst         = ForecastEqHLner(ner(:,n),rer(:,n),rer_eq(:,:,n), opt, rho);
            eval(['f.',crnc_name,'= fcst;'])
        end
        ALLfct{m} = f;
        ALLfct{m}.description = desc;
        clear f;
    end
end

% Direct forecast models
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
                fcst         = ForecastDAR(ner(:,n),rer_gap(:,:,n), opt);
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
        ALLfct{m} = ForecastPanelDAR(ner,rer_gap, opt);
        ALLfct{m}.description = desc;       
    end
end

% save all forecasts
save('data_fct_ner.mat', 'ALLfct', 'opt')


if 0
   % Full sample exchange rate adjustment SCATTER PLOTS
   horizons = [1 4 12 20];
   scaleS    = [0.5 0.5 1];
   hh=0;
   figure1 = figure('Color',[1 1 1]);
   axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
   hold on
   for h=horizons
       for mdlN = 1:3
           hh=hh+1;
           switch mdlN
               case 1
                   rer_eq = rer_ppp; desc = 'PPP';
               case 2
                   rer_eq = rer_eba; desc = 'BEER';
               case 3
                   rer_eq = feer_eba; desc = 'MB';
           end
           rer_gap = bsxfun(@minus,permute(rer,[3 1 2]),rer_eq);
           crncyR = repmat(1:opt.N,opt.T-h,1); 
           crncyR = crncyR(:,[1:3 5:9 4 10]); crncyR = crncyR(:);
           rer_diff = rer((h+1):end,:) - rer(1:(end-h),:); 
           rer_diff = rer_diff(:,[1:3 5:9 4 10]); rer_diff=rer_diff(:); % change order of countries (so that US&EA in the foreground)
           mis = squeeze(rer_gap(opt.T,:,:));  % misalignment
           x0  = mis(1:(end-h),:); 
           x0  = x0(:,[1:3 5:9 4 10]); x0=x0(:);
           subplot1 = subplot(4,3,hh,'Parent',figure1,'FontName','Times New Roman', 'FontSize', 10);
           P_colors = repmat([0 50 153]./255,length(x0),1);
           P_colors(crncyR==4,:)=repmat([255 180 0]/255,opt.T-h,1);
           P_colors(crncyR==10,:)=repmat([255 75 0]/255,opt.T-h,1);
           P = scatter(x0, rer_diff,10,P_colors,'o');
           S = scaleS(mdlN);
           xlim([-S,S])
           ylim([-S,S])
           %P_line = lsline;
           %set(P_line,'LineWidth',1.5, 'Color',[1 0 0]);
           hold on
           plot(-S:0.01:S,S:-0.01:-S,'Color',[0 0 0],'LineWidth',1 )
           hold on
           plot(-S:S,zeros(2*S+1,1),':','Color',[0 0 0],'LineWidth',0.5)
           hold on
           plot(zeros(2*S+1,1),-S:S,':','Color',[0 0 0],'LineWidth',0.5)
           hold on
           
           if h == 1; title(desc); end;
           if mdlN == 1; ylabel([num2str(h),'-quater horizon']); end
           % P_title = title([desc ', h = ' int2str(h)]);
           %P_title = title(['h = ' int2str(h)]);
       end
   end
   hold off
end
