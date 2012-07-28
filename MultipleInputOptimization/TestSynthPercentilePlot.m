% Test Synthetic Percentile Plot


%% Clear Workspace
clear all
clc

%% Adding paths
addpath('../BGFS_optimization/')
addpath('../BGFS_optimization/fminlbfgs_version2c')
addpath('../shared_functions/')

%% Set Scenario Name and Destination Folder
%ScenarioName = 'CSV4'
%ScenarioName = 'RPGM'
ScenarioName = 'DA'

DestFolder = sprintf('%sSynthPtile', ScenarioName);

%% Setting up the input file
if (strcmp(ScenarioName,'CSV4'))
    InputFile = './Inputs/CSV4Original.one'
    BestPtile = './CSV4PercentilePair/CSV4Original_R_34_146_P_5.one'
    TitleStr = 'Total Link Erros for Random Waypoint';
elseif (strcmp(ScenarioName,'RPGM'))
    InputFile = './Inputs/RPGMScenario.one'
    BestPtile = './RPGMPercentilePair/RPGMScenario_R_1_137_P_10.one'
    TitleStr = 'Total Link Erros for RPGM';
elseif (strcmp(ScenarioName,'DA'))
    InputFile = './Inputs/DA.one'
    BestPtile = './DAPercentilePair/DA_R_43_68_P_35.one'
    TitleStr = 'Total Link Erros for Disaster Area Model';
else
    error('Invalid Scenario Name')
end

[Path Name Ext]=fileparts(InputFile);

%% Setting up the range values
mode = 0;
Range = [0 150];
NormMode = 0;
PlotContent = 0;
 
RValues = {[0 150],[27 123],[38 112],[45 105],[51 99],[55 95],[60 90],[64 86],...
    [68 82],[71 79],[75 75]}
 %% Main run
Parameters = struct('NormMode',NormMode,'SpecialVarargin',1, 'PlotContent',...
    PlotContent,'DestFolder',DestFolder,'TitleStr',TitleStr);
Percenties = 0:5:50;
%Percenties = 0:5:45;
%Percenties = [0 5 10 20 30 40 50];
Inputs = cell(1,length(Percenties)+2);
Inputs{1} = InputFile;
Parameters.CustomLegend = cell(1,length(Percenties)+1);

i = 1;
Inputs{i+1} = BestPtile;
Parameters.CustomLegend{i} = 'Best Histogram Percentile';

i = 2;
for i1 = Percenties
    Parameters.CustomLegend{i} = sprintf('Percentile %d',i1);
    PercentileValues = [i1 100-i1];
    Rs=RValues{i-1};
    name = sprintf('./%s/%s_R_%d_%d_P_%d.one',DestFolder,Name,round(Rs(1)),round(Rs(2)),i1)
    Inputs{i+1} = name;
    i = i + 1;
end
%RVector=horzcat(1:19,20:5:150);
RVector=0:150;
CompareConnectivitiesOverR(RVector,Parameters, Inputs);
        