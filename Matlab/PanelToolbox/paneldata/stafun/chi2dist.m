function [ p ] = chi2dist( x, v )
%CHI2DIST Return the cumulative distribution function of a Chi-Square
%   Return the cumulative distribution function of a Chi-Square with v
%   degrees of freedom
%
%   AUTHORS: Inmaculada C. �lvarez, Javier Barbero, Jos� L. Zof�o
%   http://www.paneldatatoolbox.com
%
%   Version: 2.0
%   LAST UPDATE: 9, June, 2015
%

    p = gammainc(x/2, v/2);

end

