% Plot Results for Test Percentile Approach

%% Clear Workspace
clear all
clc

%% Adding paths
addpath('../BGFS_optimization/')
addpath('../BGFS_optimization/fminlbfgs_version2c')
addpath('../shared_functions/')

%% Set Scenario Name and Destination Folder
ScenarioName = 'CSV4'
%ScenarioName = 'RPGM'
%ScenarioName = 'DA'

DestFolder = sprintf('%sPercentilePair', ScenarioName);

%% Setting up the input file
if (strcmp(ScenarioName,'CSV4'))
    InputFile = './Inputs/CSV4Original.one'
    TitleStr = 'Total Link Erros for Random Waypoint';
elseif (strcmp(ScenarioName,'RPGM'))
    InputFile = './Inputs/RPGMScenario.one'
    TitleStr = 'Total Link Erros for RPGM';
elseif (strcmp(ScenarioName,'DA'))
    InputFile = './Inputs/DA.one'
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
 %% Main run
Parameters = struct('NormMode',NormMode,'SpecialVarargin',1, 'PlotContent',...
    PlotContent,'DestFolder',DestFolder,'TitleStr',TitleStr);
%Adjustments
if (strcmp(ScenarioName,'DA'))
    Parameters.AxisClipMode = 2
    Parameters.LegendLocation = 'NorthEast';
end
if (strcmp(ScenarioName,'RWP'))
    Parameters.LegendLocation = 'NorthEast';
end

%Percenties = 0:5:50;
Percenties = [0 5 10 20 30 40 50];
Inputs = cell(1,length(Percenties)+1);
Inputs{1} = InputFile;
Parameters.CustomLegend = cell(1,length(Percenties));
i = 1;
for i1 = Percenties
    Parameters.CustomLegend{i} = sprintf('Percentile %d',i1);
    PercentileValues = [i1 100-i1];
    Rs=NodepairDistanceHistogram(InputFile, Range, mode, PercentileValues,0);
    name = sprintf('./%s/%s_R_%d_%d_P_%d.one',DestFolder,Name,round(Rs(1)),round(Rs(2)),i1)
    Inputs{i+1} = name;
    i = i + 1;
end
%RVector=horzcat(1:19,20:5:150);
RVector=0:150;
CompareConnectivitiesOverR(RVector,Parameters, Inputs);
        