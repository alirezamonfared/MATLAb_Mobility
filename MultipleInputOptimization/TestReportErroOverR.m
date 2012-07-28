% % Test Report Errors
% addpath('../shared_functions/')
% 
% Parameters = struct('InputRs',100,'range',[0 150],'step',1)
% Err = ReportErrorOverR('./Inputs/DA.one','./DA/DA_100.one',Parameters);

%% Clear Workspace
clear all
clc

%% Adding paths
addpath('../shared_functions/')

%% Setting up Destination Folder
%ScenarioName = 'CSV4'
%ScenarioName = 'RPGM'
ScenarioName = 'DA'

%Scenario = 'OriginalHistogram'
Scenario = 'Gaussian'

if (strcmp(Scenario,'OriginalHistogram'))
    DestFolder = sprintf('%sPercentilePair', ScenarioName)
elseif(strcmp(Scenario,'Gaussian'))
    DestFolder = sprintf('%sSynthPtile', ScenarioName)
else
    error('Wrong Scenario Chosen')
end

if(~exist(DestFolder,'dir'))
    mkdir(DestFolder);
end
%% Setting up the input file
if (strcmp(ScenarioName,'CSV4'))
    OriginalInputFile = './Inputs/CSV4Original.one'
    Baseline = {'./CSV4_100/CSV4Original_R_10.one',...
        './CSV4_100/CSV4Original_R_100.one','./CSV4MultiRanges/CSV4Original_R_10_100.one'};   
    Percenties = 0:5:45;
elseif(strcmp(ScenarioName,'RPGM'))
    OriginalInputFile = './Inputs//RPGMScenario.one'
    Baseline = {'./RPGM100/RPGM_R_10.one', ...
        './RPGM100/RPGM_R_100.one','./RPGMMultiRanges/RPGMScenario_R_10_100.one'};
    Percenties = 0:5:50;
elseif(strcmp(ScenarioName,'DA'))
    OriginalInputFile = './Inputs/DA.one'
    Baseline = {'./DA/DA_10.one', './DA/DA_100.one',...
        './DAMultiRanges/DA_10_100.one'};
    Percenties = 0:5:50;
else
    error('Something wrong with ScenarioName')
end

[Path Name Ext]=fileparts(OriginalInputFile);
Range = [0 150];

RValues = {[0 150],[27 123],[38 112],[45 105],[51 99],[55 95],[60 90],[64 86],...
    [68 82],[71 79],[75 75]};

 %% Main run

 %RecordedErrors = zeros(length(Percenties)+3,9); % Legacy when we used Stds
 RecordedErrors = zeros(length(Percenties)+3,8);
 step = 1;
 RemoveRange = 3;
 NormMode = 0;
 for c = 1:3
     %Err = zeros(1,9);
     Err = zeros(1,8);
     Err(1) = 0;
     Err(2) = 10^c;
     Err(3) = 10^c;
     if (c == 3)
         Err(2) = 10;
         Err(3) = 100;
     end
     InputRs = 10^c;
     Parameters = struct('InputRs',InputRs,'Range',Range,'step',step,...
         'RemoveRange',RemoveRange,'NormMode',NormMode);
     Err(4:end) = ReportErrorOverR(OriginalInputFile,Baseline{c},Parameters);
     RecordedErrors(c,:) = Err;
 end
 c = 4;
 for i1 = Percenties
     %Err = zeros(1,9);
     Err = zeros(1,8);
     PercentileValues = [i1 100-i1]
     if (strcmp(Scenario,'OriginalHistogram'))
         InputRs=round(NodepairDistanceHistogram(OriginalInputFile, ...
             Range, 0, PercentileValues))
     elseif(strcmp(Scenario,'Gaussian'))
         InputRs=RValues{c-3}
     else
         error('Wrong Scenario Chosen')
     end
     Parameters = struct('InputRs',InputRs,'Range',Range,'step',step,...
         'RemoveRange',RemoveRange,'NormMode',NormMode);
     
     Err(1) = i1;
     Err(2) = InputRs(1);
     Err(3) = InputRs(2);
     InferredFile = sprintf('./%s/%s_R_%d_%d_P_%d.one',DestFolder,...
         Name,InputRs(1),InputRs(2),i1);
     Err(4:end) = ReportErrorOverR(OriginalInputFile,InferredFile,Parameters);
     RecordedErrors(c,:) = Err;
     c = c + 1;
 end

 CSVNmae = sprintf('./%s/%s.csv',DestFolder,Name);
 csvwrite(CSVNmae,RecordedErrors);