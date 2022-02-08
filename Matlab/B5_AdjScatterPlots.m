close all
clear all
clc
format compact
load data_eer;
load data_vars;

% rescaling 

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
           if mdlN == 1; ylabel([num2str(h),'-quarter horizon']); end
           % P_title = title([desc ', h = ' int2str(h)]);
           %P_title = title(['h = ' int2str(h)]);
       end
   end
   hold off

    

 