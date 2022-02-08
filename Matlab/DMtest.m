function res  = DMtest(f0, f1, a, CI, CW, p)

% f0, f1 - forecasts from M0 (benchmark),M1
% act    - actuals  
% one sided test
% H0: M0 is true (for Clark-West)
% H0: e0^2 = e1^2 --> d=0
% H1: e0^2 > e1^2 --> d>0
% CW = 1: for Clark-West adjustment, and DM test otherwise
% CI = 1: Coroneo-Iacone (2018)
if nargin == 3
    CI    = 1;
    CW    = 0;
    p     = 2;
end


e0  = abs(a - f0);
e1  = abs(a - f1);
d   = e0.^p - e1.^p;
if CW == 1
    adj = (f1 - f0).^2;
    d   = d + adj;
end

T   = length(d);
% long run matrix
X      = ones(T,1);
u      = d - X * mean(d);
if CI == 1
    % Coroneo-Iacone (2018) Comparing predictive accuracy in small samples using fixed smoothing asymptotics, JAE
    % method based on periodogram
    m  = floor(T^(1/3));
    % calculating periodogram
    Tspec = floor(T/2);
    freq  = 1/T:1/T:(Tspec/T);
    % fast furier transform
    xfft = zeros(T,1);
    for t=1:T
      for s=1:T
        xfft(t) = xfft(t) + u(s)*exp(-1i*2*pi*(t-1)*(s-1)/T);
      end
    end
    pgram  = real(xfft .* conj(xfft)/T);
    pgram  = pgram(2:(Tspec + 1));
    Sig  = mean(pgram(1:m));
    k    = 2*m;
else
    % Newey-West bandwidth method
    k      = T-1;
    nlags  = floor(4*(T/100)^(2/9)); 
    Sig    = 0;                         % Initialization of covariance matrix
    for ii = 0:nlags
        w = 1 - (ii/(nlags+1));
        rho = u(1:T-ii,:)'*u(1+ii:T,:)/(T-1);  
        if ii >= 1, rho = 2*rho; end
        Sig = Sig + w*rho;  
    end
   
end
Se        = sqrt(Sig/T);
% one sided test
tstat     = mean(d)/Se;            res.stat = tstat;
prob      = 1-tcdf(tstat,k);       res.prob = prob;    

%{
###############################################################
# Three tests of equal accuracy based on Diebold-Mariano test #
# INPUT VARIABLES                                             # 
# e1   - fct errors from analized model  (M1)                 #
# e2   - fct errors from benchmark model (M2)                 #
#  h   - forecast horizon                                     #
# type - "two sided" vs "one-sided" test                      #
#   1  - two sided test                                       #
#   2  - rejection of the null means that M1 outperforms M2   #
# power- d = |e1|^power - |e2|^power, default 2               #
# OUTPUT VARIABLES                                            #
# stat - the value of statistic                               #
# pval - p. value of the test                                 #
# Description of the methods in                               # 
# Harvey, Leybourne and Whitehouse, 2017.Forecast eveluation  #
# tests and negative long-run variance estimates in small samples, IJF
###############################################################

# 1. Diebold - Mariano, 1995, Comparing predictive accuracy, JBES 13
DMtest <- function(e1,e2,h=1,type=1,power=2){
  d     <- na.omit(c(abs(e1))^power - c(abs(e2))^power)
  T     <- length(d)
  d.acf <- acf(d, lag.max = h - 1, type = "covariance", plot = FALSE)$acf[, , 1]
  omega <- sum(c(d.acf[1], 2 * d.acf[-1]))
  d.adj <- sqrt(T)
  if(omega <= 0){
    stat = NA
    pval = NA
  } else {
    stat  <- d.adj*mean(d)/sqrt(omega)
    if(type==1){pval  <- 2*pnorm(-abs(stat))}  # two-sided
    else {pval  <- pnorm(stat)}
  }
  return(list(stat=stat,pval=pval))  
}

# 2. Harvey-Leybourn-Mariano (1997) Testing the equality of prediction mean squarred errors, IJF
HLNtest <- function(e1,e2,h=1,type=1,power=2){
  d     <- na.omit(c(abs(e1))^power - c(abs(e2))^power)
  T     <- length(d)
  d.acf <- acf(d, lag.max = h - 1, type = "covariance", plot = FALSE)$acf[, , 1]
  omega <- sum(c(d.acf[1], 2 * d.acf[-1]))
  d.adj <- sqrt(T + 1 - 2*h + (h/T)*(h-1))
  if(omega <= 0){
    stat = NA
    pval = NA
  } else {
    stat  <- d.adj * mean(d)/sqrt(omega)
    if(type==1){pval  <- 2*pt(-abs(stat), T-1)} 
    else {      pval  <- pt(stat,T-1)      }
  }
  return(list(stat=stat,pval=pval))  
}


# 3. Coroneo-Iacone (2018) Comparing predictive accuracy in small samples using fixed smoothing asymptotics, JAE
CItest <- function(e1,e2,h=1,type=1,power=2){
  d      <- na.omit(c(abs(e1))^power - c(abs(e2))^power)
  T      <- length(d)
  m      <- floor(T^(1/3))
  d.spec <- spec.pgram(d,demean=TRUE,detrend=FALSE,taper=0)
  omega  <- mean(d.spec$spec[1:m])
  d.adj  <- sqrt(T)
  if(omega <= 0){
    stat = NA
    pval = NA
    
  } else {
    stat  <- d.adj * mean(d)/sqrt(omega)
    if(type==1){                   # two-sided
      pval  <- 2*pt(-abs(stat), 2*m)  
    } else {
      pval  <- pt(stat,2*m)  
    }
  }
  return(list(stat=stat,pval=pval))  
}

%}


