clear; clc;

% Step 1. Loading data from excel and saving to matlab (data_vars.mat)
A1_LoadDataExcel.m

% Step 2. Estimating equilibrium exchange rates and saving to data_eer.mat)
% qPPP / qGDP / qTOT / qNFA / qEBA
A2_EqRERestimates.m

% Step 3. Generate forecasts and save to data_fct.mat
A3_ForecastsGenerate.m
% also generate forecasts for NER save to data_fct_ner.mat
A3_ForecastsGenerateNER.m

% Step 4. Calculate statistics (you can rename file rmse_linked.xlsx to
% rmse.xlsx to see the results in the form of tables)
A4_RMSEtables.m
% At the beginning of the file you can choose to generate the results for
% NER

% Step 5. Produce some nice graphs with files that start with letters B.

% Note: penel direct forecast regressions are using codes from http://www.paneldatatoolbox.com