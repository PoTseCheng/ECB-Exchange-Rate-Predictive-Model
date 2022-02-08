function out = newey(y, X)

    % newey(y,X) runs linear regression y = X*b + e (with constant - reported in the first position of the respective arrays) 
    % and Newey-West standard errors (using the Andrews and Monohan (1992) approximation for max. number of lags)
    % input: y = vector of the dependent variable, X = matrix with the
    % independent variables

    % Estimate regression with N-W SE
    s_reg_stats = struct();
    s_reg_stats.maxLag      = floor(4*(length(y)/100)^(2/9)); % Andrews and Monohan (1992)
    [~, s_reg_stats.se, s_reg_stats.coeff] = hac(X,y,'bandwidth',s_reg_stats.maxLag+1,'display','off');
    
    % get R2 and degrees of freedom 
    tmp_mdl                 = fitlm(X, y);
    s_reg_stats.rsquare     = tmp_mdl.Rsquared.Ordinary;
    s_reg_stats.rsquare_adj = tmp_mdl.Rsquared.Adjusted;
    s_reg_stats.df          = tmp_mdl.DFE;
    
    % calculate t-stats and p-values from SE
    s_reg_stats.t_stat = s_reg_stats.coeff ./ s_reg_stats.se;
    %s_reg_stats.df = min([sum(~isnan(chart_Y)) sum(~isnan(testX))]) - size(X, 2) - 1; % Number of observations in the regression
    s_reg_stats.pval = 2 * tcdf(-abs(s_reg_stats.t_stat), repmat(s_reg_stats.df, size(s_reg_stats.t_stat)));

    % return output
    out = s_reg_stats;

end